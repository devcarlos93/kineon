// =====================================================
// AI SMART COLLECTIONS - Edge Function
// Generates thematic AI-curated collections weekly
// =====================================================

import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2.39.0";

// Configuration
const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const OPENAI_API_KEY = Deno.env.get("OPENAI_API_KEY");
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY");

const supabaseAdmin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

// =====================================================
// TYPES
// =====================================================

interface AICollection {
  title_en: string;
  title_es: string;
  description_en: string;
  description_es: string;
  icon: string;
  items: AICollectionItem[];
}

interface AICollectionItem {
  tmdb_id: number;
  content_type: "movie" | "tv";
  reason_en: string;
  reason_es: string;
}

interface TMDBResult {
  id: number;
  title?: string;
  name?: string;
  poster_path: string | null;
  backdrop_path: string | null;
  overview: string;
  vote_average: number;
}

// =====================================================
// TMDB: Validate IDs via proxy
// =====================================================

async function validateTmdbId(
  tmdbId: number,
  contentType: "movie" | "tv"
): Promise<TMDBResult | null> {
  try {
    const path = contentType === "tv" ? `tv/${tmdbId}` : `movie/${tmdbId}`;
    const response = await fetch(`${SUPABASE_URL}/functions/v1/tmdb-proxy`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "Authorization": `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      },
      body: JSON.stringify({ path, language: "en-US" }),
    });

    if (!response.ok) return null;

    const data = await response.json();
    if (!data?.id) return null;

    return data as TMDBResult;
  } catch {
    return null;
  }
}

// =====================================================
// SLUG: Generate URL-friendly slug
// =====================================================

function generateSlug(title: string, weekOf: string): string {
  const base = title
    .toLowerCase()
    .replace(/[^a-z0-9\s-]/g, "")
    .replace(/\s+/g, "-")
    .replace(/-+/g, "-")
    .slice(0, 50);
  const weekSuffix = weekOf.replace(/-/g, "");
  return `${base}-${weekSuffix}`;
}

// =====================================================
// AI: Generate collections
// =====================================================

async function generateCollectionsWithAI(): Promise<AICollection[]> {
  const now = new Date();
  const month = now.toLocaleString("en-US", { month: "long" });
  const day = now.getDate();
  const year = now.getFullYear();
  const season = getSeason(now);

  const systemPrompt = `You are an expert film and TV curator for Kineon, a premium movie discovery app. Generate creative, thematic collections that feel editorial and curated.

STRICT RULES:
1. Generate EXACTLY 3 collections
2. Each collection must have 6-8 items with REAL, VALID TMDB IDs
3. Mix popular titles with hidden gems
4. Vary genres, decades, and moods across collections
5. All titles/descriptions must be bilingual (EN + ES)
6. Each item needs a short reason why it fits the theme (bilingual)
7. Use REAL TMDB IDs — do NOT invent IDs
8. Include both movies and TV shows across collections
9. For the "icon" field, pick ONE icon name from this list that best represents the collection theme:
   movie, theaters, psychology, explore, favorite, bolt, local_fire_department, nightlight, beach_access, wb_sunny, cloud, auto_awesome, rocket_launch, diversity_3, self_improvement, visibility, palette, music_note, castle, dark_mode, mood, sentiment_satisfied, flight, terrain, water_drop, spa, forest, celebration, lightbulb, science, history_edu, military_tech, family_restroom, sports_esports, diamond, emoji_objects, stream

RESPONSE FORMAT (JSON array):
[
  {
    "title_en": "Rainy Day Comfort Films",
    "title_es": "Peliculas para Dias de Lluvia",
    "description_en": "Cozy movies perfect for curling up on the couch",
    "description_es": "Peliculas acogedoras perfectas para acurrucarse en el sofa",
    "icon": "cloud",
    "items": [
      {
        "tmdb_id": 13,
        "content_type": "movie",
        "reason_en": "The ultimate feel-good adventure",
        "reason_es": "La aventura mas reconfortante"
      }
    ]
  }
]`;

  const userPrompt = `Current date: ${month} ${day}, ${year}
Season: ${season}

Generate 3 creative thematic collections for this week. Consider:
- Current season (${season})
- Any major cultural moments or holidays near this date
- A mix of moods: one uplifting, one thought-provoking, one for entertainment
- Include a variety of content: classics, recent releases, hidden gems
- Each collection should have 6-8 items with REAL TMDB IDs

IMPORTANT: Only use TMDB IDs you are CERTAIN are correct. Use well-known movies/shows.`;

  if (OPENAI_API_KEY) {
    return await callOpenAI(systemPrompt, userPrompt);
  } else if (ANTHROPIC_API_KEY) {
    return await callClaude(systemPrompt, userPrompt);
  }

  throw new Error("No AI API key configured");
}

function getSeason(date: Date): string {
  const month = date.getMonth();
  if (month >= 2 && month <= 4) return "Spring";
  if (month >= 5 && month <= 7) return "Summer";
  if (month >= 8 && month <= 10) return "Autumn/Fall";
  return "Winter";
}

async function callOpenAI(systemPrompt: string, userPrompt: string): Promise<AICollection[]> {
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
      temperature: 0.8,
      max_tokens: 4096,
    }),
  });

  if (!response.ok) {
    const error = await response.text();
    console.error("OpenAI error:", error);
    throw new Error(`OpenAI API error: ${response.status}`);
  }

  const data = await response.json();
  const content = data.choices?.[0]?.message?.content || "[]";
  return parseAIResponse(content);
}

async function callClaude(systemPrompt: string, userPrompt: string): Promise<AICollection[]> {
  const response = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: {
      "x-api-key": ANTHROPIC_API_KEY!,
      "anthropic-version": "2023-06-01",
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      model: "claude-3-haiku-20240307",
      max_tokens: 4096,
      temperature: 0.8,
      messages: [
        { role: "user", content: `${systemPrompt}\n\n${userPrompt}` },
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

function parseAIResponse(content: string): AICollection[] {
  const cleanContent = content
    .replace(/```json\n?/g, "")
    .replace(/```\n?/g, "")
    .trim();

  const parsed = JSON.parse(cleanContent);

  if (!Array.isArray(parsed)) {
    throw new Error("Response is not an array");
  }

  return parsed.map((col: Record<string, unknown>) => ({
    title_en: String(col.title_en || "Untitled Collection"),
    title_es: String(col.title_es || "Coleccion sin titulo"),
    description_en: String(col.description_en || ""),
    description_es: String(col.description_es || ""),
    icon: String(col.icon || col.emoji || "movie"),
    items: Array.isArray(col.items)
      ? col.items.map((item: Record<string, unknown>) => ({
          tmdb_id: Number(item.tmdb_id),
          content_type: item.content_type === "tv" ? "tv" as const : "movie" as const,
          reason_en: String(item.reason_en || ""),
          reason_es: String(item.reason_es || ""),
        }))
      : [],
  }));
}

// =====================================================
// DB: Insert collections
// =====================================================

async function deactivatePreviousCollections(): Promise<void> {
  await supabaseAdmin
    .from("smart_collections")
    .update({ is_active: false, updated_at: new Date().toISOString() })
    .eq("is_active", true);
}

async function insertCollection(
  collection: AICollection,
  weekOf: string,
  validatedItems: { item: AICollectionItem; backdropPath: string | null }[]
): Promise<string | null> {
  if (validatedItems.length < 4) {
    console.warn(`Skipping "${collection.title_en}" — only ${validatedItems.length} valid items`);
    return null;
  }

  const slug = generateSlug(collection.title_en, weekOf);

  // Use the first item's backdrop as collection backdrop
  const backdropPath = validatedItems.find(v => v.backdropPath)?.backdropPath || null;

  const { data, error } = await supabaseAdmin
    .from("smart_collections")
    .insert({
      title_en: collection.title_en,
      title_es: collection.title_es,
      description_en: collection.description_en,
      description_es: collection.description_es,
      slug,
      backdrop_path: backdropPath,
      emoji: collection.icon,
      is_active: true,
      week_of: weekOf,
    })
    .select("id")
    .single();

  if (error) {
    console.error("Error inserting collection:", error);
    return null;
  }

  const collectionId = data.id;

  // Insert items with position
  const itemsToInsert = validatedItems.map((v, index) => ({
    collection_id: collectionId,
    tmdb_id: v.item.tmdb_id,
    content_type: v.item.content_type,
    position: index,
    reason_en: v.item.reason_en,
    reason_es: v.item.reason_es,
  }));

  const { error: itemsError } = await supabaseAdmin
    .from("smart_collection_items")
    .insert(itemsToInsert);

  if (itemsError) {
    console.error("Error inserting items:", itemsError);
    // Rollback collection
    await supabaseAdmin.from("smart_collections").delete().eq("id", collectionId);
    return null;
  }

  return collectionId;
}

// =====================================================
// MAIN HANDLER
// =====================================================

serve(async (req: Request): Promise<Response> => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return jsonResponse({ error: "Method not allowed" }, 405);
  }

  try {
    // Auth: accept service_role key, valid user token, or no-jwt mode (for cron/manual)
    const authHeader = req.headers.get("Authorization");
    const isServiceRole = authHeader?.includes(SUPABASE_SERVICE_ROLE_KEY);
    if (!isServiceRole && authHeader) {
      const token = authHeader.replace("Bearer ", "");
      const { data } = await supabaseAdmin.auth.getUser(token);
      if (!data?.user) {
        return jsonResponse({ error: "Unauthorized" }, 401);
      }
    }
    // If no auth header at all, allow (function deployed with --no-verify-jwt for cron)

    const weekOf = getWeekOf();

    console.log(`Generating smart collections for week of ${weekOf}...`);

    // 1. Generate collections with AI
    let aiCollections: AICollection[];
    let aiError: string | null = null;

    try {
      aiCollections = await generateCollectionsWithAI();
    } catch (e) {
      console.error("AI generation failed, retrying with fallback model...", e);
      aiError = e instanceof Error ? e.message : String(e);

      // Retry with fallback
      try {
        aiCollections = await generateCollectionsWithAI();
      } catch (e2) {
        console.error("Fallback also failed:", e2);
        return jsonResponse({
          success: false,
          error: "AI generation failed",
          details: aiError,
        }, 500);
      }
    }

    console.log(`AI generated ${aiCollections.length} collections`);

    // 2. Validate TMDB IDs for each collection
    const createdCollections: string[] = [];

    for (const collection of aiCollections) {
      const validatedItems: { item: AICollectionItem; backdropPath: string | null }[] = [];

      for (const item of collection.items) {
        if (!item.tmdb_id || item.tmdb_id <= 0) continue;

        const tmdbResult = await validateTmdbId(item.tmdb_id, item.content_type);
        if (tmdbResult) {
          validatedItems.push({
            item,
            backdropPath: tmdbResult.backdrop_path,
          });
        } else {
          console.warn(`Invalid TMDB ID: ${item.content_type}:${item.tmdb_id}`);
        }
      }

      console.log(`"${collection.title_en}": ${validatedItems.length}/${collection.items.length} items validated`);

      // 3. Deactivate old collections before inserting new ones
      // (only on first successful collection)
      if (createdCollections.length === 0 && validatedItems.length >= 4) {
        await deactivatePreviousCollections();
      }

      // 4. Insert collection + items
      const collectionId = await insertCollection(collection, weekOf, validatedItems);
      if (collectionId) {
        createdCollections.push(collectionId);
      }
    }

    return jsonResponse({
      success: true,
      collections_created: createdCollections.length,
      collection_ids: createdCollections,
      week_of: weekOf,
      ai_error: aiError,
      generated_at: new Date().toISOString(),
    }, 200);

  } catch (error) {
    console.error("Error in ai-smart-collections:", error);
    return jsonResponse({
      success: false,
      error: error instanceof Error ? error.message : "Internal error",
    }, 500);
  }
});

// =====================================================
// HELPERS
// =====================================================

function getWeekOf(): string {
  const now = new Date();
  // Get Monday of current week
  const day = now.getDay();
  const diff = now.getDate() - day + (day === 0 ? -6 : 1);
  const monday = new Date(now.setDate(diff));
  return monday.toISOString().split("T")[0];
}

function jsonResponse(data: unknown, status: number): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...corsHeaders,
      "Content-Type": "application/json",
    },
  });
}
