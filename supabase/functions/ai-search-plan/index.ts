// =====================================================
// AI SEARCH PLAN - Intelligent Discovery
// Convierte búsqueda natural → filtros TMDB estructurados
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  checkRateLimit,
  recordUsage,
  rateLimitErrorResponse,
} from "../_shared/rate-limiter.ts";

const OPENAI_URL = "https://api.openai.com/v1/chat/completions";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

function json(data: unknown, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
}

// Extraer user ID del JWT en Authorization header
function getUserIdFromRequest(req: Request): string | null {
  const authHeader = req.headers.get("authorization");
  if (!authHeader?.startsWith("Bearer ")) return null;

  try {
    const token = authHeader.replace("Bearer ", "");
    const payload = JSON.parse(atob(token.split(".")[1]));
    return payload.sub || null;
  } catch {
    return null;
  }
}

// Catálogo de géneros TMDB (películas y series comparten la mayoría)
const GENRE_CATALOG = [
  { id: 28, name: "Action", name_es: "Acción" },
  { id: 12, name: "Adventure", name_es: "Aventura" },
  { id: 16, name: "Animation", name_es: "Animación" },
  { id: 35, name: "Comedy", name_es: "Comedia" },
  { id: 80, name: "Crime", name_es: "Crimen" },
  { id: 99, name: "Documentary", name_es: "Documental" },
  { id: 18, name: "Drama", name_es: "Drama" },
  { id: 10751, name: "Family", name_es: "Familia" },
  { id: 14, name: "Fantasy", name_es: "Fantasía" },
  { id: 36, name: "History", name_es: "Historia" },
  { id: 27, name: "Horror", name_es: "Terror" },
  { id: 10402, name: "Music", name_es: "Música" },
  { id: 9648, name: "Mystery", name_es: "Misterio" },
  { id: 10749, name: "Romance", name_es: "Romance" },
  { id: 878, name: "Science Fiction", name_es: "Ciencia Ficción" },
  { id: 10770, name: "TV Movie", name_es: "Película de TV" },
  { id: 53, name: "Thriller", name_es: "Thriller" },
  { id: 10752, name: "War", name_es: "Guerra" },
  { id: 37, name: "Western", name_es: "Western" },
  // TV específicos
  { id: 10759, name: "Action & Adventure", name_es: "Acción y Aventura" },
  { id: 10762, name: "Kids", name_es: "Infantil" },
  { id: 10763, name: "News", name_es: "Noticias" },
  { id: 10764, name: "Reality", name_es: "Reality" },
  { id: 10765, name: "Sci-Fi & Fantasy", name_es: "Sci-Fi y Fantasía" },
  { id: 10766, name: "Soap", name_es: "Telenovela" },
  { id: 10767, name: "Talk", name_es: "Talk Show" },
  { id: 10768, name: "War & Politics", name_es: "Guerra y Política" },
];

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return json({ error: "Use POST" }, 405);
    }

    const key = Deno.env.get("OPENAI_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!key) {
      return json({ error: "Missing OPENAI_API_KEY" }, 500);
    }

    const body = await req.json().catch(() => ({}));
    const queryText = String(body?.query ?? "").trim();

    if (!queryText) {
      return json({ error: "Query is required" }, 400);
    }

    // Parámetros opcionales
    const selectedGenreIds: number[] = Array.isArray(body?.selected_genre_ids)
      ? body.selected_genre_ids.map((x: number) => Number(x)).filter((n: number) => Number.isFinite(n))
      : [];
    const moodChip = String(body?.mood_chip ?? "").trim();
    const mediaType = body?.media_type === "tv" ? "tv" : "movie"; // default movie
    const language = String(body?.language ?? "es-ES");
    const region = String(body?.region ?? "ES");

    // ═══════════════════════════════════════════════════════════════════
    // RATE LIMITING
    // ═══════════════════════════════════════════════════════════════════
    const userId = getUserIdFromRequest(req);
    let supabase: ReturnType<typeof createClient> | null = null;

    if (userId && supabaseUrl && supabaseServiceKey) {
      supabase = createClient(supabaseUrl, supabaseServiceKey);
      const rateCheck = await checkRateLimit(supabase, userId, "ai-search-plan");

      if (!rateCheck.allowed) {
        return rateLimitErrorResponse(rateCheck, language);
      }
    }

    const isEnglish = language.startsWith("en");
    const outputLanguage = isEnglish ? "English" : "Spanish";

    const systemPrompt = `
You are Kineon Intelligent Search - a movie/TV discovery assistant.
Your task: convert natural language queries into TMDB discover API filters.

IMPORTANT RULES:
1. Return ONLY valid JSON, no explanations
2. Use ONLY genre IDs from the provided catalog
3. All text outputs (intent_summary, tags, ui labels) must be in ${outputLanguage}
4. Be conservative with filters - better to show more results than none
5. Consider media_type: "${mediaType}" (movie or tv)

GENRE CATALOG (use these IDs only):
${JSON.stringify(GENRE_CATALOG.map(g => ({ id: g.id, name: g.name_es })))}

USER CONTEXT:
- Selected genre IDs (override if provided): ${JSON.stringify(selectedGenreIds)}
- Mood chip (if any): "${moodChip}"
- Region: ${region}
- Language: ${language}

OUTPUT JSON SCHEMA:
{
  "plan_version": 1,
  "intent_summary": "string (max 80 chars, in ${outputLanguage}, describes what user wants)",
  "media_type": "movie" | "tv",
  "discover": {
    "with_genres": [number array of genre IDs],
    "without_genres": [number array to exclude, optional],
    "vote_average_gte": number (6.0-8.0 range typically),
    "vote_count_gte": number (50-500, higher for popular requests),
    "with_runtime_gte": number | null (minutes, for movies only),
    "with_runtime_lte": number | null (minutes, for movies only),
    "primary_release_date_gte": "YYYY-MM-DD" | null,
    "primary_release_date_lte": "YYYY-MM-DD" | null,
    "sort_by": "popularity.desc" | "vote_average.desc" | "primary_release_date.desc"
  },
  "tags": ["string array of 2-4 descriptive tags in ${outputLanguage}"],
  "ui": {
    "mood_label": "string in ${outputLanguage} (e.g., '${isEnglish ? "Intense" : "Intenso"}', '${isEnglish ? "Relaxing" : "Relajante"}', '${isEnglish ? "Emotional" : "Emotivo"}')",
    "runtime_label": "string | null (e.g., '< 2h', '> 2h')",
    "year_label": "string | null (e.g., '2020+', 'Clásicos')",
    "genre_label": "string (main genre name in Spanish)"
  },
  "confidence": number (0.0-1.0, how confident you are in understanding the query)
}

EXAMPLES:
- "algo como Interstellar pero más corto" → sci-fi, runtime_lte: 120, vote_average_gte: 7.0
- "comedia romántica para ver con mi pareja" → romance + comedy, vote_average_gte: 6.5
- "serie de terror psicológico" → media_type: tv, horror + thriller
- "película de los 80s de acción" → action, year 1980-1989
- "algo relajante para el domingo" → comedy/family/animation, vote_average_gte: 6.0
`;

    const userMessage = JSON.stringify({
      query: queryText,
      selected_genre_ids: selectedGenreIds,
      mood_chip: moodChip,
      media_type: mediaType,
      region,
      language,
    });

    const model = Deno.env.get("AI_MODEL") ?? "gpt-4o-mini";

    const response = await fetch(OPENAI_URL, {
      method: "POST",
      headers: {
        "Authorization": `Bearer ${key}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages: [
          { role: "system", content: systemPrompt },
          { role: "user", content: userMessage },
        ],
        response_format: { type: "json_object" },
        max_tokens: 500,
        temperature: 0.3,
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("OpenAI error:", errorText);
      return json({ error: "AI service error", details: errorText }, 502);
    }

    const data = await response.json();
    const content = data?.choices?.[0]?.message?.content;

    if (!content) {
      return json({ error: "No response from AI" }, 502);
    }

    const plan = JSON.parse(content);

    // Validar y sanitizar el plan
    const sanitizedPlan = {
      plan_version: 1,
      intent_summary: String(plan.intent_summary ?? "Búsqueda personalizada").slice(0, 100),
      media_type: plan.media_type === "tv" ? "tv" : "movie",
      discover: {
        with_genres: Array.isArray(plan.discover?.with_genres)
          ? plan.discover.with_genres.filter((id: number) => GENRE_CATALOG.some(g => g.id === id))
          : [],
        without_genres: Array.isArray(plan.discover?.without_genres)
          ? plan.discover.without_genres.filter((id: number) => GENRE_CATALOG.some(g => g.id === id))
          : [],
        vote_average_gte: Math.min(Math.max(Number(plan.discover?.vote_average_gte) || 6.0, 0), 10),
        vote_count_gte: Math.min(Math.max(Number(plan.discover?.vote_count_gte) || 100, 0), 10000),
        with_runtime_gte: plan.discover?.with_runtime_gte ? Number(plan.discover.with_runtime_gte) : null,
        with_runtime_lte: plan.discover?.with_runtime_lte ? Number(plan.discover.with_runtime_lte) : null,
        primary_release_date_gte: plan.discover?.primary_release_date_gte ?? null,
        primary_release_date_lte: plan.discover?.primary_release_date_lte ?? null,
        sort_by: plan.discover?.sort_by ?? "popularity.desc",
      },
      tags: Array.isArray(plan.tags) ? plan.tags.slice(0, 4) : [],
      ui: {
        mood_label: plan.ui?.mood_label ?? null,
        runtime_label: plan.ui?.runtime_label ?? null,
        year_label: plan.ui?.year_label ?? null,
        genre_label: plan.ui?.genre_label ?? "Todos",
      },
      confidence: Math.min(Math.max(Number(plan.confidence) || 0.7, 0), 1),
    };

    // Registrar uso para rate limiting
    if (userId && supabase) {
      const tokensUsed = data?.usage?.total_tokens ?? 0;
      await recordUsage(supabase, userId, "ai-search-plan", tokensUsed);
    }

    return json(sanitizedPlan);

  } catch (e) {
    console.error("Error in ai-search-plan:", e);
    return json({ error: "Server error", details: String(e) }, 500);
  }
});
