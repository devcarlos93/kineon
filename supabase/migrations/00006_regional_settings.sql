-- ============================================================================
-- MIGRACIÓN: Configuración Regional Multi-País
-- ============================================================================
-- Agrega soporte para:
-- - country_code: ISO-2 (CO, MX, ES, AR, US...)
-- - language_tag: IETF (es-CO, es-MX, en-US...)
--
-- Esto permite:
-- - Mostrar contenido en el idioma correcto
-- - Filtrar por región para watch providers
-- - Recomendaciones IA relevantes por país
-- ============================================================================

-- Agregar columnas de configuración regional a profiles
ALTER TABLE public.profiles
ADD COLUMN IF NOT EXISTS country_code TEXT DEFAULT 'ES',
ADD COLUMN IF NOT EXISTS language_tag TEXT DEFAULT 'es-ES';

-- Comentarios para documentación
COMMENT ON COLUMN public.profiles.country_code IS 'ISO 3166-1 alpha-2 country code (CO, MX, ES, AR, US...)';
COMMENT ON COLUMN public.profiles.language_tag IS 'IETF BCP 47 language tag (es-CO, es-MX, en-US...)';

-- Índice para queries por región (útil para analytics)
CREATE INDEX IF NOT EXISTS idx_profiles_country_code
ON public.profiles(country_code);

-- Función helper para obtener configuración regional del usuario
CREATE OR REPLACE FUNCTION get_user_regional_settings(user_id UUID)
RETURNS TABLE (
    country_code TEXT,
    language_tag TEXT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        COALESCE(p.country_code, 'ES') as country_code,
        COALESCE(p.language_tag, 'es-ES') as language_tag
    FROM public.profiles p
    WHERE p.id = user_id;
END;
$$;
