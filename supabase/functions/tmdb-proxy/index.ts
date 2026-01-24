// =====================================================
// TMDB PROXY - Edge Function (Con Cache)
// Proxy seguro para TMDB API con caché en Supabase
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Configuración
const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const TMDB_BEARER_TOKEN = Deno.env.get("TMDB_BEARER_TOKEN");
const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

// Cliente Supabase (service_role para acceder a tmdb_cache)
const supabase = createClient(SUPABASE_URL!, SUPABASE_SERVICE_ROLE_KEY!);

// CORS Headers
const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// =====================================================
// CACHE - TTL Configuration (en segundos)
// =====================================================
const TTL_CONFIG: { pattern: RegExp; ttl: number }[] = [
  // NO CACHEAR: search (demasiado variable)
  { pattern: /^search\//, ttl: 0 },

  // 7 días: listas de géneros (casi nunca cambian)
  { pattern: /^genre\/(movie|tv)\/list$/, ttl: 7 * 24 * 60 * 60 },

  // 24 horas: configuración y detalles de contenido
  { pattern: /^configuration$/, ttl: 24 * 60 * 60 },
  { pattern: /^movie\/\d+$/, ttl: 24 * 60 * 60 },
  { pattern: /^tv\/\d+$/, ttl: 24 * 60 * 60 },
  { pattern: /^person\/\d+/, ttl: 24 * 60 * 60 },
  { pattern: /^collection\/\d+$/, ttl: 24 * 60 * 60 },

  // 12 horas: detalles extras (credits, videos, etc.)
  { pattern: /^movie\/\d+\//, ttl: 12 * 60 * 60 },
  { pattern: /^tv\/\d+\//, ttl: 12 * 60 * 60 },
  { pattern: /^(movie|tv)\/top_rated$/, ttl: 12 * 60 * 60 },

  // 6 horas: populares y proveedores
  { pattern: /^(movie|tv)\/popular$/, ttl: 6 * 60 * 60 },
  { pattern: /^watch\/providers\//, ttl: 6 * 60 * 60 },

  // 4 horas: discover y estrenos
  { pattern: /^discover\//, ttl: 4 * 60 * 60 },
  { pattern: /^movie\/now_playing$/, ttl: 4 * 60 * 60 },
  { pattern: /^movie\/upcoming$/, ttl: 4 * 60 * 60 },
  { pattern: /^tv\/on_the_air$/, ttl: 4 * 60 * 60 },
  { pattern: /^tv\/airing_today$/, ttl: 4 * 60 * 60 },

  // 2 horas: trending (cambia frecuentemente)
  { pattern: /^trending\//, ttl: 2 * 60 * 60 },
];

// TTL por defecto: 4 horas
const DEFAULT_TTL = 4 * 60 * 60;

// =====================================================
// CACHE - Helper Functions
// =====================================================

/**
 * Genera una clave de caché única basada en path + query params ordenados
 */
function getCacheKey(path: string, query?: Record<string, string | number | boolean | undefined>): string {
  const cleanPath = path.replace(/^\/+/, "").replace(/\/+$/, "");

  if (!query || Object.keys(query).length === 0) {
    return cleanPath;
  }

  // Ordenar query params alfabéticamente para consistencia
  const sortedParams = Object.entries(query)
    .filter(([_, v]) => v !== undefined && v !== null && v !== "")
    .sort(([a], [b]) => a.localeCompare(b))
    .map(([k, v]) => `${k}=${v}`)
    .join("&");

  return sortedParams ? `${cleanPath}?${sortedParams}` : cleanPath;
}

/**
 * Obtiene el TTL apropiado según el endpoint
 */
function getTTL(path: string): number {
  const cleanPath = path.replace(/^\/+/, "").replace(/\/+$/, "");

  for (const config of TTL_CONFIG) {
    if (config.pattern.test(cleanPath)) {
      return config.ttl;
    }
  }

  return DEFAULT_TTL;
}

/**
 * Determina si el endpoint debe ser cacheado
 */
function shouldCache(path: string, query?: Record<string, string | number | boolean | undefined>): boolean {
  const ttl = getTTL(path);
  if (ttl === 0) return false;

  // Opcional: no cachear páginas > 1 (menos beneficio, más storage)
  // Comentado porque puede ser útil cachear paginación popular
  // if (query?.page && Number(query.page) > 1) return false;

  return true;
}

/**
 * Busca datos en el caché
 */
async function getFromCache(key: string): Promise<{ data: unknown; hit: boolean } | null> {
  try {
    const { data, error } = await supabase
      .from("tmdb_cache")
      .select("data, expires_at, hit_count")
      .eq("key", key)
      .single();

    if (error || !data) return null;

    const now = new Date();
    const expiresAt = new Date(data.expires_at);

    // Cache expirado
    if (expiresAt <= now) {
      return null;
    }

    // Incrementar hit_count (fire and forget)
    supabase
      .from("tmdb_cache")
      .update({ hit_count: data.hit_count + 1 })
      .eq("key", key)
      .then(() => {});

    return { data: data.data, hit: true };
  } catch (err) {
    console.error("Cache read error:", err);
    return null;
  }
}

/**
 * Guarda datos en el caché
 */
async function saveToCache(key: string, data: unknown, ttlSeconds: number): Promise<void> {
  try {
    const expiresAt = new Date(Date.now() + ttlSeconds * 1000).toISOString();

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
    // No fallar si el caché falla, solo loguear
    console.error("Cache write error:", err);
  }
}

// =====================================================
// WHITELIST DE RUTAS PERMITIDAS
// =====================================================
const ALLOWED_ROUTES: RegExp[] = [
  /^trending\/(movie|tv|all)\/(day|week)$/,
  /^(movie|tv)\/popular$/,
  /^(movie|tv)\/top_rated$/,
  /^movie\/upcoming$/,
  /^movie\/now_playing$/,
  /^tv\/on_the_air$/,
  /^tv\/airing_today$/,
  /^movie\/\d+$/,
  /^tv\/\d+$/,
  /^person\/\d+$/,
  /^movie\/\d+\/(credits|videos|images|recommendations|similar|reviews|watch\/providers)$/,
  /^tv\/\d+\/(credits|videos|images|recommendations|similar|reviews|watch\/providers|season\/\d+)$/,
  /^person\/\d+\/(movie_credits|tv_credits|combined_credits|images)$/,
  /^search\/(movie|tv|multi|person|keyword|collection)$/,
  /^discover\/(movie|tv)$/,
  /^genre\/(movie|tv)\/list$/,
  /^configuration$/,
  /^watch\/providers\/(movie|tv)$/,
  /^collection\/\d+$/,
];

// =====================================================
// TIPOS
// =====================================================
interface RequestBody {
  path: string;
  query?: Record<string, string | number | boolean | undefined>;
  language?: string;  // IETF BCP 47: es-MX, es-CO, en-US
  region?: string;    // ISO 3166-1 alpha-2: MX, CO, US
}

// =====================================================
// VALIDACIÓN
// =====================================================
function isValidPath(path: string): boolean {
  const cleanPath = path.replace(/^\/+/, "").replace(/\/+$/, "");
  return ALLOWED_ROUTES.some((pattern) => pattern.test(cleanPath));
}

// =====================================================
// HANDLER PRINCIPAL
// =====================================================
serve(async (req: Request): Promise<Response> => {
  // Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  // Solo aceptar POST
  if (req.method !== "POST") {
    return new Response(
      JSON.stringify({ error: "Método no permitido", code: "METHOD_NOT_ALLOWED" }),
      { status: 405, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }

  try {
    // Verificar token configurado
    if (!TMDB_BEARER_TOKEN) {
      console.error("TMDB_BEARER_TOKEN no configurado");
      return new Response(
        JSON.stringify({ error: "TMDB_BEARER_TOKEN no configurado", code: "CONFIG_ERROR" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Parsear body
    let body: RequestBody;
    try {
      body = await req.json();
    } catch {
      return new Response(
        JSON.stringify({ error: "JSON inválido", code: "INVALID_JSON" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const { path, query, language, region } = body;

    // Validar path
    if (!path || typeof path !== "string") {
      return new Response(
        JSON.stringify({ error: "Campo 'path' requerido", code: "MISSING_PATH" }),
        { status: 400, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    if (!isValidPath(path)) {
      return new Response(
        JSON.stringify({ error: `Ruta no permitida: ${path}`, code: "FORBIDDEN_PATH" }),
        { status: 403, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // =========================================
    // CACHE: Generar key y buscar en caché
    // =========================================
    const useCache = shouldCache(path, query);
    // Incluir language y region en cache key para separar por locale
    const cacheQuery = {
      ...query,
      _lang: language || "es-ES",
      _region: region,
    };
    const cacheKey = useCache ? getCacheKey(path, cacheQuery) : "";

    if (useCache) {
      const cached = await getFromCache(cacheKey);
      if (cached) {
        console.log(`Cache HIT: ${cacheKey}`);
        return new Response(JSON.stringify(cached.data), {
          status: 200,
          headers: {
            ...corsHeaders,
            "Content-Type": "application/json",
            "X-Cache": "HIT",
          },
        });
      }
      console.log(`Cache MISS: ${cacheKey}`);
    }

    // Construir URL para TMDB
    const url = new URL(`${TMDB_BASE_URL}/${path}`);

    // Usar language del request o default a es-ES
    const tmdbLanguage = language || "es-ES";
    url.searchParams.set("language", tmdbLanguage);

    // Usar region del request (para watch providers, discover, etc.)
    if (region) {
      url.searchParams.set("region", region);
      url.searchParams.set("watch_region", region); // Para watch providers
    }

    if (query) {
      for (const [key, value] of Object.entries(query)) {
        if (value !== undefined && value !== null && value !== "") {
          url.searchParams.set(key, String(value));
        }
      }
    }

    console.log(`TMDB Request: ${url.toString()}`);

    // Hacer request a TMDB
    const tmdbResponse = await fetch(url.toString(), {
      method: "GET",
      headers: {
        "Authorization": `Bearer ${TMDB_BEARER_TOKEN}`,
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
    });

    // Manejar errores de TMDB
    if (!tmdbResponse.ok) {
      const errorText = await tmdbResponse.text();
      console.error(`TMDB Error [${tmdbResponse.status}]: ${errorText}`);
      return new Response(
        JSON.stringify({
          error: "Error de TMDB",
          code: "TMDB_ERROR",
          status: tmdbResponse.status,
          details: errorText
        }),
        { status: tmdbResponse.status, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // Retornar respuesta de TMDB
    const data = await tmdbResponse.json();

    // =========================================
    // CACHE: Guardar en caché (si aplica)
    // =========================================
    if (useCache) {
      const ttl = getTTL(path);
      // Guardar en background (no bloquear respuesta)
      saveToCache(cacheKey, data, ttl).catch((err) => {
        console.error("Failed to save cache:", err);
      });
    }

    return new Response(JSON.stringify(data), {
      status: 200,
      headers: {
        ...corsHeaders,
        "Content-Type": "application/json",
        "X-Cache": useCache ? "MISS" : "BYPASS",
      },
    });

  } catch (error) {
    console.error("Error en tmdb-proxy:", error);
    return new Response(
      JSON.stringify({
        error: "Error interno",
        code: "INTERNAL_ERROR",
        details: error instanceof Error ? error.message : String(error)
      }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
