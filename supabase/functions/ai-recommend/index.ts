// =====================================================
// AI RECOMMEND - Edge Function
// Recomendaciones personalizadas usando OpenAI + historial
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// Configuración
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

// Cliente Supabase con service_role (para leer datos del usuario)
const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// =====================================================
// TIPOS
// =====================================================

interface RequestBody {
  prompt: string;
  content_type?: "movie" | "tv" | "both";
  limit?: number;
}

interface UserHistory {
  watchlist: HistoryItem[];
  favorites: HistoryItem[];
  watched: HistoryItem[];
  ratings: RatingItem[];
}

interface HistoryItem {
  tmdb_id: number;
  content_type: string;
  title?: string;
}

interface RatingItem extends HistoryItem {
  rating: number;
}

interface Recommendation {
  tmdb_id: number;
  title: string;
  content_type: "movie" | "tv";
  reason: string;
  tags: string[];
  confidence: number;
}

interface TMDBResult {
  id: number;
  title?: string;
  name?: string;
  overview?: string;
  vote_average?: number;
  genre_ids?: number[];
  release_date?: string;
  first_air_date?: string;
}

// =====================================================
// AUTH: Validar JWT
// =====================================================

async function validateUser(req: Request): Promise<{ userId: string } | null> {
  const authHeader = req.headers.get("Authorization");
  
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }

  const token = authHeader.replace("Bearer ", "");
  
  // Crear cliente con el token del usuario para validar
  const supabaseClient = createClient(SUPABASE_URL, SUPABASE_ANON_KEY, {
    global: { headers: { Authorization: `Bearer ${token}` } },
  });

  const { data: { user }, error } = await supabaseClient.auth.getUser();
  
  if (error || !user) {
    return null;
  }

  return { userId: user.id };
}

// =====================================================
// DB: Leer historial del usuario
// =====================================================

async function getUserHistory(userId: string): Promise<UserHistory> {
  // Leer en paralelo
  const [watchlistRes, favoritesRes, watchedRes, ratingsRes] = await Promise.all([
    // Watchlist
    supabaseAdmin
      .from("user_movie_state")
      .select("tmdb_id, content_type")
      .eq("user_id", userId)
      .eq("status", "watchlist")
      .limit(50),
    
    // Favoritos
    supabaseAdmin
      .from("user_movie_state")
      .select("tmdb_id, content_type")
      .eq("user_id", userId)
      .eq("is_favorite", true)
      .limit(50),
    
    // Vistos
    supabaseAdmin
      .from("user_movie_state")
      .select("tmdb_id, content_type")
      .eq("user_id", userId)
      .eq("status", "watched")
      .limit(50),
    
    // Ratings (con puntuación)
    supabaseAdmin
      .from("user_ratings")
      .select("tmdb_id, content_type, rating")
      .eq("user_id", userId)
      .order("rating", { ascending: false })
      .limit(30),
  ]);

  return {
    watchlist: (watchlistRes.data || []) as HistoryItem[],
    favorites: (favoritesRes.data || []) as HistoryItem[],
    watched: (watchedRes.data || []) as HistoryItem[],
    ratings: (ratingsRes.data || []) as RatingItem[],
  };
}

// =====================================================
// TMDB: Llamar al proxy interno
// =====================================================

async function callTmdbProxy(path: string, query?: Record<string, unknown>): Promise<unknown> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/tmdb-proxy`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({ path, query }),
  });

  if (!response.ok) {
    throw new Error(`TMDB Proxy error: ${response.status}`);
  }

  return response.json();
}

async function getTmdbDetails(tmdbId: number, contentType: "movie" | "tv"): Promise<TMDBResult | null> {
  try {
    const data = await callTmdbProxy(`${contentType}/${tmdbId}`) as TMDBResult;
    return data;
  } catch {
    return null;
  }
}

async function searchTmdb(query: string, contentType: "movie" | "tv" | "multi" = "multi"): Promise<TMDBResult[]> {
  try {
    const data = await callTmdbProxy(`search/${contentType}`, { query }) as { results: TMDBResult[] };
    return data.results || [];
  } catch {
    return [];
  }
}

// =====================================================
// AI: Generar recomendaciones con OpenAI
// =====================================================

async function generateRecommendations(
  prompt: string,
  history: UserHistory,
  contentType: "movie" | "tv" | "both",
  limit: number
): Promise<Recommendation[]> {
  if (!OPENAI_API_KEY) {
    throw new Error("OpenAI no configurado");
  }

  // Obtener títulos de favoritos y mejor calificados para contexto
  const topRated = history.ratings
    .filter((r) => r.rating >= 7)
    .slice(0, 10);
  
  const favoriteIds = history.favorites.slice(0, 10);
  
  // Obtener detalles de TMDB para contexto
  const detailsPromises = [...topRated, ...favoriteIds].slice(0, 15).map(async (item) => {
    const details = await getTmdbDetails(item.tmdb_id, item.content_type as "movie" | "tv");
    return details ? { ...item, title: details.title || details.name } : null;
  });
  
  const detailsResults = await Promise.all(detailsPromises);
  const withTitles = detailsResults.filter((d): d is HistoryItem & { title: string } => d !== null && !!d.title);

  // Construir contexto para OpenAI
  const favoriteTitles = withTitles.map((d) => d.title).join(", ") || "ninguno";
  const watchedCount = history.watched.length;
  const contentTypeText = contentType === "both" ? "películas o series" : contentType === "movie" ? "películas" : "series";

  const systemPrompt = `Eres un experto en cine y series de TV. Tu tarea es recomendar ${contentTypeText} basándote en:
1. El prompt del usuario
2. Sus gustos previos

REGLAS ESTRICTAS:
- Devuelve EXACTAMENTE ${limit} recomendaciones
- Formato JSON válido, sin texto adicional
- Solo recomienda contenido REAL que exista
- NO repitas títulos del historial del usuario
- "confidence" es un número entre 0.0 y 1.0

FORMATO DE RESPUESTA (JSON array):
[
  {
    "title": "Título exacto en español o inglés",
    "content_type": "movie" o "tv",
    "reason": "Por qué le gustará (1-2 frases)",
    "tags": ["tag1", "tag2", "tag3"],
    "confidence": 0.85
  }
]`;

  const userPrompt = `HISTORIAL DEL USUARIO:
- Ha visto ${watchedCount} títulos
- Favoritos/mejor calificados: ${favoriteTitles}

PROMPT DEL USUARIO:
"${prompt}"

Devuelve ${limit} recomendaciones de ${contentTypeText} en formato JSON.`;

  // Llamar a OpenAI
  const openaiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        { role: "system", content: systemPrompt },
        { role: "user", content: userPrompt },
      ],
      temperature: 0.7,
      max_tokens: 1500,
    }),
  });

  if (!openaiResponse.ok) {
    const error = await openaiResponse.text();
    console.error("OpenAI error:", error);
    throw new Error("Error al generar recomendaciones");
  }

  const openaiData = await openaiResponse.json();
  const content = openaiData.choices?.[0]?.message?.content || "[]";

  // Parsear respuesta
  let aiRecommendations: Array<{
    title: string;
    content_type: "movie" | "tv";
    reason: string;
    tags: string[];
    confidence: number;
  }>;

  try {
    // Limpiar posible markdown
    const cleanContent = content.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
    aiRecommendations = JSON.parse(cleanContent);
  } catch {
    console.error("Error parsing AI response:", content);
    throw new Error("Error al procesar recomendaciones");
  }

  // Buscar tmdb_id para cada recomendación
  const recommendations: Recommendation[] = [];

  for (const rec of aiRecommendations) {
    // Buscar en TMDB
    const searchResults = await searchTmdb(rec.title, rec.content_type);
    
    if (searchResults.length > 0) {
      const match = searchResults[0];
      
      // Verificar que no esté en el historial
      const isInHistory = [
        ...history.watched,
        ...history.favorites,
        ...history.watchlist,
      ].some((h) => h.tmdb_id === match.id && h.content_type === rec.content_type);

      if (!isInHistory) {
        recommendations.push({
          tmdb_id: match.id,
          title: match.title || match.name || rec.title,
          content_type: rec.content_type,
          reason: rec.reason,
          tags: rec.tags,
          confidence: Math.min(1, Math.max(0, rec.confidence)),
        });
      }
    }

    // Parar si ya tenemos suficientes
    if (recommendations.length >= limit) break;
  }

  return recommendations;
}

// =====================================================
// HANDLER PRINCIPAL
// =====================================================

serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Solo POST
  if (req.method !== "POST") {
    return jsonResponse({ error: "Método no permitido", code: "METHOD_NOT_ALLOWED" }, 405);
  }

  try {
    // 1. Validar usuario
    const user = await validateUser(req);
    if (!user) {
      return jsonResponse({ error: "No autenticado", code: "UNAUTHORIZED" }, 401);
    }

    // 2. Parsear body
    let body: RequestBody;
    try {
      body = await req.json();
    } catch {
      return jsonResponse({ error: "JSON inválido", code: "INVALID_JSON" }, 400);
    }

    // 3. Validar input
    const { prompt, content_type = "both", limit = 5 } = body;

    if (!prompt || typeof prompt !== "string" || prompt.trim().length < 3) {
      return jsonResponse({ 
        error: "El prompt debe tener al menos 3 caracteres", 
        code: "INVALID_PROMPT" 
      }, 400);
    }

    if (prompt.length > 500) {
      return jsonResponse({ 
        error: "El prompt no puede exceder 500 caracteres", 
        code: "PROMPT_TOO_LONG" 
      }, 400);
    }

    const validContentTypes = ["movie", "tv", "both"];
    if (!validContentTypes.includes(content_type)) {
      return jsonResponse({ 
        error: "content_type debe ser 'movie', 'tv' o 'both'", 
        code: "INVALID_CONTENT_TYPE" 
      }, 400);
    }

    const finalLimit = Math.min(Math.max(1, limit), 10); // Entre 1 y 10

    // 4. Obtener historial del usuario
    const history = await getUserHistory(user.userId);

    // 5. Generar recomendaciones
    const recommendations = await generateRecommendations(
      prompt.trim(),
      history,
      content_type as "movie" | "tv" | "both",
      finalLimit
    );

    // 6. Responder
    return jsonResponse({
      success: true,
      prompt: prompt.trim(),
      content_type,
      recommendations,
      meta: {
        user_history: {
          watchlist_count: history.watchlist.length,
          favorites_count: history.favorites.length,
          watched_count: history.watched.length,
          ratings_count: history.ratings.length,
        },
        generated_at: new Date().toISOString(),
      },
    }, 200);

  } catch (error) {
    console.error("Error en ai-recommend:", error);
    
    const message = error instanceof Error ? error.message : "Error interno";
    return jsonResponse({ error: message, code: "INTERNAL_ERROR" }, 500);
  }
});

// =====================================================
// HELPERS
// =====================================================

function jsonResponse(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
