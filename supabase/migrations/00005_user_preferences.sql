-- =====================================================
-- MIGRACION: User Preferences para IA
-- Agrega campos de preferencias del onboarding
-- =====================================================

-- Agregar campos de preferencias a profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS preferred_genres INTEGER[] DEFAULT '{}',
ADD COLUMN IF NOT EXISTS mood_text TEXT DEFAULT '',
ADD COLUMN IF NOT EXISTS onboarding_completed BOOLEAN DEFAULT false;

-- Comentarios
COMMENT ON COLUMN public.profiles.preferred_genres IS 'IDs de generos TMDB seleccionados en onboarding';
COMMENT ON COLUMN public.profiles.mood_text IS 'Texto de mood/preferencia escrito por el usuario';
COMMENT ON COLUMN public.profiles.onboarding_completed IS 'Si el usuario completo el onboarding';

-- Indice para buscar usuarios con onboarding completo
CREATE INDEX IF NOT EXISTS idx_profiles_onboarding
ON public.profiles(onboarding_completed)
WHERE onboarding_completed = true;
