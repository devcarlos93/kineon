// =====================================================
// TMDB BULK - Edge Function
// Obtiene detalles de múltiples películas/series en paralelo
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const TMDB_BEARER_TOKEN = Deno.env.get("TMDB_BEARER_TOKEN");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// =====================================================
// TIPOS
// =====================================================

interface BulkRequest {
  ids: number[];
  content_type?: "movie" | "tv";
  language?: string;
  region?: string;  // ISO 3166-1 alpha-2: MX, CO, US, ES
}

interface BulkItem {
  id: number;
  title: string;
  poster_path: string | null;
  backdrop_path: string | null;
  vote_average: number;
  release_date: string | null;
  runtime: number | null;
  genres: { id: number; name: string }[];
  overview: string | null;
  error?: boolean;
}

// =====================================================
// CACHE (usa la misma tabla tmdb_cache)
// =====================================================

const CACHE_TTL = 24 * 60 * 60; // 24 horas

async function getFromCache(key: string): Promise<BulkItem | null> {
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

    return data.data as BulkItem;
  } catch {
    return null;
  }
}

async function saveToCache(key: string, data: BulkItem): Promise<void> {
  try {
    const expiresAt = new Date(Date.now() + CACHE_TTL * 1000).toISOString();
    await supabase.from("tmdb_cache").upsert(
      { key, data, expires_at: expiresAt, hit_count: 0 },
      { onConflict: "key" }
    );
  } catch {
    // Ignorar errores de cache
  }
}

// =====================================================
// POOL MAP - Concurrencia controlada
// =====================================================

async function poolMap<T, R>(
  items: T[],
  concurrency: number,
  fn: (item: T) => Promise<R>
): Promise<R[]> {
  const results: R[] = new Array(items.length);
  let idx = 0;

  const workers = Array.from({ length: concurrency }, async () => {
    while (idx < items.length) {
      const i = idx++;
      results[i] = await fn(items[i]);
    }
  });

  await Promise.all(workers);
  return results;
}

// =====================================================
// FETCH INDIVIDUAL
// =====================================================

async function fetchItem(
  id: number,
  contentType: "movie" | "tv",
  language: string
): Promise<BulkItem> {
  // Primero buscar en cache (incluir language en key)
  const cacheKey = `bulk:${contentType}:${id}:${language}`;
  const cached = await getFromCache(cacheKey);
  if (cached) {
    console.log(`Cache HIT: ${cacheKey}`);
    return cached;
  }

  console.log(`Cache MISS: ${cacheKey}, fetching from TMDB...`);

  try {
    const url = new URL(`${TMDB_BASE_URL}/${contentType}/${id}`);
    url.searchParams.set("language", language);

    const response = await fetch(url.toString(), {
      headers: { Authorization: `Bearer ${TMDB_BEARER_TOKEN}` },
    });

    if (!response.ok) {
      return { id, title: "", poster_path: null, backdrop_path: null, vote_average: 0, release_date: null, runtime: null, genres: [], overview: null, error: true };
    }

    const data = await response.json();

    const item: BulkItem = {
      id: data.id,
      title: data.title ?? data.name ?? "",
      poster_path: data.poster_path ?? null,
      backdrop_path: data.backdrop_path ?? null,
      vote_average: data.vote_average ?? 0,
      release_date: data.release_date ?? data.first_air_date ?? null,
      runtime: data.runtime ?? (data.episode_run_time?.[0] ?? null),
      genres: (data.genres ?? []).map((g: { id: number; name: string }) => ({
        id: g.id,
        name: g.name,
      })),
      overview: data.overview ?? null,
    };

    // Guardar en cache (fire and forget)
    saveToCache(cacheKey, item).catch(() => {});

    return item;
  } catch {
    return { id, title: "", poster_path: null, backdrop_path: null, vote_average: 0, release_date: null, runtime: null, genres: [], overview: null, error: true };
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
      JSON.stringify({ error: "Use POST" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    if (!TMDB_BEARER_TOKEN) {
      throw new Error("TMDB_BEARER_TOKEN no configurado");
    }

    const body: BulkRequest = await req.json();
    const ids = Array.isArray(body.ids)
      ? body.ids.map((x) => Number(x)).filter((x) => Number.isFinite(x))
      : [];
    const contentType = body.content_type ?? "movie";
    const language = body.language ?? "es-ES";

    // Limitar a 50 items máximo
    const limitedIds = [...new Set(ids)].slice(0, 50);

    if (limitedIds.length === 0) {
      return new Response(
        JSON.stringify({ items: [] }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    console.log(`Fetching ${limitedIds.length} ${contentType}s...`);

    // Fetch en paralelo con concurrencia de 8
    const items = await poolMap(limitedIds, 8, (id) =>
      fetchItem(id, contentType, language)
    );

    // Filtrar errores
    const validItems = items.filter((item) => !item.error);

    return new Response(
      JSON.stringify({ items: validItems }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Error en tmdb-bulk:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Error desconocido",
        items: [],
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
