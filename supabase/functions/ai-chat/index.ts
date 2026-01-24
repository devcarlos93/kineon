// =====================================================
// AI CHAT - Asistente conversacional de Kineon
// Chat con recomendaciones personalizadas + quick replies
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

// Catálogo de géneros TMDB
const GENRE_CATALOG = [
  { id: 28, name: "Action" },
  { id: 12, name: "Adventure" },
  { id: 16, name: "Animation" },
  { id: 35, name: "Comedy" },
  { id: 80, name: "Crime" },
  { id: 99, name: "Documentary" },
  { id: 18, name: "Drama" },
  { id: 10751, name: "Family" },
  { id: 14, name: "Fantasy" },
  { id: 36, name: "History" },
  { id: 27, name: "Horror" },
  { id: 10402, name: "Music" },
  { id: 9648, name: "Mystery" },
  { id: 10749, name: "Romance" },
  { id: 878, name: "Science Fiction" },
  { id: 53, name: "Thriller" },
  { id: 10752, name: "War" },
  { id: 37, name: "Western" },
];

interface ChatMessage {
  role: "user" | "assistant";
  content: string;
}

interface RequestBody {
  message: string;
  history?: ChatMessage[];
  user_prefs?: {
    preferred_genres?: number[];
    mood_text?: string;
  };
  language?: string;
  region?: string;
}

interface Pick {
  tmdb_id: number;
  match: number;
  reason: string;
  content_type: "movie" | "tv";
}

interface AiResponse {
  assistant_message: string;
  picks: Pick[];
  quick_replies: string[];
}

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (req.method !== "POST") {
      return json({ error: "Use POST" }, 405);
    }

    const openaiKey = Deno.env.get("OPENAI_API_KEY");
    const supabaseUrl = Deno.env.get("SUPABASE_URL");
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");

    if (!openaiKey) {
      return json({ error: "Missing OPENAI_API_KEY" }, 500);
    }

    const body: RequestBody = await req.json().catch(() => ({}));
    const message = String(body?.message ?? "").trim();

    if (!message) {
      return json({ error: "Message is required" }, 400);
    }

    const history = Array.isArray(body?.history) ? body.history.slice(-10) : [];
    const userPrefs = body?.user_prefs ?? {};
    const language = body?.language ?? "es-ES";
    const region = body?.region ?? "ES";

    // ═══════════════════════════════════════════════════════════════════
    // RATE LIMITING
    // ═══════════════════════════════════════════════════════════════════
    const userId = getUserIdFromRequest(req);

    if (userId && supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);
      const rateCheck = await checkRateLimit(supabase, userId, "ai-chat");

      if (!rateCheck.allowed) {
        return rateLimitErrorResponse(rateCheck, language);
      }
    }

    // Construir contexto de preferencias
    const prefGenres = (userPrefs.preferred_genres ?? [])
      .map((id: number) => GENRE_CATALOG.find((g) => g.id === id)?.name)
      .filter(Boolean)
      .join(", ");

    const isEnglish = language.startsWith("en");

    const systemPrompt = `You are Kineon AI, an expert assistant for movies and TV series. Your personality:
- Friendly, concise, and enthusiastic about cinema
- You give personalized recommendations based on what the user asks
- You ALWAYS respond in ${isEnglish ? "English" : "Spanish"}
- NO spoilers

USER PREFERENCES:
- Favorite genres: ${prefGenres || (isEnglish ? "Not specified" : "No especificados")}
- Current mood: ${userPrefs.mood_text || (isEnglish ? "Not specified" : "No especificado")}
- Region: ${region}

IMPORTANT: You must ALWAYS respond in valid JSON format with this exact structure:
{
  "assistant_message": "${isEnglish ? "Your conversational response here (max 150 words)" : "Tu respuesta conversacional aquí (máx 150 palabras)"}",
  "picks": [
    {
      "tmdb_id": 123,
      "match": 92,
      "reason": "${isEnglish ? "Short reason why they'll like it (max 20 words)" : "Razón corta de por qué le gustará (máx 20 palabras)"}",
      "content_type": "movie"
    }
  ],
  "quick_replies": ["${isEnglish ? "Suggestion 1" : "Sugerencia 1"}", "${isEnglish ? "Suggestion 2" : "Sugerencia 2"}", "${isEnglish ? "Suggestion 3" : "Sugerencia 3"}"]
}

REGLAS:
1. "picks" debe tener 0-3 recomendaciones con TMDB IDs reales
2. "match" es un porcentaje 70-98 basado en qué tan bien encaja con lo pedido
3. "quick_replies" son 2-4 sugerencias cortas para continuar la conversación
4. Si el usuario saluda o hace preguntas generales, picks puede estar vacío
5. "content_type" es "movie" o "tv" según corresponda
6. Responde SOLO el JSON, sin texto adicional ni markdown`;

    const messages = [
      { role: "system", content: systemPrompt },
      ...history.map((m) => ({
        role: m.role,
        content: m.content,
      })),
      { role: "user", content: message },
    ];

    const model = Deno.env.get("AI_MODEL") ?? "gpt-4o-mini";

    const aiResponse = await fetch(OPENAI_URL, {
      method: "POST",
      headers: {
        Authorization: `Bearer ${openaiKey}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        model,
        messages,
        response_format: { type: "json_object" },
        max_tokens: 800,
        temperature: 0.7,
      }),
    });

    if (!aiResponse.ok) {
      const errorText = await aiResponse.text();
      console.error("OpenAI error:", errorText);
      return json({ error: "AI service error" }, 502);
    }

    const aiData = await aiResponse.json();
    const content = aiData?.choices?.[0]?.message?.content;

    if (!content) {
      return json({ error: "No response from AI" }, 502);
    }

    let parsed: AiResponse;
    try {
      parsed = JSON.parse(content);
    } catch {
      // Si falla el parse, devolver respuesta básica
      return json({
        assistant_message: content.slice(0, 500),
        picks: [],
        quick_replies: ["Cuéntame más", "Otra recomendación", "Sorpréndeme"],
      });
    }

    // Validar y sanitizar la respuesta
    const result: AiResponse = {
      assistant_message: String(parsed.assistant_message ?? "").slice(0, 1000),
      picks: Array.isArray(parsed.picks)
        ? parsed.picks.slice(0, 3).map((p) => ({
            tmdb_id: Number(p.tmdb_id) || 0,
            match: Math.min(Math.max(Number(p.match) || 80, 50), 99),
            reason: String(p.reason ?? "").slice(0, 150),
            content_type: p.content_type === "tv" ? "tv" : "movie",
          }))
        : [],
      quick_replies: Array.isArray(parsed.quick_replies)
        ? parsed.quick_replies.slice(0, 4).map((r) => String(r).slice(0, 50))
        : ["Cuéntame más", "Otra opción", "Sorpréndeme"],
    };

    // Filtrar picks con tmdb_id inválido
    result.picks = result.picks.filter((p) => p.tmdb_id > 0);

    // Registrar uso para rate limiting
    if (userId && supabaseUrl && supabaseServiceKey) {
      const supabase = createClient(supabaseUrl, supabaseServiceKey);
      const tokensUsed = aiData?.usage?.total_tokens ?? 0;
      await recordUsage(supabase, userId, "ai-chat", tokensUsed);
    }

    return json(result);
  } catch (e) {
    console.error("Error in ai-chat:", e);
    return json({
      assistant_message: "Lo siento, hubo un problema. ¿Intentamos de nuevo?",
      picks: [],
      quick_replies: ["Reintentar", "Algo popular", "Sorpréndeme"],
    });
  }
});
