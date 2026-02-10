-- =====================================================
-- SMART COLLECTIONS - AI-generated thematic collections
-- =====================================================

-- Main collections table
CREATE TABLE IF NOT EXISTS public.smart_collections (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title_en text NOT NULL,
  title_es text NOT NULL,
  description_en text NOT NULL,
  description_es text NOT NULL,
  slug text UNIQUE NOT NULL,
  backdrop_path text,
  emoji text NOT NULL DEFAULT '',
  is_active boolean NOT NULL DEFAULT true,
  week_of date NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now()
);

-- Collection items table
CREATE TABLE IF NOT EXISTS public.smart_collection_items (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  collection_id uuid NOT NULL REFERENCES public.smart_collections(id) ON DELETE CASCADE,
  tmdb_id integer NOT NULL,
  content_type text NOT NULL CHECK (content_type IN ('movie', 'tv')),
  position integer NOT NULL,
  reason_en text NOT NULL DEFAULT '',
  reason_es text NOT NULL DEFAULT ''
);

-- =====================================================
-- INDEXES
-- =====================================================

CREATE INDEX idx_smart_collections_week_active ON public.smart_collections(week_of, is_active);
CREATE UNIQUE INDEX idx_smart_collections_slug ON public.smart_collections(slug);
CREATE INDEX idx_smart_collection_items_collection_position ON public.smart_collection_items(collection_id, position);

-- =====================================================
-- RLS POLICIES
-- =====================================================

ALTER TABLE public.smart_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.smart_collection_items ENABLE ROW LEVEL SECURITY;

-- Authenticated users can read collections
CREATE POLICY "Authenticated users can read smart_collections"
  ON public.smart_collections FOR SELECT
  TO authenticated
  USING (true);

-- Authenticated users can read collection items
CREATE POLICY "Authenticated users can read smart_collection_items"
  ON public.smart_collection_items FOR SELECT
  TO authenticated
  USING (true);

-- Service role has full access (implicit via BYPASSRLS)
