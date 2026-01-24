-- =====================================================
-- MIGRACIÓN: Preferencias de perfil
-- Agrega columnas para persistir preferencias del usuario
-- =====================================================

-- Agregar columnas de preferencias
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS hide_spoilers BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS country_code TEXT DEFAULT 'US',
ADD COLUMN IF NOT EXISTS theme_mode TEXT DEFAULT 'dark';

-- Comentarios
COMMENT ON COLUMN public.profiles.hide_spoilers IS 'Ocultar spoilers en sinopsis y recomendaciones IA';
COMMENT ON COLUMN public.profiles.country_code IS 'Código de país para proveedores de streaming (US, MX, ES, CO, etc)';
COMMENT ON COLUMN public.profiles.theme_mode IS 'Modo de apariencia: system, light, dark';

-- =====================================================
-- FUNCIÓN: Actualizar preferencias
-- =====================================================

CREATE OR REPLACE FUNCTION public.update_profile_preferences(
  p_user_id UUID,
  p_hide_spoilers BOOLEAN DEFAULT NULL,
  p_country_code TEXT DEFAULT NULL,
  p_theme_mode TEXT DEFAULT NULL,
  p_preferred_language TEXT DEFAULT NULL
)
RETURNS public.profiles
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
  v_profile public.profiles;
BEGIN
  UPDATE public.profiles
  SET
    hide_spoilers = COALESCE(p_hide_spoilers, hide_spoilers),
    country_code = COALESCE(p_country_code, country_code),
    theme_mode = COALESCE(p_theme_mode, theme_mode),
    preferred_language = COALESCE(p_preferred_language, preferred_language),
    updated_at = NOW()
  WHERE id = p_user_id
  RETURNING * INTO v_profile;

  RETURN v_profile;
END;
$$;

-- =====================================================
-- FUNCIÓN: Obtener preferencias del perfil
-- =====================================================

CREATE OR REPLACE FUNCTION public.get_profile_preferences(p_user_id UUID)
RETURNS TABLE (
  hide_spoilers BOOLEAN,
  country_code TEXT,
  theme_mode TEXT,
  preferred_language TEXT,
  display_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.hide_spoilers,
    p.country_code,
    p.theme_mode,
    p.preferred_language,
    p.display_name,
    p.avatar_url,
    p.created_at
  FROM public.profiles p
  WHERE p.id = p_user_id;
END;
$$;
