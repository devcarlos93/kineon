-- ============================================================================
-- SUBSCRIPTION & DAILY LIMITS
-- Sistema de suscripción Pro y límites diarios para usuarios Free
-- ============================================================================

-- ============================================================================
-- 1. AGREGAR CAMPOS DE SUSCRIPCIÓN A PROFILES
-- ============================================================================

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_status TEXT DEFAULT 'free'
    CHECK (subscription_status IN ('free', 'pro', 'expired', 'grace_period'));

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_expires_at TIMESTAMPTZ;

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_provider TEXT; -- 'apple', 'google', 'stripe'

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_product_id TEXT; -- ID del producto comprado

ALTER TABLE profiles
ADD COLUMN IF NOT EXISTS subscription_original_transaction_id TEXT; -- Para restore

-- ============================================================================
-- 2. TABLA DE LÍMITES POR TIER
-- ============================================================================

CREATE TABLE IF NOT EXISTS subscription_limits (
    tier TEXT PRIMARY KEY, -- 'free', 'pro'
    ai_chat_daily INT NOT NULL DEFAULT 5,
    ai_search_daily INT NOT NULL DEFAULT 5,
    ai_insight_daily INT NOT NULL DEFAULT 3,
    ai_picks_daily INT NOT NULL DEFAULT 5,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Insertar límites por defecto
-- FREE: Límites conservadores para controlar costos de IA
-- PRO: Prácticamente ilimitado
INSERT INTO subscription_limits (tier, ai_chat_daily, ai_search_daily, ai_insight_daily, ai_picks_daily)
VALUES
    ('free', 3, 3, 3, 5),
    ('pro', 1000, 1000, 1000, 1000)
ON CONFLICT (tier) DO UPDATE SET
    ai_chat_daily = EXCLUDED.ai_chat_daily,
    ai_search_daily = EXCLUDED.ai_search_daily,
    ai_insight_daily = EXCLUDED.ai_insight_daily,
    ai_picks_daily = EXCLUDED.ai_picks_daily,
    updated_at = NOW();

-- ============================================================================
-- 3. FUNCIÓN: Obtener uso diario del usuario
-- ============================================================================

CREATE OR REPLACE FUNCTION get_daily_ai_usage(p_user_id UUID)
RETURNS TABLE (
    endpoint TEXT,
    used_today INT,
    daily_limit INT,
    remaining INT
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tier TEXT;
BEGIN
    -- Obtener tier del usuario
    SELECT COALESCE(
        CASE
            WHEN subscription_status = 'pro' AND (subscription_expires_at IS NULL OR subscription_expires_at > NOW())
            THEN 'pro'
            ELSE 'free'
        END,
        'free'
    ) INTO v_tier
    FROM profiles
    WHERE id = p_user_id;

    -- Si no existe el usuario, asumir free
    IF v_tier IS NULL THEN
        v_tier := 'free';
    END IF;

    RETURN QUERY
    WITH usage_counts AS (
        SELECT
            au.endpoint,
            COUNT(*)::INT as used_today
        FROM ai_usage au
        WHERE au.user_id = p_user_id
          AND au.created_at >= CURRENT_DATE
          AND au.created_at < CURRENT_DATE + INTERVAL '1 day'
        GROUP BY au.endpoint
    ),
    limits AS (
        SELECT
            'ai-chat' as endpoint, sl.ai_chat_daily as daily_limit FROM subscription_limits sl WHERE sl.tier = v_tier
        UNION ALL
        SELECT 'ai-search-plan', sl.ai_search_daily FROM subscription_limits sl WHERE sl.tier = v_tier
        UNION ALL
        SELECT 'ai-movie-insight', sl.ai_insight_daily FROM subscription_limits sl WHERE sl.tier = v_tier
        UNION ALL
        SELECT 'ai-home-picks', sl.ai_picks_daily FROM subscription_limits sl WHERE sl.tier = v_tier
    )
    SELECT
        l.endpoint,
        COALESCE(uc.used_today, 0) as used_today,
        l.daily_limit,
        GREATEST(0, l.daily_limit - COALESCE(uc.used_today, 0)) as remaining
    FROM limits l
    LEFT JOIN usage_counts uc ON uc.endpoint = l.endpoint;
END;
$$;

-- ============================================================================
-- 4. FUNCIÓN: Verificar si puede usar feature (con límite diario)
-- ============================================================================

CREATE OR REPLACE FUNCTION check_daily_limit(
    p_user_id UUID,
    p_endpoint TEXT
)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_tier TEXT;
    v_used_today INT;
    v_daily_limit INT;
    v_remaining INT;
BEGIN
    -- Obtener tier del usuario
    SELECT COALESCE(
        CASE
            WHEN subscription_status = 'pro' AND (subscription_expires_at IS NULL OR subscription_expires_at > NOW())
            THEN 'pro'
            ELSE 'free'
        END,
        'free'
    ) INTO v_tier
    FROM profiles
    WHERE id = p_user_id;

    IF v_tier IS NULL THEN
        v_tier := 'free';
    END IF;

    -- Obtener límite según endpoint
    SELECT
        CASE p_endpoint
            WHEN 'ai-chat' THEN ai_chat_daily
            WHEN 'ai-search-plan' THEN ai_search_daily
            WHEN 'ai-movie-insight' THEN ai_insight_daily
            WHEN 'ai-home-picks' THEN ai_picks_daily
            ELSE 5
        END
    INTO v_daily_limit
    FROM subscription_limits
    WHERE tier = v_tier;

    IF v_daily_limit IS NULL THEN
        v_daily_limit := 5;
    END IF;

    -- Contar uso de hoy
    SELECT COUNT(*)::INT INTO v_used_today
    FROM ai_usage
    WHERE user_id = p_user_id
      AND endpoint = p_endpoint
      AND created_at >= CURRENT_DATE
      AND created_at < CURRENT_DATE + INTERVAL '1 day';

    v_remaining := GREATEST(0, v_daily_limit - v_used_today);

    -- Retornar resultado
    RETURN jsonb_build_object(
        'allowed', v_remaining > 0,
        'tier', v_tier,
        'used_today', v_used_today,
        'daily_limit', v_daily_limit,
        'remaining', v_remaining,
        'is_pro', v_tier = 'pro'
    );
END;
$$;

-- ============================================================================
-- 5. FUNCIÓN: Obtener estado de suscripción
-- ============================================================================

CREATE OR REPLACE FUNCTION get_subscription_status(p_user_id UUID)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSONB;
BEGIN
    SELECT jsonb_build_object(
        'status', COALESCE(subscription_status, 'free'),
        'is_pro', subscription_status = 'pro' AND (subscription_expires_at IS NULL OR subscription_expires_at > NOW()),
        'expires_at', subscription_expires_at,
        'provider', subscription_provider,
        'product_id', subscription_product_id
    ) INTO v_result
    FROM profiles
    WHERE id = p_user_id;

    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'status', 'free',
            'is_pro', false,
            'expires_at', NULL,
            'provider', NULL,
            'product_id', NULL
        );
    END IF;

    RETURN v_result;
END;
$$;

-- ============================================================================
-- 6. FUNCIÓN: Actualizar suscripción (llamada desde webhook)
-- ============================================================================

CREATE OR REPLACE FUNCTION update_subscription(
    p_user_id UUID,
    p_status TEXT,
    p_expires_at TIMESTAMPTZ,
    p_provider TEXT,
    p_product_id TEXT,
    p_original_transaction_id TEXT DEFAULT NULL
)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE profiles SET
        subscription_status = p_status,
        subscription_expires_at = p_expires_at,
        subscription_provider = p_provider,
        subscription_product_id = p_product_id,
        subscription_original_transaction_id = COALESCE(p_original_transaction_id, subscription_original_transaction_id),
        updated_at = NOW()
    WHERE id = p_user_id;
END;
$$;

-- ============================================================================
-- 7. ÍNDICES
-- ============================================================================

CREATE INDEX IF NOT EXISTS idx_profiles_subscription_status
    ON profiles(subscription_status);

-- Índice para queries de uso diario
-- El índice idx_ai_usage_user_endpoint_time ya existe en 00008, cubre este caso

-- ============================================================================
-- 8. RLS POLICIES
-- ============================================================================

-- subscription_limits es solo lectura para todos
ALTER TABLE subscription_limits ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read subscription_limits"
    ON subscription_limits
    FOR SELECT
    TO authenticated
    USING (true);

CREATE POLICY "Service role can manage subscription_limits"
    ON subscription_limits
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- COMENTARIOS
-- ============================================================================

COMMENT ON TABLE subscription_limits IS 'Límites diarios de IA por tier de suscripción';
COMMENT ON FUNCTION get_daily_ai_usage IS 'Obtiene el uso diario de IA del usuario con límites';
COMMENT ON FUNCTION check_daily_limit IS 'Verifica si el usuario puede usar una feature de IA';
COMMENT ON FUNCTION get_subscription_status IS 'Obtiene el estado de suscripción del usuario';
COMMENT ON FUNCTION update_subscription IS 'Actualiza la suscripción (desde webhook de pagos)';
