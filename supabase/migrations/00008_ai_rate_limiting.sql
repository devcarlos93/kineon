-- ============================================================================
-- AI RATE LIMITING
-- Protege contra abuso y controla costos de OpenAI
-- ============================================================================

-- Tabla para tracking de uso de IA por usuario
CREATE TABLE IF NOT EXISTS ai_usage (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    endpoint TEXT NOT NULL, -- 'ai-chat', 'ai-search-plan', 'ai-movie-insight'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    tokens_used INT DEFAULT 0, -- Para tracking de costos (opcional)

    -- Index para queries rápidas
    CONSTRAINT ai_usage_user_endpoint_idx UNIQUE (id)
);

-- Índices para queries de rate limiting
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_time
    ON ai_usage(user_id, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_usage_endpoint_time
    ON ai_usage(endpoint, created_at DESC);
CREATE INDEX IF NOT EXISTS idx_ai_usage_user_endpoint_time
    ON ai_usage(user_id, endpoint, created_at DESC);

-- ============================================================================
-- FUNCIÓN: Verificar rate limit
-- Retorna: { allowed: boolean, wait_seconds: number, requests_remaining: number }
-- ============================================================================
CREATE OR REPLACE FUNCTION check_ai_rate_limit(
    p_user_id UUID,
    p_endpoint TEXT,
    p_max_per_minute INT DEFAULT 10,
    p_max_per_hour INT DEFAULT 50,
    p_min_interval_seconds INT DEFAULT 2
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_last_request TIMESTAMPTZ;
    v_count_minute INT;
    v_count_hour INT;
    v_seconds_since_last NUMERIC;
    v_wait_seconds INT := 0;
BEGIN
    -- Obtener última request del usuario para este endpoint
    SELECT created_at INTO v_last_request
    FROM ai_usage
    WHERE user_id = p_user_id AND endpoint = p_endpoint
    ORDER BY created_at DESC
    LIMIT 1;

    -- Calcular segundos desde última request
    IF v_last_request IS NOT NULL THEN
        v_seconds_since_last := EXTRACT(EPOCH FROM (NOW() - v_last_request));

        -- Verificar intervalo mínimo
        IF v_seconds_since_last < p_min_interval_seconds THEN
            v_wait_seconds := CEIL(p_min_interval_seconds - v_seconds_since_last);
            RETURN jsonb_build_object(
                'allowed', false,
                'reason', 'too_fast',
                'wait_seconds', v_wait_seconds,
                'requests_remaining', 0
            );
        END IF;
    END IF;

    -- Contar requests en el último minuto
    SELECT COUNT(*) INTO v_count_minute
    FROM ai_usage
    WHERE user_id = p_user_id
      AND endpoint = p_endpoint
      AND created_at > NOW() - INTERVAL '1 minute';

    IF v_count_minute >= p_max_per_minute THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'reason', 'minute_limit',
            'wait_seconds', 60,
            'requests_remaining', 0
        );
    END IF;

    -- Contar requests en la última hora
    SELECT COUNT(*) INTO v_count_hour
    FROM ai_usage
    WHERE user_id = p_user_id
      AND endpoint = p_endpoint
      AND created_at > NOW() - INTERVAL '1 hour';

    IF v_count_hour >= p_max_per_hour THEN
        RETURN jsonb_build_object(
            'allowed', false,
            'reason', 'hour_limit',
            'wait_seconds', 3600,
            'requests_remaining', 0
        );
    END IF;

    -- Permitido
    RETURN jsonb_build_object(
        'allowed', true,
        'reason', NULL,
        'wait_seconds', 0,
        'requests_remaining', p_max_per_hour - v_count_hour
    );
END;
$$;

-- ============================================================================
-- FUNCIÓN: Registrar uso de IA
-- ============================================================================
CREATE OR REPLACE FUNCTION record_ai_usage(
    p_user_id UUID,
    p_endpoint TEXT,
    p_tokens_used INT DEFAULT 0
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_id UUID;
BEGIN
    INSERT INTO ai_usage (user_id, endpoint, tokens_used)
    VALUES (p_user_id, p_endpoint, p_tokens_used)
    RETURNING id INTO v_id;

    RETURN v_id;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Limpiar registros antiguos (>24h)
-- Ejecutar con pg_cron diariamente
-- ============================================================================
CREATE OR REPLACE FUNCTION clean_old_ai_usage()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted INT;
BEGIN
    DELETE FROM ai_usage
    WHERE created_at < NOW() - INTERVAL '24 hours';

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Estadísticas de uso (para dashboard admin)
-- ============================================================================
CREATE OR REPLACE FUNCTION ai_usage_stats(p_hours INT DEFAULT 24)
RETURNS TABLE (
    endpoint TEXT,
    total_requests BIGINT,
    unique_users BIGINT,
    avg_per_user NUMERIC
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        au.endpoint,
        COUNT(*)::BIGINT as total_requests,
        COUNT(DISTINCT au.user_id)::BIGINT as unique_users,
        ROUND(COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT au.user_id), 0), 2) as avg_per_user
    FROM ai_usage au
    WHERE au.created_at > NOW() - (p_hours || ' hours')::INTERVAL
    GROUP BY au.endpoint
    ORDER BY total_requests DESC;
END;
$$;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================
ALTER TABLE ai_usage ENABLE ROW LEVEL SECURITY;

-- Solo el service_role puede insertar/leer (desde Edge Functions)
CREATE POLICY "Service role full access to ai_usage"
    ON ai_usage
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- Los usuarios pueden ver solo su propio uso (opcional, para UI)
CREATE POLICY "Users can view own ai_usage"
    ON ai_usage
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

-- ============================================================================
-- COMENTARIOS
-- ============================================================================
COMMENT ON TABLE ai_usage IS 'Tracking de uso de endpoints de IA para rate limiting';
COMMENT ON FUNCTION check_ai_rate_limit IS 'Verifica si un usuario puede hacer una request de IA';
COMMENT ON FUNCTION record_ai_usage IS 'Registra una request de IA';
COMMENT ON FUNCTION clean_old_ai_usage IS 'Limpia registros de más de 24h';
COMMENT ON FUNCTION ai_usage_stats IS 'Estadísticas de uso de IA para admin';
