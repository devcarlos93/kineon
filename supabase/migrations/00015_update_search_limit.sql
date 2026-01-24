-- ============================================================================
-- UPDATE AI SEARCH LIMIT FOR FREE TIER
-- Cambiar límite de búsqueda IA de 10 a 6 para usuarios gratuitos
-- ============================================================================

UPDATE subscription_limits
SET ai_search_daily = 6,
    updated_at = NOW()
WHERE tier = 'free';
