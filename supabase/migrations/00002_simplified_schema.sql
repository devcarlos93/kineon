-- =====================================================
-- KINEON DATABASE SCHEMA v2
-- Esquema simplificado con RLS
-- =====================================================

-- Limpiar tablas anteriores si existen (CUIDADO en producción)
DROP TABLE IF EXISTS public.custom_list_items CASCADE;
DROP TABLE IF EXISTS public.custom_lists CASCADE;
DROP TABLE IF EXISTS public.watched CASCADE;
DROP TABLE IF EXISTS public.favorites CASCADE;
DROP TABLE IF EXISTS public.watchlist CASCADE;
DROP TABLE IF EXISTS public.ai_conversations CASCADE;
DROP TABLE IF EXISTS public.profiles CASCADE;

-- Limpiar tipos si existen
DROP TYPE IF EXISTS content_type CASCADE;
DROP TYPE IF EXISTS watch_status CASCADE;

-- =====================================================
-- TIPOS ENUMERADOS
-- =====================================================

CREATE TYPE content_type AS ENUM ('movie', 'tv');
CREATE TYPE watch_status AS ENUM ('watchlist', 'watching', 'watched', 'dropped', 'on_hold');

-- =====================================================
-- TABLA: profiles
-- Perfil extendido del usuario
-- =====================================================

CREATE TABLE public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    username TEXT UNIQUE,
    display_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    
    -- Preferencias
    preferred_language TEXT DEFAULT 'es',
    include_adult BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_profiles_username ON public.profiles(username) WHERE username IS NOT NULL;

-- Trigger para crear perfil automáticamente
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.profiles (id, display_name, avatar_url)
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data->>'full_name',
            NEW.raw_user_meta_data->>'name',
            split_part(NEW.email, '@', 1)
        ),
        NEW.raw_user_meta_data->>'avatar_url'
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- RLS
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Perfiles visibles públicamente"
    ON public.profiles FOR SELECT
    USING (true);

CREATE POLICY "Usuarios editan su perfil"
    ON public.profiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- =====================================================
-- TABLA: user_movie_state
-- Estado de películas/series del usuario
-- Combina watchlist, watching, watched, etc.
-- =====================================================

CREATE TABLE public.user_movie_state (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Contenido TMDB
    tmdb_id INT NOT NULL,
    content_type content_type NOT NULL,
    
    -- Estado
    status watch_status NOT NULL DEFAULT 'watchlist',
    is_favorite BOOLEAN NOT NULL DEFAULT false,
    
    -- Progreso (para series)
    current_season INT,
    current_episode INT,
    
    -- Timestamps
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Constraint único: un usuario solo puede tener un estado por contenido
    CONSTRAINT uq_user_movie_state UNIQUE (user_id, tmdb_id, content_type)
);

-- Índices para queries comunes
CREATE INDEX idx_ums_user_id ON public.user_movie_state(user_id);
CREATE INDEX idx_ums_user_status ON public.user_movie_state(user_id, status);
CREATE INDEX idx_ums_user_favorite ON public.user_movie_state(user_id, is_favorite) WHERE is_favorite = true;
CREATE INDEX idx_ums_tmdb ON public.user_movie_state(tmdb_id, content_type);
CREATE INDEX idx_ums_updated ON public.user_movie_state(updated_at DESC);

-- RLS
ALTER TABLE public.user_movie_state ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Usuarios ven su estado"
    ON public.user_movie_state FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios crean su estado"
    ON public.user_movie_state FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan su estado"
    ON public.user_movie_state FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan su estado"
    ON public.user_movie_state FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: user_ratings
-- Calificaciones y reseñas
-- =====================================================

CREATE TABLE public.user_ratings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Contenido TMDB
    tmdb_id INT NOT NULL,
    content_type content_type NOT NULL,
    
    -- Rating (1-10, permite medios como 7.5)
    rating DECIMAL(3,1) NOT NULL CHECK (rating >= 1 AND rating <= 10),
    
    -- Reseña opcional
    review TEXT,
    contains_spoilers BOOLEAN DEFAULT false,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Un usuario solo puede calificar una vez por contenido
    CONSTRAINT uq_user_rating UNIQUE (user_id, tmdb_id, content_type)
);

-- Índices
CREATE INDEX idx_ratings_user ON public.user_ratings(user_id);
CREATE INDEX idx_ratings_tmdb ON public.user_ratings(tmdb_id, content_type);
CREATE INDEX idx_ratings_score ON public.user_ratings(rating DESC);
CREATE INDEX idx_ratings_recent ON public.user_ratings(created_at DESC);

-- RLS
ALTER TABLE public.user_ratings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Ratings públicos para lectura"
    ON public.user_ratings FOR SELECT
    USING (true);

CREATE POLICY "Usuarios crean sus ratings"
    ON public.user_ratings FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan sus ratings"
    ON public.user_ratings FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan sus ratings"
    ON public.user_ratings FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: user_lists
-- Listas personalizadas
-- =====================================================

CREATE TABLE public.user_lists (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    
    -- Info de la lista
    name TEXT NOT NULL CHECK (char_length(name) >= 1 AND char_length(name) <= 100),
    description TEXT CHECK (char_length(description) <= 500),
    
    -- Configuración
    is_public BOOLEAN NOT NULL DEFAULT false,
    is_ranked BOOLEAN NOT NULL DEFAULT false, -- Si el orden importa (ranking)
    
    -- Cover (poster de la primera película o custom)
    cover_tmdb_id INT,
    cover_type content_type,
    
    -- Timestamps
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Índices
CREATE INDEX idx_lists_user ON public.user_lists(user_id);
CREATE INDEX idx_lists_public ON public.user_lists(is_public, updated_at DESC) WHERE is_public = true;
CREATE INDEX idx_lists_updated ON public.user_lists(updated_at DESC);

-- RLS
ALTER TABLE public.user_lists ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Listas públicas visibles"
    ON public.user_lists FOR SELECT
    USING (is_public = true OR auth.uid() = user_id);

CREATE POLICY "Usuarios crean listas"
    ON public.user_lists FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios actualizan sus listas"
    ON public.user_lists FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Usuarios eliminan sus listas"
    ON public.user_lists FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- TABLA: user_list_items
-- Items dentro de listas
-- =====================================================

CREATE TABLE public.user_list_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    list_id UUID NOT NULL REFERENCES public.user_lists(id) ON DELETE CASCADE,
    
    -- Contenido TMDB
    tmdb_id INT NOT NULL,
    content_type content_type NOT NULL,
    
    -- Orden (para listas rankeadas)
    position INT NOT NULL DEFAULT 0,
    
    -- Nota personal (ej: "Mi favorita de Nolan")
    note TEXT CHECK (char_length(note) <= 280),
    
    -- Timestamps
    added_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    
    -- Un item solo puede estar una vez en cada lista
    CONSTRAINT uq_list_item UNIQUE (list_id, tmdb_id, content_type)
);

-- Índices
CREATE INDEX idx_list_items_list ON public.user_list_items(list_id, position);
CREATE INDEX idx_list_items_tmdb ON public.user_list_items(tmdb_id, content_type);

-- RLS
ALTER TABLE public.user_list_items ENABLE ROW LEVEL SECURITY;

-- Función helper para verificar ownership
CREATE OR REPLACE FUNCTION public.owns_list(list_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_lists
        WHERE id = list_id AND user_id = auth.uid()
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Función helper para verificar si lista es pública
CREATE OR REPLACE FUNCTION public.list_is_public(list_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_lists
        WHERE id = list_id AND is_public = true
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE POLICY "Items visibles si lista pública o propia"
    ON public.user_list_items FOR SELECT
    USING (
        public.owns_list(list_id) OR 
        public.list_is_public(list_id)
    );

CREATE POLICY "Usuarios agregan a sus listas"
    ON public.user_list_items FOR INSERT
    WITH CHECK (public.owns_list(list_id));

CREATE POLICY "Usuarios actualizan items de sus listas"
    ON public.user_list_items FOR UPDATE
    USING (public.owns_list(list_id))
    WITH CHECK (public.owns_list(list_id));

CREATE POLICY "Usuarios eliminan items de sus listas"
    ON public.user_list_items FOR DELETE
    USING (public.owns_list(list_id));

-- =====================================================
-- FUNCIONES DE UTILIDAD
-- =====================================================

-- Actualizar updated_at automáticamente
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Triggers de updated_at
CREATE TRIGGER trg_profiles_updated
    BEFORE UPDATE ON public.profiles
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_movie_state_updated
    BEFORE UPDATE ON public.user_movie_state
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_ratings_updated
    BEFORE UPDATE ON public.user_ratings
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER trg_user_lists_updated
    BEFORE UPDATE ON public.user_lists
    FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Actualizar cover de lista al agregar primer item
CREATE OR REPLACE FUNCTION public.update_list_cover()
RETURNS TRIGGER AS $$
BEGIN
    -- Solo actualizar si la lista no tiene cover
    UPDATE public.user_lists
    SET cover_tmdb_id = NEW.tmdb_id,
        cover_type = NEW.content_type,
        updated_at = NOW()
    WHERE id = NEW.list_id
      AND cover_tmdb_id IS NULL;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_list_item_cover
    AFTER INSERT ON public.user_list_items
    FOR EACH ROW EXECUTE FUNCTION public.update_list_cover();

-- =====================================================
-- VISTAS ÚTILES
-- =====================================================

-- Estadísticas del usuario
CREATE OR REPLACE VIEW public.user_stats AS
SELECT 
    p.id AS user_id,
    p.display_name,
    p.avatar_url,
    (SELECT COUNT(*) FROM public.user_movie_state WHERE user_id = p.id AND status = 'watched') AS movies_watched,
    (SELECT COUNT(*) FROM public.user_movie_state WHERE user_id = p.id AND status = 'watchlist') AS in_watchlist,
    (SELECT COUNT(*) FROM public.user_movie_state WHERE user_id = p.id AND is_favorite = true) AS favorites_count,
    (SELECT COUNT(*) FROM public.user_ratings WHERE user_id = p.id) AS ratings_count,
    (SELECT AVG(rating) FROM public.user_ratings WHERE user_id = p.id) AS avg_rating,
    (SELECT COUNT(*) FROM public.user_lists WHERE user_id = p.id) AS lists_count
FROM public.profiles p;

-- =====================================================
-- COMENTARIOS
-- =====================================================

COMMENT ON TABLE public.profiles IS 'Perfiles de usuario con preferencias';
COMMENT ON TABLE public.user_movie_state IS 'Estado de películas/series: watchlist, watching, watched, favoritos';
COMMENT ON TABLE public.user_ratings IS 'Calificaciones y reseñas de usuarios';
COMMENT ON TABLE public.user_lists IS 'Listas personalizadas de usuarios';
COMMENT ON TABLE public.user_list_items IS 'Contenido dentro de las listas';

COMMENT ON TYPE content_type IS 'Tipo de contenido: movie o tv';
COMMENT ON TYPE watch_status IS 'Estado de visualización';

-- =====================================================
-- DATOS DE EJEMPLO (opcional, comentar en producción)
-- =====================================================

/*
-- Crear lista de ejemplo para testing
INSERT INTO public.user_lists (user_id, name, description, is_public)
SELECT id, 'Películas favoritas', 'Mis películas de todos los tiempos', true
FROM auth.users LIMIT 1;
*/
