-- ============================================================================
-- DELETE ACCOUNT
-- Permite al usuario eliminar completamente su cuenta y datos
-- ============================================================================

-- Función para eliminar la cuenta del usuario actual
-- Debe ejecutarse como el usuario autenticado
CREATE OR REPLACE FUNCTION public.delete_my_account()
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
    v_user_id UUID;
    v_deleted_counts JSONB;
BEGIN
    -- Obtener el usuario actual
    v_user_id := auth.uid();

    IF v_user_id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'No authenticated user'
        );
    END IF;

    -- Contar datos antes de eliminar (para confirmación)
    SELECT jsonb_build_object(
        'profiles', (SELECT COUNT(*) FROM public.profiles WHERE id = v_user_id),
        'movie_states', (SELECT COUNT(*) FROM public.user_movie_state WHERE user_id = v_user_id),
        'ratings', (SELECT COUNT(*) FROM public.user_ratings WHERE user_id = v_user_id),
        'lists', (SELECT COUNT(*) FROM public.user_lists WHERE user_id = v_user_id),
        'chat_threads', (SELECT COUNT(*) FROM public.chat_threads WHERE user_id = v_user_id),
        'ai_usage', (SELECT COUNT(*) FROM public.ai_usage WHERE user_id = v_user_id),
        'hidden_media', (SELECT COUNT(*) FROM public.user_hidden_media WHERE user_id = v_user_id)
    ) INTO v_deleted_counts;

    -- Eliminar datos manualmente (aunque CASCADE lo haría, esto es más explícito)
    -- El orden importa por las foreign keys

    -- 1. Eliminar items de listas (cascade desde user_lists)
    DELETE FROM public.user_list_items
    WHERE list_id IN (SELECT id FROM public.user_lists WHERE user_id = v_user_id);

    -- 2. Eliminar listas
    DELETE FROM public.user_lists WHERE user_id = v_user_id;

    -- 3. Eliminar estados de películas
    DELETE FROM public.user_movie_state WHERE user_id = v_user_id;

    -- 4. Eliminar ratings
    DELETE FROM public.user_ratings WHERE user_id = v_user_id;

    -- 5. Eliminar mensajes de chat (cascade desde threads)
    DELETE FROM public.chat_messages
    WHERE thread_id IN (SELECT id FROM public.chat_threads WHERE user_id = v_user_id);

    -- 6. Eliminar threads de chat
    DELETE FROM public.chat_threads WHERE user_id = v_user_id;

    -- 7. Eliminar uso de IA
    DELETE FROM public.ai_usage WHERE user_id = v_user_id;

    -- 8. Eliminar media oculto
    DELETE FROM public.user_hidden_media WHERE user_id = v_user_id;

    -- 9. Eliminar perfil
    DELETE FROM public.profiles WHERE id = v_user_id;

    -- 10. Eliminar usuario de auth (requiere service_role, ver nota abajo)
    -- Esta parte se debe hacer desde el cliente con signOut + Edge Function
    -- o usando supabase.auth.admin.deleteUser() desde el servidor

    RETURN jsonb_build_object(
        'success', true,
        'deleted', v_deleted_counts,
        'message', 'User data deleted. Call auth signOut to complete.'
    );
END;
$$;

-- Comentario
COMMENT ON FUNCTION public.delete_my_account IS 'Elimina todos los datos del usuario actual. El usuario debe cerrar sesión después.';

-- Dar permisos a usuarios autenticados
GRANT EXECUTE ON FUNCTION public.delete_my_account TO authenticated;
