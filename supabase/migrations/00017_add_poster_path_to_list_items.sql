-- Add poster_path to user_list_items for collage preview
-- This stores the TMDB poster path when adding items to custom lists

ALTER TABLE public.user_list_items
ADD COLUMN IF NOT EXISTS poster_path TEXT;

-- Add index for faster lookups
CREATE INDEX IF NOT EXISTS idx_user_list_items_list_id_added
ON public.user_list_items(list_id, added_at DESC);
