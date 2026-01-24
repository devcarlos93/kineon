/**
 * Rate Limiter para Edge Functions de IA
 * Protege contra abuso y controla costos de OpenAI
 */

import { SupabaseClient } from "https://esm.sh/@supabase/supabase-js@2";

// Configuración por endpoint
export const RATE_LIMITS = {
  "ai-chat": {
    maxPerMinute: 10,
    maxPerHour: 50,
    minIntervalSeconds: 2,
  },
  "ai-search-plan": {
    maxPerMinute: 6,
    maxPerHour: 40,
    minIntervalSeconds: 3,
  },
  "ai-movie-insight": {
    maxPerMinute: 15,
    maxPerHour: 100,
    minIntervalSeconds: 1,
  },
} as const;

export type AiEndpoint = keyof typeof RATE_LIMITS;

export interface RateLimitResult {
  allowed: boolean;
  reason: "too_fast" | "minute_limit" | "hour_limit" | null;
  waitSeconds: number;
  requestsRemaining: number;
}

export interface RateLimitError {
  error: string;
  code: "RATE_LIMITED";
  waitSeconds: number;
  message: {
    es: string;
    en: string;
  };
}

/**
 * Verifica si el usuario puede hacer una request
 */
export async function checkRateLimit(
  supabase: SupabaseClient,
  userId: string,
  endpoint: AiEndpoint
): Promise<RateLimitResult> {
  const limits = RATE_LIMITS[endpoint];

  const { data, error } = await supabase.rpc("check_ai_rate_limit", {
    p_user_id: userId,
    p_endpoint: endpoint,
    p_max_per_minute: limits.maxPerMinute,
    p_max_per_hour: limits.maxPerHour,
    p_min_interval_seconds: limits.minIntervalSeconds,
  });

  if (error) {
    console.error("Rate limit check error:", error);
    // En caso de error, permitir (fail-open) pero loggear
    return {
      allowed: true,
      reason: null,
      waitSeconds: 0,
      requestsRemaining: -1,
    };
  }

  return {
    allowed: data.allowed,
    reason: data.reason,
    waitSeconds: data.wait_seconds,
    requestsRemaining: data.requests_remaining,
  };
}

/**
 * Registra el uso después de una request exitosa
 */
export async function recordUsage(
  supabase: SupabaseClient,
  userId: string,
  endpoint: AiEndpoint,
  tokensUsed: number = 0
): Promise<void> {
  const { error } = await supabase.rpc("record_ai_usage", {
    p_user_id: userId,
    p_endpoint: endpoint,
    p_tokens_used: tokensUsed,
  });

  if (error) {
    console.error("Record usage error:", error);
  }
}

/**
 * Genera respuesta de error por rate limit
 */
export function rateLimitErrorResponse(
  result: RateLimitResult,
  language: string = "es"
): Response {
  const isSpanish = language.startsWith("es");

  let message: { es: string; en: string };

  switch (result.reason) {
    case "too_fast":
      message = {
        es: `Espera ${result.waitSeconds} segundo${result.waitSeconds > 1 ? "s" : ""} antes de enviar otro mensaje.`,
        en: `Wait ${result.waitSeconds} second${result.waitSeconds > 1 ? "s" : ""} before sending another message.`,
      };
      break;
    case "minute_limit":
      message = {
        es: "Has enviado muchos mensajes. Espera un minuto.",
        en: "You've sent too many messages. Wait a minute.",
      };
      break;
    case "hour_limit":
      message = {
        es: "Has alcanzado el límite de mensajes por hora. Vuelve más tarde.",
        en: "You've reached the hourly message limit. Try again later.",
      };
      break;
    default:
      message = {
        es: "Demasiadas solicitudes. Intenta de nuevo.",
        en: "Too many requests. Please try again.",
      };
  }

  const errorBody: RateLimitError = {
    error: "rate_limited",
    code: "RATE_LIMITED",
    waitSeconds: result.waitSeconds,
    message,
  };

  return new Response(JSON.stringify(errorBody), {
    status: 429,
    headers: {
      "Content-Type": "application/json",
      "Retry-After": String(result.waitSeconds),
    },
  });
}
