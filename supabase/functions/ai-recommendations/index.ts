// Supabase Edge Function: AI Recommendations
// Genera recomendaciones personalizadas usando OpenAI + TMDB

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";

const TMDB_BASE_URL = "https://api.themoviedb.org/3";
const TMDB_API_KEY = Deno.env.get("TMDB_API_KEY");
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface RequestBody {
  movie_ids?: number[];
  tv_ids?: number[];
  mood?: string;
  genres?: string[];
}

interface TMDBMovie {
  id: number;
  title?: string;
  name?: string;
  poster_path: string | null;
  vote_average: number;
  overview: string;
  media_type?: string;
}

serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!TMDB_API_KEY) throw new Error("TMDB_API_KEY no configurada");
    if (!OPENAI_API_KEY) throw new Error("OPENAI_API_KEY no configurada");

    const body: RequestBody = await req.json();
    const { movie_ids = [], tv_ids = [], mood, genres = [] } = body;

    // Obtener detalles de las películas/series que el usuario ha visto
    const watchedDetails = await Promise.all([
      ...movie_ids.slice(0, 5).map((id) => fetchTMDBDetails("movie", id)),
      ...tv_ids.slice(0, 5).map((id) => fetchTMDBDetails("tv", id)),
    ]);

    const watchedTitles = watchedDetails
      .filter((d) => d !== null)
      .map((d) => d?.title || d?.name)
      .filter(Boolean);

    // Generar prompt para OpenAI
    const prompt = buildPrompt(watchedTitles, mood, genres);

    // Llamar a OpenAI para obtener recomendaciones
    const aiResponse = await fetch("https://api.openai.com/v1/chat/completions", {
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
            content: `Eres un experto en cine y series de TV. Tu tarea es recomendar películas y series basándote en los gustos del usuario. 
            Responde SOLO con un JSON array de títulos de películas/series en el siguiente formato:
            {"recommendations": ["Título 1", "Título 2", "Título 3", ...]}
            Máximo 10 recomendaciones. Solo el JSON, sin explicaciones adicionales.`,
          },
          { role: "user", content: prompt },
        ],
        temperature: 0.8,
        max_tokens: 500,
      }),
    });

    if (!aiResponse.ok) {
      throw new Error(`OpenAI error: ${aiResponse.status}`);
    }

    const aiData = await aiResponse.json();
    const aiContent = aiData.choices?.[0]?.message?.content || "{}";

    // Parsear las recomendaciones de la IA
    let recommendedTitles: string[] = [];
    try {
      const parsed = JSON.parse(aiContent);
      recommendedTitles = parsed.recommendations || [];
    } catch {
      // Intentar extraer títulos si el formato no es exacto
      const matches = aiContent.match(/"([^"]+)"/g);
      if (matches) {
        recommendedTitles = matches.map((m: string) => m.replace(/"/g, ""));
      }
    }

    // Buscar cada título en TMDB para obtener los detalles completos
    const recommendations = await Promise.all(
      recommendedTitles.slice(0, 10).map((title) => searchTMDB(title))
    );

    const validRecommendations = recommendations
      .filter((r): r is TMDBMovie => r !== null)
      .map((r) => ({
        id: r.id,
        title: r.title || r.name,
        poster_path: r.poster_path,
        vote_average: r.vote_average,
        overview: r.overview,
        media_type: r.media_type || "movie",
      }));

    // Categorizar recomendaciones
    const result = {
      for_you: validRecommendations.slice(0, 5),
      based_on_mood: mood ? validRecommendations.slice(3, 7) : [],
      because_you_liked:
        watchedTitles.length > 0 ? validRecommendations.slice(5, 10) : [],
    };

    return new Response(JSON.stringify(result), {
      status: 200,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error en ai-recommendations:", error);
    return new Response(
      JSON.stringify({
        error: error instanceof Error ? error.message : "Error desconocido",
        for_you: [],
        based_on_mood: [],
        because_you_liked: [],
      }),
      {
        status: 400,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});

function buildPrompt(
  watchedTitles: string[],
  mood?: string,
  genres?: string[]
): string {
  let prompt = "Recomiéndame películas y series ";

  if (watchedTitles.length > 0) {
    prompt += `basándote en que me gustaron: ${watchedTitles.join(", ")}. `;
  }

  if (mood) {
    prompt += `Mi estado de ánimo actual es: ${mood}. `;
  }

  if (genres && genres.length > 0) {
    prompt += `Me interesan los géneros: ${genres.join(", ")}. `;
  }

  if (!watchedTitles.length && !mood && (!genres || !genres.length)) {
    prompt +=
      "populares y aclamadas por la crítica de los últimos años. Incluye variedad de géneros.";
  }

  return prompt;
}

async function fetchTMDBDetails(
  type: "movie" | "tv",
  id: number
): Promise<TMDBMovie | null> {
  try {
    const url = `${TMDB_BASE_URL}/${type}/${id}?api_key=${TMDB_API_KEY}&language=es-ES`;
    const response = await fetch(url);
    if (!response.ok) return null;
    const data = await response.json();
    return { ...data, media_type: type };
  } catch {
    return null;
  }
}

async function searchTMDB(query: string): Promise<TMDBMovie | null> {
  try {
    const url = `${TMDB_BASE_URL}/search/multi?api_key=${TMDB_API_KEY}&language=es-ES&query=${encodeURIComponent(query)}`;
    const response = await fetch(url);
    if (!response.ok) return null;
    const data = await response.json();
    const result = data.results?.[0];
    if (result && (result.media_type === "movie" || result.media_type === "tv")) {
      return result;
    }
    return null;
  } catch {
    return null;
  }
}
