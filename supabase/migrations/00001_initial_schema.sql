-- =====================================================
-- KINEON DATABASE SCHEMA
-- Esquema inicial con Row Level Security (RLS)
-- =====================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLA: profiles
-- Perfiles de usuario (extensión de auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Trigger para crear perfil automáticamente al registrarse
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- RLS para profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver perfiles públicos"
    ON public.profiles FOR SELECT
    USING (true);

CREATE POLICY "Usuarios pueden actualizar su propio perfil"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- =====================================================
-- TABLA: watchlist
-- Lista de contenido por ver
-- =====================================================
CREATE TABLE IF NOT EXISTS public.watchlist (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    content_type TEXT NOT NULL CHECK (content_type IN ('movie', 'tv')),
    status TEXT NOT NULL DEFAULT 'plan_to_watch' CHECK (status IN ('plan_to_watch', 'watching', 'completed', 'dropped', 'on_hold')),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Índice único para evitar duplicados
    UNIQUE(user_id, tmdb_id, content_type)
);

-- Índices para mejor rendimiento
CREATE INDEX IF NOT EXISTS idx_watchlist_user_id ON public.watchlist(user_id);
CREATE INDEX IF NOT EXISTS idx_watchlist_status ON public.watchlist(status);

-- RLS para watchlist
ALTER TABLE public.watchlist ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver su propia watchlist"
    ON public.watchlist FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden agregar a su watchlist"
    ON public.watchlist FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden actualizar su watchlist"
    ON public.watchlist FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar de su watchlist"
    ON public.watchlist FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: favorites
-- Contenido favorito
-- =====================================================
CREATE TABLE IF NOT EXISTS public.favorites (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    content_type TEXT NOT NULL CHECK (content_type IN ('movie', 'tv')),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    
    UNIQUE(user_id, tmdb_id, content_type)
);

CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);

-- RLS para favorites
ALTER TABLE public.favorites ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver sus favoritos"
    ON public.favorites FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden agregar favoritos"
    ON public.favorites FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar favoritos"
    ON public.favorites FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: watched
-- Contenido visto con calificación opcional
-- =====================================================
CREATE TABLE IF NOT EXISTS public.watched (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    content_type TEXT NOT NULL CHECK (content_type IN ('movie', 'tv')),
    watched_at TIMESTAMPTZ DEFAULT NOW(),
    rating INTEGER CHECK (rating >= 1 AND rating <= 10),
    review TEXT,
    
    UNIQUE(user_id, tmdb_id, content_type)
);

CREATE INDEX IF NOT EXISTS idx_watched_user_id ON public.watched(user_id);
CREATE INDEX IF NOT EXISTS idx_watched_rating ON public.watched(rating);

-- RLS para watched
ALTER TABLE public.watched ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver su historial"
    ON public.watched FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden agregar a historial"
    ON public.watched FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden actualizar historial"
    ON public.watched FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar de historial"
    ON public.watched FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: custom_lists
-- Listas personalizadas
-- =====================================================
CREATE TABLE IF NOT EXISTS public.custom_lists (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    description TEXT,
    is_public BOOLEAN DEFAULT FALSE,
    cover_path TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_custom_lists_user_id ON public.custom_lists(user_id);
CREATE INDEX IF NOT EXISTS idx_custom_lists_public ON public.custom_lists(is_public) WHERE is_public = true;

-- RLS para custom_lists
ALTER TABLE public.custom_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver sus listas y listas públicas"
    ON public.custom_lists FOR SELECT
    USING (auth.uid() = user_id OR is_public = true);

CREATE POLICY "Usuarios pueden crear listas"
    ON public.custom_lists FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden actualizar sus listas"
    ON public.custom_lists FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar sus listas"
    ON public.custom_lists FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: custom_list_items
-- Items dentro de listas personalizadas
-- =====================================================
CREATE TABLE IF NOT EXISTS public.custom_list_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    list_id UUID NOT NULL REFERENCES public.custom_lists(id) ON DELETE CASCADE,
    tmdb_id INTEGER NOT NULL,
    content_type TEXT NOT NULL CHECK (content_type IN ('movie', 'tv')),
    added_at TIMESTAMPTZ DEFAULT NOW(),
    "order" INTEGER DEFAULT 0,
    notes TEXT,
    
    UNIQUE(list_id, tmdb_id, content_type)
);

CREATE INDEX IF NOT EXISTS idx_custom_list_items_list_id ON public.custom_list_items(list_id);
CREATE INDEX IF NOT EXISTS idx_custom_list_items_order ON public.custom_list_items("order");

-- RLS para custom_list_items
ALTER TABLE public.custom_list_items ENABLE ROW LEVEL SECURITY;

-- Función para verificar si el usuario es dueño de la lista
CREATE OR REPLACE FUNCTION public.is_list_owner(list_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.custom_lists
        WHERE id = list_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función para verificar si la lista es pública
CREATE OR REPLACE FUNCTION public.is_list_public(list_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.custom_lists
        WHERE id = list_id AND is_public = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Usuarios pueden ver items de sus listas y listas públicas"
    ON public.custom_list_items FOR SELECT
    USING (
        public.is_list_owner(list_id) OR 
        public.is_list_public(list_id)
    );

CREATE POLICY "Usuarios pueden agregar items a sus listas"
    ON public.custom_list_items FOR INSERT
    WITH CHECK (public.is_list_owner(list_id));

CREATE POLICY "Usuarios pueden actualizar items de sus listas"
    ON public.custom_list_items FOR UPDATE
    USING (public.is_list_owner(list_id))
    WITH CHECK (public.is_list_owner(list_id));

CREATE POLICY "Usuarios pueden eliminar items de sus listas"
    ON public.custom_list_items FOR DELETE
    USING (public.is_list_owner(list_id));

-- =====================================================
-- TABLA: ai_conversations
-- Historial de conversaciones con la IA
-- =====================================================
CREATE TABLE IF NOT EXISTS public.ai_conversations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT,
    messages JSONB DEFAULT '[]'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ai_conversations_user_id ON public.ai_conversations(user_id);

-- RLS para ai_conversations
ALTER TABLE public.ai_conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios pueden ver sus conversaciones"
    ON public.ai_conversations FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden crear conversaciones"
    ON public.ai_conversations FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden actualizar sus conversaciones"
    ON public.ai_conversations FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden eliminar sus conversaciones"
    ON public.ai_conversations FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- FUNCIONES DE UTILIDAD
-- =====================================================

-- Función para actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de updated_at
CREATE TRIGGER set_updated_at_profiles
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_watchlist
    BEFORE UPDATE ON public.watchlist
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_custom_lists
    BEFORE UPDATE ON public.custom_lists
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_ai_conversations
    BEFORE UPDATE ON public.ai_conversations
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- =====================================================
-- ESTADÍSTICAS Y VISTAS
-- =====================================================

-- Vista para estadísticas del usuario
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
    p.id as user_id,
    p.display_name,
    (SELECT COUNT(*) FROM public.watchlist w WHERE w.user_id = p.id) as watchlist_count,
    (SELECT COUNT(*) FROM public.favorites f WHERE f.user_id = p.id) as favorites_count,
    (SELECT COUNT(*) FROM public.watched h WHERE h.user_id = p.id) as watched_count,
    (SELECT COUNT(*) FROM public.custom_lists l WHERE l.user_id = p.id) as lists_count,
    (SELECT AVG(rating) FROM public.watched h WHERE h.user_id = p.id AND h.rating IS NOT NULL) as avg_rating
FROM public.profiles p;

-- COMENTARIOS
COMMENT ON TABLE public.profiles IS 'Perfiles extendidos de usuarios';
COMMENT ON TABLE public.watchlist IS 'Lista de contenido pendiente por ver';
COMMENT ON TABLE public.favorites IS 'Contenido marcado como favorito';
COMMENT ON TABLE public.watched IS 'Historial de contenido visto con calificaciones';
COMMENT ON TABLE public.custom_lists IS 'Listas personalizadas creadas por usuarios';
COMMENT ON TABLE public.custom_list_items IS 'Items dentro de las listas personalizadas';
COMMENT ON TABLE public.ai_conversations IS 'Historial de conversaciones con el asistente IA';
