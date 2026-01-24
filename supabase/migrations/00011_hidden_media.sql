-- =====================================================
-- MIGRACIÓN: Media oculto ("No me interesa")
-- Permite al usuario ocultar contenido de recomendaciones
-- =====================================================

CREATE TABLE IF NOT EXISTS public.user_hidden_media (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    content_type content_type NOT NULL,
    hidden_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),

    -- Un usuario solo puede ocultar un item una vez
    UNIQUE(user_id, tmdb_id, content_type)
);

-- Índices para queries rápidas
CREATE INDEX idx_hidden_media_user ON public.user_hidden_media(user_id);
CREATE INDEX idx_hidden_media_lookup ON public.user_hidden_media(user_id, tmdb_id, content_type);

-- RLS
ALTER TABLE public.user_hidden_media ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own hidden media"
    ON public.user_hidden_media FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can hide media"
    ON public.user_hidden_media FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unhide media"
    ON public.user_hidden_media FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- FUNCIONES
-- =====================================================

-- Ocultar un item
CREATE OR REPLACE FUNCTION public.hide_media(
    p_tmdb_id INTEGER,
    p_content_type content_type
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    INSERT INTO public.user_hidden_media (user_id, tmdb_id, content_type)
    VALUES (auth.uid(), p_tmdb_id, p_content_type)
    ON CONFLICT (user_id, tmdb_id, content_type) DO NOTHING;
END;
$$;

-- Desocultar un item (undo)
CREATE OR REPLACE FUNCTION public.unhide_media(
    p_tmdb_id INTEGER,
    p_content_type content_type
)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    DELETE FROM public.user_hidden_media
    WHERE user_id = auth.uid()
      AND tmdb_id = p_tmdb_id
      AND content_type = p_content_type;
END;
$$;

-- Obtener lista de IDs ocultos (para filtrar en cliente)
CREATE OR REPLACE FUNCTION public.get_hidden_media_ids()
RETURNS TABLE (tmdb_id INTEGER, content_type content_type)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT h.tmdb_id, h.content_type
    FROM public.user_hidden_media h
    WHERE h.user_id = auth.uid();
END;
$$;

-- Verificar si un item está oculto
CREATE OR REPLACE FUNCTION public.is_media_hidden(
    p_tmdb_id INTEGER,
    p_content_type content_type
)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_hidden_media
        WHERE user_id = auth.uid()
          AND tmdb_id = p_tmdb_id
          AND content_type = p_content_type
    );
END;
$$;
