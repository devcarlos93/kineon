-- ============================================================================
-- UPDATE AI CHAT LIMIT FOR FREE TIER
-- Aumentar límite de chat de 3 a 4 para usuarios gratuitos
-- ============================================================================

UPDATE subscription_limits
SET ai_chat_daily = 4,
    updated_at = NOW()
WHERE tier = 'free';
