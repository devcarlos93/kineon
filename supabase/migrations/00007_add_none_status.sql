-- ============================================================================
-- MIGRACIÓN: Agregar status 'none' para favoritos independientes
-- ============================================================================
-- Permite que un item sea favorito sin estar en watchlist
-- ============================================================================

-- Agregar 'none' al enum watch_status
ALTER TYPE watch_status ADD VALUE IF NOT EXISTS 'none' BEFORE 'watchlist';
