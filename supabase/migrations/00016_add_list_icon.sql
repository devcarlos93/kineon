-- =====================================================
-- MIGRATION: Add icon column to user_lists
-- =====================================================

-- Add icon column with default emoji
ALTER TABLE public.user_lists ADD COLUMN IF NOT EXISTS icon TEXT DEFAULT '🎬';

-- Comment
COMMENT ON COLUMN public.user_lists.icon IS 'Emoji icon for the list display';
