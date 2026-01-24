-- =====================================================
-- TMDB CACHE TABLE
-- Cache de respuestas de TMDB para Edge Functions
-- Solo accesible via service_role (Edge Functions)
-- =====================================================

-- Crear tabla de cache
CREATE TABLE IF NOT EXISTS public.tmdb_cache (
    -- Key única: combina path + query ordenado
    key TEXT PRIMARY KEY,
    
    -- Respuesta JSON de TMDB
    data JSONB NOT NULL,
    
    -- Expiración
    expires_at TIMESTAMPTZ NOT NULL,
    
    -- Metadata
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    hit_count INT NOT NULL DEFAULT 0
);

-- Índice para limpiar cache expirado
CREATE INDEX idx_tmdb_cache_expires ON public.tmdb_cache(expires_at);

-- Índice para encontrar entradas más usadas
CREATE INDEX idx_tmdb_cache_hits ON public.tmdb_cache(hit_count DESC);

-- =====================================================
-- RLS: BLOQUEAR ACCESO PÚBLICO
-- Solo service_role puede acceder (usado por Edge Functions)
-- =====================================================

ALTER TABLE public.tmdb_cache ENABLE ROW LEVEL SECURITY;

-- NO crear políticas para anon/authenticated
-- Esto significa que SOLO service_role puede acceder
-- Las Edge Functions usan service_role automáticamente

-- Política explícita: denegar todo a usuarios normales
-- (RLS habilitado sin políticas = denegado por defecto)

-- =====================================================
-- FUNCIONES HELPER
-- =====================================================

-- Actualizar updated_at automáticamente
CREATE TRIGGER trg_tmdb_cache_updated
    BEFORE UPDATE ON public.tmdb_cache
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Función para limpiar cache expirado (ejecutar periódicamente)
CREATE OR REPLACE FUNCTION public.clean_expired_cache()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    deleted_count INT;
BEGIN
    DELETE FROM public.tmdb_cache
    WHERE expires_at < NOW();
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$;

-- Función para obtener estadísticas del cache
CREATE OR REPLACE FUNCTION public.cache_stats()
RETURNS TABLE (
    total_entries BIGINT,
    expired_entries BIGINT,
    valid_entries BIGINT,
    total_hits BIGINT,
    oldest_entry TIMESTAMPTZ,
    newest_entry TIMESTAMPTZ
)
LANGUAGE sql
SECURITY DEFINER
AS $$
    SELECT 
        COUNT(*) as total_entries,
        COUNT(*) FILTER (WHERE expires_at < NOW()) as expired_entries,
        COUNT(*) FILTER (WHERE expires_at >= NOW()) as valid_entries,
        COALESCE(SUM(hit_count), 0) as total_hits,
        MIN(created_at) as oldest_entry,
        MAX(created_at) as newest_entry
    FROM public.tmdb_cache;
$$;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE public.tmdb_cache IS 'Cache de respuestas TMDB. Solo accesible via service_role (Edge Functions).';
COMMENT ON COLUMN public.tmdb_cache.key IS 'Clave única: hash de path + query params ordenados';
COMMENT ON COLUMN public.tmdb_cache.data IS 'Respuesta JSON de TMDB';
COMMENT ON COLUMN public.tmdb_cache.expires_at IS 'Timestamp de expiración del cache';
COMMENT ON COLUMN public.tmdb_cache.hit_count IS 'Contador de hits para estadísticas';

-- =====================================================
-- CRON JOB (opcional - configurar en Supabase Dashboard)
-- Dashboard > Database > Extensions > pg_cron
-- =====================================================

/*
-- Limpiar cache expirado cada hora
SELECT cron.schedule(
    'clean-tmdb-cache',
    '0 * * * *',  -- Cada hora
    $$SELECT public.clean_expired_cache()$$
);
*/
