-- =====================================================
-- KINEON: ROW LEVEL SECURITY (RLS) POLICIES
-- Cada usuario solo puede acceder a sus propios datos
-- =====================================================

-- =====================================================
-- 0. LIMPIAR POLÍTICAS Y FUNCIONES EXISTENTES
-- =====================================================

-- Eliminar políticas existentes de user_list_items
DROP POLICY IF EXISTS "Items visibles si lista pública o propia" ON public.user_list_items;
DROP POLICY IF EXISTS "Usuarios agregan a sus listas" ON public.user_list_items;
DROP POLICY IF EXISTS "Usuarios actualizan items de sus listas" ON public.user_list_items;
DROP POLICY IF EXISTS "Usuarios eliminan items de sus listas" ON public.user_list_items;
DROP POLICY IF EXISTS "list_items_select" ON public.user_list_items;
DROP POLICY IF EXISTS "list_items_insert_own" ON public.user_list_items;
DROP POLICY IF EXISTS "list_items_update_own" ON public.user_list_items;
DROP POLICY IF EXISTS "list_items_delete_own" ON public.user_list_items;

-- Eliminar políticas existentes de user_lists
DROP POLICY IF EXISTS "Listas públicas visibles" ON public.user_lists;
DROP POLICY IF EXISTS "Usuarios crean listas" ON public.user_lists;
DROP POLICY IF EXISTS "Usuarios actualizan sus listas" ON public.user_lists;
DROP POLICY IF EXISTS "Usuarios eliminan sus listas" ON public.user_lists;
DROP POLICY IF EXISTS "lists_select_own_or_public" ON public.user_lists;
DROP POLICY IF EXISTS "lists_insert_own" ON public.user_lists;
DROP POLICY IF EXISTS "lists_update_own" ON public.user_lists;
DROP POLICY IF EXISTS "lists_delete_own" ON public.user_lists;

-- Eliminar políticas existentes de user_ratings
DROP POLICY IF EXISTS "Ratings públicos para lectura" ON public.user_ratings;
DROP POLICY IF EXISTS "Usuarios crean sus ratings" ON public.user_ratings;
DROP POLICY IF EXISTS "Usuarios actualizan sus ratings" ON public.user_ratings;
DROP POLICY IF EXISTS "Usuarios eliminan sus ratings" ON public.user_ratings;
DROP POLICY IF EXISTS "ratings_select_public" ON public.user_ratings;
DROP POLICY IF EXISTS "ratings_insert_own" ON public.user_ratings;
DROP POLICY IF EXISTS "ratings_update_own" ON public.user_ratings;
DROP POLICY IF EXISTS "ratings_delete_own" ON public.user_ratings;

-- Eliminar políticas existentes de user_movie_state
DROP POLICY IF EXISTS "Usuarios ven su estado" ON public.user_movie_state;
DROP POLICY IF EXISTS "Usuarios crean su estado" ON public.user_movie_state;
DROP POLICY IF EXISTS "Usuarios actualizan su estado" ON public.user_movie_state;
DROP POLICY IF EXISTS "Usuarios eliminan su estado" ON public.user_movie_state;
DROP POLICY IF EXISTS "ums_select_own" ON public.user_movie_state;
DROP POLICY IF EXISTS "ums_insert_own" ON public.user_movie_state;
DROP POLICY IF EXISTS "ums_update_own" ON public.user_movie_state;
DROP POLICY IF EXISTS "ums_delete_own" ON public.user_movie_state;

-- Eliminar políticas existentes de profiles
DROP POLICY IF EXISTS "Perfiles visibles públicamente" ON public.profiles;
DROP POLICY IF EXISTS "Usuarios editan su perfil" ON public.profiles;
DROP POLICY IF EXISTS "Usuarios pueden ver perfiles públicos" ON public.profiles;
DROP POLICY IF EXISTS "Usuarios pueden actualizar su propio perfil" ON public.profiles;
DROP POLICY IF EXISTS "profiles_select_public" ON public.profiles;
DROP POLICY IF EXISTS "profiles_update_own" ON public.profiles;

-- Ahora sí eliminar funciones
DROP FUNCTION IF EXISTS public.owns_list(UUID);
DROP FUNCTION IF EXISTS public.list_is_public(UUID);
DROP FUNCTION IF EXISTS public.is_list_owner(UUID);
DROP FUNCTION IF EXISTS public.is_list_public(UUID);

-- =====================================================
-- 1. PROFILES
-- =====================================================

-- Habilitar RLS (bloquea todo por defecto)
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- SELECT: Perfiles son públicos (para mostrar nombre/avatar en listas compartidas)
-- ✅ SEGURO: Solo expone datos no sensibles (display_name, avatar)
CREATE POLICY "profiles_select_public"
    ON public.profiles
    FOR SELECT
    USING (true);

-- INSERT: No permitido directamente (se crea via trigger al registrarse)
-- ✅ SEGURO: El trigger handle_new_user() crea el perfil automáticamente
-- No necesitamos policy de INSERT

-- UPDATE: Solo el propietario puede editar su perfil
-- ✅ SEGURO: auth.uid() garantiza que solo el usuario autenticado modifica sus datos
CREATE POLICY "profiles_update_own"
    ON public.profiles
    FOR UPDATE
    USING (auth.uid() = id)          -- Solo si es mi perfil
    WITH CHECK (auth.uid() = id);    -- Solo puedo actualizarlo a mi propio id

-- DELETE: No permitido (el perfil se elimina en cascada con auth.users)
-- ✅ SEGURO: ON DELETE CASCADE en la FK maneja esto automáticamente

-- =====================================================
-- 2. USER_MOVIE_STATE (watchlist, favoritos, etc.)
-- =====================================================

ALTER TABLE public.user_movie_state ENABLE ROW LEVEL SECURITY;

-- SELECT: Solo ver mis estados
-- ✅ SEGURO: Cada usuario solo ve su watchlist/favoritos
CREATE POLICY "ums_select_own"
    ON public.user_movie_state
    FOR SELECT
    USING (auth.uid() = user_id);

-- INSERT: Solo crear estados para mí mismo
-- ✅ SEGURO: WITH CHECK previene que alguien inserte con otro user_id
CREATE POLICY "ums_insert_own"
    ON public.user_movie_state
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Solo actualizar mis estados
-- ✅ SEGURO: No puedo modificar el user_id a otro usuario (WITH CHECK)
CREATE POLICY "ums_update_own"
    ON public.user_movie_state
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Solo eliminar mis estados
-- ✅ SEGURO: Solo puedo quitar películas de MI watchlist
CREATE POLICY "ums_delete_own"
    ON public.user_movie_state
    FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- 3. USER_RATINGS (calificaciones y reseñas)
-- =====================================================

ALTER TABLE public.user_ratings ENABLE ROW LEVEL SECURITY;

-- SELECT: Ratings son públicos (para mostrar calificaciones de la comunidad)
-- ✅ SEGURO: Las reseñas son contenido público por diseño
-- ⚠️ Si quieres ratings privados, cambia a: USING (auth.uid() = user_id)
CREATE POLICY "ratings_select_public"
    ON public.user_ratings
    FOR SELECT
    USING (true);

-- INSERT: Solo crear ratings para mí mismo
-- ✅ SEGURO: No puedo crear reseñas a nombre de otro usuario
CREATE POLICY "ratings_insert_own"
    ON public.user_ratings
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Solo editar mis ratings
-- ✅ SEGURO: No puedo modificar reseñas de otros
CREATE POLICY "ratings_update_own"
    ON public.user_ratings
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Solo eliminar mis ratings
-- ✅ SEGURO: Solo puedo borrar MIS reseñas
CREATE POLICY "ratings_delete_own"
    ON public.user_ratings
    FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- 4. USER_LISTS (listas personalizadas)
-- =====================================================

ALTER TABLE public.user_lists ENABLE ROW LEVEL SECURITY;

-- SELECT: Ver mis listas + listas públicas de otros
-- ✅ SEGURO: Respeta la configuración is_public del creador
CREATE POLICY "lists_select_own_or_public"
    ON public.user_lists
    FOR SELECT
    USING (
        auth.uid() = user_id    -- Mis listas (públicas o privadas)
        OR is_public = true     -- Listas públicas de otros
    );

-- INSERT: Solo crear listas para mí mismo
-- ✅ SEGURO: No puedo crear listas a nombre de otro
CREATE POLICY "lists_insert_own"
    ON public.user_lists
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- UPDATE: Solo editar mis listas
-- ✅ SEGURO: No puedo editar listas de otros ni cambiar el owner
CREATE POLICY "lists_update_own"
    ON public.user_lists
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- DELETE: Solo eliminar mis listas
-- ✅ SEGURO: No puedo borrar listas de otros
CREATE POLICY "lists_delete_own"
    ON public.user_lists
    FOR DELETE
    USING (auth.uid() = user_id);

-- =====================================================
-- 5. USER_LIST_ITEMS (items de listas)
-- =====================================================

ALTER TABLE public.user_list_items ENABLE ROW LEVEL SECURITY;

-- Funciones helper
CREATE OR REPLACE FUNCTION public.owns_list(p_list_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER  -- Ejecuta con permisos del creador, no del caller
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.user_lists
        WHERE id = p_list_id AND user_id = auth.uid()
    );
$$;

CREATE OR REPLACE FUNCTION public.list_is_public(p_list_id UUID)
RETURNS BOOLEAN
LANGUAGE sql
SECURITY DEFINER
SET search_path = public
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.user_lists
        WHERE id = p_list_id AND is_public = true
    );
$$;

-- SELECT: Ver items de mis listas o listas públicas
-- ✅ SEGURO: Usa funciones SECURITY DEFINER para verificar ownership
CREATE POLICY "list_items_select"
    ON public.user_list_items
    FOR SELECT
    USING (
        public.owns_list(list_id)        -- Es mi lista
        OR public.list_is_public(list_id) -- O es pública
    );

-- INSERT: Solo agregar items a MIS listas
-- ✅ SEGURO: No puedo agregar películas a listas de otros
CREATE POLICY "list_items_insert_own"
    ON public.user_list_items
    FOR INSERT
    WITH CHECK (public.owns_list(list_id));

-- UPDATE: Solo modificar items de MIS listas
-- ✅ SEGURO: No puedo editar notas en listas ajenas
CREATE POLICY "list_items_update_own"
    ON public.user_list_items
    FOR UPDATE
    USING (public.owns_list(list_id))
    WITH CHECK (public.owns_list(list_id));

-- DELETE: Solo eliminar items de MIS listas
-- ✅ SEGURO: No puedo quitar películas de listas de otros
CREATE POLICY "list_items_delete_own"
    ON public.user_list_items
    FOR DELETE
    USING (public.owns_list(list_id));

-- =====================================================
-- VERIFICACIÓN: Listar todas las políticas creadas
-- =====================================================

/*
-- Ejecuta esto para verificar las políticas:
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies 
WHERE schemaname = 'public'
ORDER BY tablename, cmd;
*/

-- =====================================================
-- NOTAS DE SEGURIDAD
-- =====================================================

/*
🔐 PRINCIPIOS APLICADOS:

1. DENY BY DEFAULT
   - RLS habilitado = todo bloqueado hasta que una policy lo permita
   - Si no hay policy, no hay acceso

2. LEAST PRIVILEGE
   - Cada usuario solo accede a lo mínimo necesario
   - Datos privados → solo el owner
   - Datos públicos → lectura para todos

3. auth.uid() ES LA CLAVE
   - Supabase inyecta el user_id del JWT automáticamente
   - No se puede falsificar desde el cliente
   - Si no hay sesión, auth.uid() = NULL → no matchea nada

4. SECURITY DEFINER EN FUNCIONES
   - Las funciones owns_list() y list_is_public() se ejecutan
     con permisos elevados para poder consultar user_lists
   - Previene ataques de inferencia

5. WITH CHECK EN INSERT/UPDATE
   - USING: filtra qué filas puedo ver/modificar
   - WITH CHECK: valida qué valores puedo escribir
   - Previene que cambie user_id a otro usuario

⚠️ POSIBLES VECTORES DE ATAQUE MITIGADOS:

- IDOR (Insecure Direct Object Reference): 
  ✅ Mitigado con auth.uid() = user_id

- Mass Assignment:
  ✅ WITH CHECK previene cambiar user_id

- Privilege Escalation:
  ✅ No hay forma de acceder a datos de otros

- Information Disclosure:
  ✅ Datos sensibles solo visibles al owner
*/
