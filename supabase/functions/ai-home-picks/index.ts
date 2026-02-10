// =====================================================
// AI HOME PICKS - Edge Function
// Recomendaciones IA seguras: criterios -> TMDB -> IDs reales
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// Configuracion
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const SUPABASE_ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY")!;
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

// Cliente Supabase con service_role
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

interface UserPreferences {
  preferred_genres: number[];
  mood_text: string;
  onboarding_completed: boolean;
}

interface UserHistory {
  favorites: HistoryItem[];
  watched: HistoryItem[];
  ratings: RatingItem[];
  preferences: UserPreferences | null;
}

interface HistoryItem {
  tmdb_id: number;
  content_type: string;
}

interface RatingItem extends HistoryItem {
  rating: number;
}

interface SearchCriteria {
  genres: number[];
  year_min?: number;
  year_max?: number;
  vote_min?: number;
  content_type: "movie" | "tv";
  sort_by?: string;
  reason: string;
}

interface AIPick {
  tmdb_id: number;
  title: string;
  poster_path: string | null;
  backdrop_path: string | null;
  overview: string;
  vote_average: number;
  release_date: string | null;
  content_type: "movie" | "tv";
  genre_ids: number[];
  reason: string;
}

interface TMDBMovie {
  id: number;
  title?: string;
  name?: string;
  overview: string;
  poster_path: string | null;
  backdrop_path: string | null;
  vote_average: number;
  release_date?: string;
  first_air_date?: string;
  genre_ids: number[];
}

// Mapa de generos TMDB
const GENRE_MAP: Record<string, number> = {
  // Peliculas
  "accion": 28,
  "aventura": 12,
  "animacion": 16,
  "comedia": 35,
  "crimen": 80,
  "documental": 99,
  "drama": 18,
  "familia": 10751,
  "fantasia": 14,
  "historia": 36,
  "terror": 27,
  "musica": 10402,
  "misterio": 9648,
  "romance": 10749,
  "ciencia ficcion": 878,
  "sci-fi": 878,
  "thriller": 53,
  "guerra": 10752,
  "western": 37,
  // TV
  "action & adventure": 10759,
  "kids": 10762,
  "news": 10763,
  "reality": 10764,
  "sci-fi & fantasy": 10765,
  "soap": 10766,
  "talk": 10767,
  "war & politics": 10768,
};

// =====================================================
// AUTH: Validar JWT
// =====================================================

async function validateUser(req: Request): Promise<{ userId: string } | null> {
  try {
    const authHeader = req.headers.get("Authorization");

    if (!authHeader?.startsWith("Bearer ")) {
      return null;
    }

    const token = authHeader.replace("Bearer ", "");
    const { data, error } = await supabaseAdmin.auth.getUser(token);

    if (error || !data?.user) {
      return null;
    }

    return { userId: data.user.id };
  } catch (e) {
    console.error("validateUser error:", e);
    return null;
  }
}

// =====================================================
// DB: Leer historial del usuario
// =====================================================

async function getUserHistory(userId: string): Promise<UserHistory> {
  const [favoritesRes, watchedRes, ratingsRes, preferencesRes] = await Promise.all([
    supabaseAdmin
      .from("user_movie_state")
      .select("tmdb_id, content_type")
      .eq("user_id", userId)
      .eq("is_favorite", true)
      .limit(30),

    supabaseAdmin
      .from("user_movie_state")
      .select("tmdb_id, content_type")
      .eq("user_id", userId)
      .eq("status", "watched")
      .limit(30),

    supabaseAdmin
      .from("user_ratings")
      .select("tmdb_id, content_type, rating")
      .eq("user_id", userId)
      .order("rating", { ascending: false })
      .limit(20),

    // Obtener preferencias del onboarding
    supabaseAdmin
      .from("profiles")
      .select("preferred_genres, mood_text, onboarding_completed")
      .eq("id", userId)
      .maybeSingle(),
  ]);

  return {
    favorites: (favoritesRes.data || []) as HistoryItem[],
    watched: (watchedRes.data || []) as HistoryItem[],
    ratings: (ratingsRes.data || []) as RatingItem[],
    preferences: preferencesRes.data as UserPreferences | null,
  };
}

// =====================================================
// TMDB: Llamar al proxy interno
// =====================================================

// Variables globales para language/region (set en el handler)
let globalLanguage = "es-ES";
let globalRegion = "ES";

async function callTmdbProxy(path: string, query?: Record<string, unknown>): Promise<unknown> {
  const response = await fetch(`${SUPABASE_URL}/functions/v1/tmdb-proxy`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
    },
    body: JSON.stringify({
      path,
      query,
      language: globalLanguage,
      region: globalRegion,
    }),
  });

  if (!response.ok) {
    throw new Error(`TMDB Proxy error: ${response.status}`);
  }

  return response.json();
}

async function discoverMovies(criteria: SearchCriteria): Promise<TMDBMovie[]> {
  const query: Record<string, unknown> = {
    sort_by: criteria.sort_by || "popularity.desc",
    "vote_average.gte": criteria.vote_min || 6.0,
    "vote_count.gte": 100,
  };

  if (criteria.genres.length > 0) {
    query.with_genres = criteria.genres.join(",");
  }

  if (criteria.year_min) {
    query["primary_release_date.gte"] = `${criteria.year_min}-01-01`;
  }

  if (criteria.year_max) {
    query["primary_release_date.lte"] = `${criteria.year_max}-12-31`;
  }

  const path = criteria.content_type === "tv" ? "discover/tv" : "discover/movie";
  const data = await callTmdbProxy(path, query) as { results: TMDBMovie[] };

  return data.results || [];
}

async function getTrending(contentType: "movie" | "tv"): Promise<TMDBMovie[]> {
  const data = await callTmdbProxy(`trending/${contentType}/week`) as { results: TMDBMovie[] };
  return data.results || [];
}

// =====================================================
// AI: Generar criterios de busqueda
// =====================================================

// Mapa de IDs de genero TMDB a nombres para el prompt
const GENRE_ID_TO_NAME: Record<number, string> = {
  28: "Accion",
  12: "Aventura",
  16: "Animacion",
  35: "Comedia",
  80: "Crimen",
  99: "Documental",
  18: "Drama",
  10751: "Familia",
  14: "Fantasia",
  36: "Historia",
  27: "Terror",
  10402: "Musica",
  9648: "Misterio",
  10749: "Romance",
  878: "Ciencia Ficcion",
  53: "Thriller",
  10752: "Guerra",
  37: "Western",
};

async function generateSearchCriteria(
  history: UserHistory,
  timeOfDay: string,
  pickCount: number,
  storyMode: boolean = false
): Promise<SearchCriteria[]> {
  // Generar un seed aleatorio para forzar variabilidad en cada request
  const randomSeed = Math.floor(Math.random() * 10000);

  // Preparar contexto del usuario
  const topRatedIds = history.ratings
    .filter(r => r.rating >= 7)
    .map(r => `${r.content_type}:${r.tmdb_id}`)
    .slice(0, 10);

  const favoriteIds = history.favorites
    .map(f => `${f.content_type}:${f.tmdb_id}`)
    .slice(0, 10);

  const hasHistory = topRatedIds.length > 0 || favoriteIds.length > 0;

  // Verificar preferencias del onboarding
  const prefs = history.preferences;
  const hasPreferences = prefs && (prefs.preferred_genres.length > 0 || (prefs.mood_text && prefs.mood_text.length > 0));


  // Determinar idioma para las razones
  const isEnglish = globalLanguage.startsWith("en");
  const reasonLanguage = isEnglish ? "English" : "Spanish (español)";

  const storyModeInstruction = storyMode
    ? `\n6. STORY MODE: The "reason" field must be a SHORT HOOK (20-50 chars max), punchy, catchy, like a headline. Optional emoji at start. Examples: "🔥 Tu próximo favorito", "Mind-bending thriller", "🎬 Imperdible este año"\n7. IMPORTANT: Set vote_min >= 7.0 to prioritize quality content for stories`
    : "";

  const systemPrompt = `You are an expert film and series curator. Your task is to generate SEARCH CRITERIA for TMDB, NOT specific titles.

STRICT RULES:
1. Return EXACTLY ${pickCount} different search criteria
2. Each criterion must generate DIFFERENT results (vary genres, years, etc.)
3. Genres must be numeric TMDB IDs
4. Valid JSON format, no additional text
5. The "reason" field must be personalized and in ${reasonLanguage}${storyModeInstruction}

AVAILABLE TMDB GENRES (use these IDs):
- Movies: 28(Action), 12(Adventure), 16(Animation), 35(Comedy), 80(Crime), 99(Documentary), 18(Drama), 10751(Family), 14(Fantasy), 36(History), 27(Horror), 10402(Music), 9648(Mystery), 10749(Romance), 878(Sci-Fi), 53(Thriller), 10752(War), 37(Western)
- TV: 10759(Action & Adventure), 16(Animation), 35(Comedy), 80(Crime), 99(Documentary), 18(Drama), 10751(Family), 10762(Kids), 9648(Mystery), 10763(News), 10764(Reality), 10765(Sci-Fi & Fantasy), 10766(Soap), 10767(Talk), 10768(War & Politics), 37(Western)

RESPONSE FORMAT (JSON array):
[
  {
    "genres": [28, 878],
    "year_min": 2020,
    "year_max": 2026,
    "vote_min": 7.0,
    "content_type": "movie",
    "sort_by": "popularity.desc",
    "reason": "${storyMode ? (isEnglish ? "🔥 Your next obsession" : "🔥 Tu próxima obsesión") : (isEnglish ? "Because you love action movies with impressive visual effects" : "Porque te gustan las películas de acción con efectos visuales impresionantes")}"
  }
]

Options for sort_by: popularity.desc, vote_average.desc, primary_release_date.desc, revenue.desc`;

  let userPrompt: string;

  // Caso A: Usuario con preferencias del onboarding
  if (hasPreferences && prefs) {
    const genreNames = prefs.preferred_genres
      .map(id => GENRE_ID_TO_NAME[id] || `ID:${id}`)
      .join(", ");

    const moodInfo = prefs.mood_text ? `\n- Mood/preferencia: "${prefs.mood_text}"` : "";

    userPrompt = `USER PREFERENCES (from onboarding):
- Favorite genres: ${genreNames} (IDs: ${prefs.preferred_genres.join(", ")})${moodInfo}

VIEWING HISTORY:
- Favorites: ${favoriteIds.length > 0 ? favoriteIds.join(", ") : "none yet"}
- Top rated: ${topRatedIds.length > 0 ? topRatedIds.join(", ") : "none yet"}
- Total watched: ${history.watched.length}

TIME OF DAY: ${timeOfDay}

Generate ${pickCount} PERSONALIZED search criteria based on:
1. Use their favorite genres in at least ${Math.ceil(pickCount * 0.6)} criteria
2. If there's a mood/preference, adapt the reasons to that mood
3. Include some discovery suggestion (related but new genre)
4. Reasons must mention "${isEnglish ? "Based on your taste" : "Basado en tus gustos"}" or similar
5. Write all "reason" fields in ${reasonLanguage}

IMPORTANT: Generate DIFFERENT recommendations than before. Variation seed: ${randomSeed}`;
  }
  // Caso B: Usuario con historial pero sin preferencias
  else if (hasHistory) {
    userPrompt = `USER CONTEXT (no onboarding preferences, only history):
- Favorites (content_type:tmdb_id): ${favoriteIds.join(", ") || "none"}
- Top rated: ${topRatedIds.join(", ") || "none"}
- Total watched: ${history.watched.length}

TIME OF DAY: ${timeOfDay}

Generate ${pickCount} VARIED search criteria for personalized recommendations.
- One can be based on their favorites
- Another can be a new discovery
- Vary between movies and series if they have history of both
- Write all "reason" fields in ${reasonLanguage}

IMPORTANT: Generate DIFFERENT recommendations than before. Variation seed: ${randomSeed}`;
  }
  // Caso C: Usuario nuevo sin preferencias ni historial (cold start)
  else {
    userPrompt = `NEW USER (cold start - no history or preferences)

TIME OF DAY: ${timeOfDay}

Generate ${pickCount} VARIED search criteria for a new user:
- Mix of recent popular movies and acclaimed series
- Include different popular genres to explore their tastes
- Prioritize content with good ratings (vote_min >= 7)
- Reasons should be generic: "${isEnglish ? "Trending this week" : "Trending esta semana"}", "${isEnglish ? "Popular among users" : "Popular entre usuarios"}", etc.
- Write all "reason" fields in ${reasonLanguage}

IMPORTANT: Generate DIFFERENT recommendations than before. Variation seed: ${randomSeed}`;
  }

  // Intentar con OpenAI primero, luego Claude como fallback
  let aiResponse: SearchCriteria[];

  if (OPENAI_API_KEY) {
    aiResponse = await callOpenAI(systemPrompt, userPrompt);
  } else if (ANTHROPIC_API_KEY) {
    aiResponse = await callClaude(systemPrompt, userPrompt);
  } else {
    throw new Error("No AI API key configured");
  }

  return aiResponse;
}

async function callClaude(systemPrompt: string, userPrompt: string): Promise<SearchCriteria[]> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_API_KEY!,
      "anthropic-version": "2023-06-01",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-3-haiku-20240307",
      max_tokens: 1024,
      temperature: 0.9, // Alta variabilidad para picks diferentes cada vez
      messages: [
        { role: "user", content: `${systemPrompt}\n\n${userPrompt}` }
      ],
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    console.error("Claude error:", error);
    throw new Error("Claude API error");
  }

  const data = await response.json();
  const content = data.content?.[0]?.text || "[]";

  return parseAIResponse(content);
}

async function callOpenAI(systemPrompt: string, userPrompt: string): Promise<SearchCriteria[]> {
  const response = await fetch("https://api.openai.com/v1/chat/completions", {
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
      temperature: 0.9,
      max_tokens: 1024,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    console.error("OpenAI error:", error);
    throw new Error(`OpenAI API error: ${response.status} - ${error.substring(0, 200)}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || "[]";

  return parseAIResponse(content);
}

function parseAIResponse(content: string): SearchCriteria[] {
  try {
    const cleanContent = content
      .replace(/```json\n?/g, "")
      .replace(/```\n?/g, "")
      .trim();

    const parsed = JSON.parse(cleanContent);

    // Validar estructura
    if (!Array.isArray(parsed)) {
      throw new Error("Response is not an array");
    }

    return parsed.map(item => ({
      genres: Array.isArray(item.genres) ? item.genres.filter((g: unknown) => typeof g === "number") : [],
      year_min: typeof item.year_min === "number" ? item.year_min : undefined,
      year_max: typeof item.year_max === "number" ? item.year_max : undefined,
      vote_min: typeof item.vote_min === "number" ? item.vote_min : 6.0,
      content_type: item.content_type === "tv" ? "tv" : "movie",
      sort_by: typeof item.sort_by === "string" ? item.sort_by : "popularity.desc",
      reason: typeof item.reason === "string" ? item.reason : (globalLanguage.startsWith("en") ? "Recommended for you" : "Recomendado para ti"),
    }));
  } catch (e) {
    console.error("Error parsing AI response:", content, e);
    throw new Error("Failed to parse AI response");
  }
}

// =====================================================
// FALLBACK: Trending si IA falla
// =====================================================

async function getFallbackPicks(pickCount: number): Promise<AIPick[]> {

  const [movies, tvShows] = await Promise.all([
    getTrending("movie"),
    getTrending("tv"),
  ]);

  const isEnglish = globalLanguage.startsWith("en");
  const fallbackReasons = isEnglish ? [
    "Trending this week",
    "Popular among users",
    "Highly rated",
    "Featured right now",
    "Popular recommendation",
  ] : [
    "Trending esta semana",
    "Popular entre los usuarios",
    "Muy bien valorada",
    "Destacada del momento",
    "Recomendación popular",
  ];

  const picks: AIPick[] = [];

  // Alternar entre peliculas y series
  for (let i = 0; i < pickCount; i++) {
    const isMovie = i % 2 === 0;
    const source = isMovie ? movies : tvShows;
    const index = Math.floor(i / 2);

    if (source[index]) {
      const item = source[index];
      picks.push({
        tmdb_id: item.id,
        title: item.title || item.name || "Sin titulo",
        poster_path: item.poster_path,
        backdrop_path: item.backdrop_path,
        overview: item.overview,
        vote_average: item.vote_average,
        release_date: item.release_date || item.first_air_date || null,
        content_type: isMovie ? "movie" : "tv",
        genre_ids: item.genre_ids || [],
        reason: fallbackReasons[i % fallbackReasons.length],
      });
    }
  }

  return picks;
}

// =====================================================
// MAIN: Generar picks con IA
// =====================================================

async function generateAIPicks(
  history: UserHistory,
  pickCount: number,
  storyMode: boolean = false
): Promise<AIPick[]> {
  // Determinar momento del dia
  const hour = new Date().getHours();
  let timeOfDay: string;
  if (hour >= 6 && hour < 12) timeOfDay = "manana";
  else if (hour >= 12 && hour < 18) timeOfDay = "tarde";
  else if (hour >= 18 && hour < 22) timeOfDay = "noche (prime time)";
  else timeOfDay = "madrugada";

  // 1. Generar criterios con IA
  const criteria = await generateSearchCriteria(history, timeOfDay, pickCount, storyMode);

  // 2. Para cada criterio, buscar en TMDB
  const picks: AIPick[] = [];
  const usedIds = new Set<string>(); // Evitar duplicados

  // Agregar historial a IDs usados
  [...history.favorites, ...history.watched].forEach(item => {
    usedIds.add(`${item.content_type}:${item.tmdb_id}`);
  });

  for (const criterion of criteria) {
    if (picks.length >= pickCount) break;

    try {
      const results = await discoverMovies(criterion);

      // Filtrar resultados que no estan en historial
      const availableResults = results.filter(result => {
        const key = `${criterion.content_type}:${result.id}`;
        if (usedIds.has(key)) return false;
        // En story mode, filtrar sin backdrop_path
        if (storyMode && !result.backdrop_path) return false;
        return true;
      });

      if (availableResults.length > 0) {
        // Seleccionar aleatoriamente de los primeros 10 resultados disponibles
        const poolSize = Math.min(10, availableResults.length);
        const randomIndex = Math.floor(Math.random() * poolSize);
        const result = availableResults[randomIndex];

        const key = `${criterion.content_type}:${result.id}`;
        usedIds.add(key);

        picks.push({
          tmdb_id: result.id,
          title: result.title || result.name || "Sin titulo",
          poster_path: result.poster_path,
          backdrop_path: result.backdrop_path,
          overview: result.overview,
          vote_average: result.vote_average,
          release_date: result.release_date || result.first_air_date || null,
          content_type: criterion.content_type,
          genre_ids: result.genre_ids || [],
          reason: criterion.reason,
        });
      }
    } catch (e) {
      console.error("Error discovering for criterion:", criterion, e);
    }
  }

  return picks;
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
    return jsonResponse({ error: "Metodo no permitido", code: "METHOD_NOT_ALLOWED" }, 405);
  }

  try {
    // 1. Validar usuario (opcional para usuarios nuevos)
    const user = await validateUser(req);

    // 2. Parsear body
    let body: { pick_count?: number; language?: string; region?: string; story_mode?: boolean } = {};
    try {
      body = await req.json();
    } catch {
      // Body vacio es OK
    }

    const storyMode = body.story_mode === true;
    const maxPicks = storyMode ? 15 : 10;
    const defaultPicks = storyMode ? 12 : 5;
    const pickCount = Math.min(Math.max(body.pick_count || defaultPicks, 1), maxPicks);

    // Configurar language/region global para las llamadas TMDB
    globalLanguage = body.language || "es-ES";
    globalRegion = body.region || "ES";

    // 3. Obtener historial si hay usuario
    let history: UserHistory = { favorites: [], watched: [], ratings: [], preferences: null };

    if (user) {
      history = await getUserHistory(user.userId);
    }

    // 4. Generar picks con IA (con fallback)
    let picks: AIPick[];
    let source: "ai" | "fallback";

    let aiError: string | null = null;
    try {
      if (!ANTHROPIC_API_KEY && !OPENAI_API_KEY) {
        throw new Error("No AI API key configured");
      }

      picks = await generateAIPicks(history, pickCount, storyMode);
      source = "ai";

      // Si IA no devolvio suficientes, complementar con fallback
      if (picks.length < pickCount) {
        const fallback = await getFallbackPicks(pickCount - picks.length);
        picks = [...picks, ...fallback];
      }
    } catch (e) {
      console.error("AI failed, using fallback:", e);
      aiError = e instanceof Error ? e.message : String(e);
      picks = await getFallbackPicks(pickCount);
      source = "fallback";
    }

    // 5. Responder
    const hasPreferences = !!(history.preferences?.preferred_genres?.length || history.preferences?.mood_text);

    return jsonResponse({
      success: true,
      source,
      picks,
      meta: {
        user_authenticated: !!user,
        has_preferences: hasPreferences,
        has_history: history.favorites.length + history.watched.length > 0,
        history_size: history.favorites.length + history.watched.length,
        generated_at: new Date().toISOString(),
        ai_error: aiError,
      },
    }, 200);

  } catch (error) {
    console.error("Error en ai-home-picks:", error);

    // Fallback final: trending
    try {
      const fallbackPicks = await getFallbackPicks(5);
      return jsonResponse({
        success: true,
        source: "fallback",
        picks: fallbackPicks,
        meta: {
          user_authenticated: false,
          history_size: 0,
          generated_at: new Date().toISOString(),
          error: "Fallback due to error",
        },
      }, 200);
    } catch {
      return jsonResponse({
        error: "Error interno",
        code: "INTERNAL_ERROR"
      }, 500);
    }
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
