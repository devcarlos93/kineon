// =====================================================
// AI MOVIE INSIGHT - Edge Function
// Genera insights personalizados para películas usando IA
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
import {
  checkRateLimit,
  recordUsage,
  rateLimitErrorResponse,
} from "../_shared/rate-limiter.ts";

// Configuración
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

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

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// TTL del caché: 7 días (el insight de una película no cambia)
const CACHE_TTL_SECONDS = 7 * 24 * 60 * 60;

// =====================================================
// TIPOS
// =====================================================
interface RequestBody {
  tmdb_id: number;
  content_type: "movie" | "tv";
  title: string;
  overview: string;
  genres: string[];
  vote_average: number;
  runtime?: number;
  release_year?: number;
  director?: string;
  user_id?: string; // Opcional para personalización futura
}

interface AiInsight {
  bullets: string[];
  tags: string[];
  match_score?: number; // 0-100, opcional para personalización futura
}

// =====================================================
// CACHE FUNCTIONS
// =====================================================

function getCacheKey(tmdbId: number, contentType: string): string {
  return `ai_insight:${contentType}:${tmdbId}`;
}

async function getFromCache(key: string): Promise<AiInsight | null> {
  try {
    const { data, error } = await supabase
      .from("tmdb_cache")
      .select("data, expires_at")
      .eq("key", key)
      .single();

    if (error || !data) return null;

    const now = new Date();
    const expiresAt = new Date(data.expires_at);

    if (expiresAt <= now) return null;

    // Incrementar hit_count
    supabase
      .from("tmdb_cache")
      .update({ hit_count: (data as { hit_count?: number }).hit_count ?? 0 + 1 })
      .eq("key", key)
      .then(() => {});

    return data.data as AiInsight;
  } catch {
    return null;
  }
}

async function saveToCache(key: string, data: AiInsight): Promise<void> {
  try {
    const expiresAt = new Date(Date.now() + CACHE_TTL_SECONDS * 1000).toISOString();

    await supabase
      .from("tmdb_cache")
      .upsert({
        key,
        data,
        expires_at: expiresAt,
        hit_count: 0,
      }, {
        onConflict: "key",
      });
  } catch (err) {
    console.error("Cache write error:", err);
  }
}

// =====================================================
// AI GENERATION
// =====================================================

function buildPrompt(movie: RequestBody): string {
  const genresText = movie.genres.join(", ");
  const runtimeText = movie.runtime ? `${Math.floor(movie.runtime / 60)}h ${movie.runtime % 60}m` : "desconocida";

  return `Analiza la siguiente película/serie y genera insights útiles para el espectador:

TÍTULO: ${movie.title}
AÑO: ${movie.release_year || "desconocido"}
GÉNEROS: ${genresText}
DURACIÓN: ${runtimeText}
CALIFICACIÓN: ${movie.vote_average.toFixed(1)}/10
${movie.director ? `DIRECTOR: ${movie.director}` : ""}

SINOPSIS:
${movie.overview || "Sin sinopsis disponible."}

Genera exactamente 3 insights cortos y útiles que ayuden al espectador a decidir si ver esta película. Los insights deben ser:
- Objetivos y basados en los datos proporcionados
- Útiles para tomar una decisión
- Escritos en español
- Máximo 80 caracteres cada uno
- Sin emojis

También genera 3 tags descriptivos en MAYÚSCULAS que capturen la esencia de la película (ej: MIND-BENDING, FAMILIAR, INTENSA, SLOW-BURN, etc).

Responde ÚNICAMENTE con JSON válido en este formato exacto:
{
  "bullets": ["insight 1", "insight 2", "insight 3"],
  "tags": ["TAG1", "TAG2", "TAG3"]
}`;
}

async function generateInsight(movie: RequestBody): Promise<AiInsight> {
  const prompt = buildPrompt(movie);

  const response = await fetch("https://api.openai.com/v1/chat/completions", {
    method: "POST",
    headers: {
      Authorization: `Bearer ${OPENAI_API_KEY}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "gpt-4o-mini",
      messages: [
        {
          role: "system",
          content: `Eres un crítico de cine conciso que ayuda a los usuarios a decidir qué ver.
Siempre respondes con JSON válido. Eres objetivo y preciso.`,
        },
        { role: "user", content: prompt },
      ],
      temperature: 0.7,
      max_tokens: 300,
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(`OpenAI error ${response.status}: ${errorText}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || "{}";

  try {
    // Limpiar el contenido por si viene con markdown
    const cleanContent = content.replace(/```json\n?/g, "").replace(/```\n?/g, "").trim();
    const parsed = JSON.parse(cleanContent);

    return {
      bullets: parsed.bullets || [],
      tags: parsed.tags || [],
    };
  } catch (parseError) {
    console.error("Error parsing AI response:", content, parseError);
    // Fallback con datos básicos
    return {
      bullets: [
        `Calificación ${movie.vote_average.toFixed(1)}/10 por la audiencia.`,
        movie.genres.length > 0 ? `Género: ${movie.genres.slice(0, 2).join(" y ")}.` : "Género variado.",
        movie.runtime ? `Duración: ${Math.floor(movie.runtime / 60)}h ${movie.runtime % 60}m.` : "Duración estándar.",
      ],
      tags: movie.genres.slice(0, 3).map(g => g.toUpperCase()),
    };
  }
}

// =====================================================
// HANDLER PRINCIPAL
// =====================================================
serve(async (req: Request): Promise<Response> => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    if (!OPENAI_API_KEY) {
      throw new Error("OPENAI_API_KEY no configurada");
    }

    const body: RequestBody = await req.json();

    // Validación básica
    if (!body.tmdb_id || !body.content_type || !body.title) {
      return new Response(
        JSON.stringify({ error: "Campos requeridos: tmdb_id, content_type, title" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // ═══════════════════════════════════════════════════════════════════
    // RATE LIMITING (solo si hay user_id, sino permitir sin tracking)
    // ═══════════════════════════════════════════════════════════════════
    const userId = getUserIdFromRequest(req) || body.user_id;

    if (userId) {
      const rateCheck = await checkRateLimit(supabase, userId, "ai-movie-insight");

      if (!rateCheck.allowed) {
        return rateLimitErrorResponse(rateCheck, "es");
      }
    }

    // Buscar en caché
    const cacheKey = getCacheKey(body.tmdb_id, body.content_type);
    const cached = await getFromCache(cacheKey);

    if (cached) {
      console.log(`AI Insight Cache HIT: ${cacheKey}`);
      return new Response(JSON.stringify(cached), {
        status: 200,
        headers: { ...corsHeaders, "Content-Type": "application/json", "X-Cache": "HIT" },
      });
    }

    console.log(`AI Insight Cache MISS: ${cacheKey}, generating...`);

    // Generar insight con IA
    const insight = await generateInsight(body);

    // Registrar uso para rate limiting (solo cuando se genera, no desde caché)
    if (userId) {
      await recordUsage(supabase, userId, "ai-movie-insight", 300); // ~300 tokens promedio
    }

    // Guardar en caché (background)
    saveToCache(cacheKey, insight).catch((err) => {
      console.error("Failed to save AI insight to cache:", err);
    });

    return new Response(JSON.stringify(insight), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json", "X-Cache": "MISS" },
    });

  } catch (error) {
    console.error("Error en ai-movie-insight:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Error desconocido",
        bullets: [],
        tags: [],
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
