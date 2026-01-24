-- ============================================================================
-- CHAT PERSISTENCE
-- Persistir conversaciones del asistente IA
-- ============================================================================

-- Tabla de threads (conversaciones)
CREATE TABLE IF NOT EXISTS chat_threads (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    title TEXT, -- Título auto-generado del primer mensaje
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para obtener threads de un usuario ordenados
CREATE INDEX IF NOT EXISTS idx_chat_threads_user_updated
    ON chat_threads(user_id, updated_at DESC);

-- Tabla de mensajes
CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id UUID NOT NULL REFERENCES chat_threads(id) ON DELETE CASCADE,
    role TEXT NOT NULL CHECK (role IN ('user', 'assistant')),
    content TEXT NOT NULL,
    meta_json JSONB, -- picks, quick_replies, etc.
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índice para obtener mensajes de un thread ordenados
CREATE INDEX IF NOT EXISTS idx_chat_messages_thread_created
    ON chat_messages(thread_id, created_at ASC);

-- ============================================================================
-- TRIGGER: Actualizar updated_at del thread
-- ============================================================================
CREATE OR REPLACE FUNCTION update_thread_timestamp()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    UPDATE chat_threads
    SET updated_at = NOW()
    WHERE id = NEW.thread_id;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_chat_message_update_thread
    AFTER INSERT ON chat_messages
    FOR EACH ROW
    EXECUTE FUNCTION update_thread_timestamp();

-- ============================================================================
-- FUNCIÓN: Obtener o crear thread activo del usuario
-- Retorna el thread más reciente o crea uno nuevo
-- ============================================================================
CREATE OR REPLACE FUNCTION get_or_create_chat_thread(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_thread_id UUID;
BEGIN
    -- Buscar thread activo (actualizado en las últimas 24h)
    SELECT id INTO v_thread_id
    FROM chat_threads
    WHERE user_id = p_user_id
      AND updated_at > NOW() - INTERVAL '24 hours'
    ORDER BY updated_at DESC
    LIMIT 1;

    -- Si no existe, crear uno nuevo
    IF v_thread_id IS NULL THEN
        INSERT INTO chat_threads (user_id)
        VALUES (p_user_id)
        RETURNING id INTO v_thread_id;
    END IF;

    RETURN v_thread_id;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Cargar mensajes de un thread
-- ============================================================================
CREATE OR REPLACE FUNCTION load_chat_messages(
    p_thread_id UUID,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    id UUID,
    role TEXT,
    content TEXT,
    meta_json JSONB,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    SELECT
        cm.id,
        cm.role,
        cm.content,
        cm.meta_json,
        cm.created_at
    FROM chat_messages cm
    WHERE cm.thread_id = p_thread_id
    ORDER BY cm.created_at ASC
    LIMIT p_limit;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Guardar mensaje
-- ============================================================================
CREATE OR REPLACE FUNCTION save_chat_message(
    p_thread_id UUID,
    p_role TEXT,
    p_content TEXT,
    p_meta_json JSONB DEFAULT NULL
)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_message_id UUID;
BEGIN
    INSERT INTO chat_messages (thread_id, role, content, meta_json)
    VALUES (p_thread_id, p_role, p_content, p_meta_json)
    RETURNING id INTO v_message_id;

    -- Actualizar título del thread si es el primer mensaje del usuario
    IF p_role = 'user' THEN
        UPDATE chat_threads
        SET title = COALESCE(title, LEFT(p_content, 50))
        WHERE id = p_thread_id AND title IS NULL;
    END IF;

    RETURN v_message_id;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Limpiar threads antiguos (>30 días sin actividad)
-- ============================================================================
CREATE OR REPLACE FUNCTION clean_old_chat_threads()
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_deleted INT;
BEGIN
    DELETE FROM chat_threads
    WHERE updated_at < NOW() - INTERVAL '30 days';

    GET DIAGNOSTICS v_deleted = ROW_COUNT;
    RETURN v_deleted;
END;
$$;

-- ============================================================================
-- FUNCIÓN: Iniciar nuevo thread (forzar)
-- ============================================================================
CREATE OR REPLACE FUNCTION start_new_chat_thread(p_user_id UUID)
RETURNS UUID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_thread_id UUID;
BEGIN
    INSERT INTO chat_threads (user_id)
    VALUES (p_user_id)
    RETURNING id INTO v_thread_id;

    RETURN v_thread_id;
END;
$$;

-- ============================================================================
-- RLS POLICIES
-- ============================================================================
ALTER TABLE chat_threads ENABLE ROW LEVEL SECURITY;
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

-- Usuarios solo ven sus propios threads
CREATE POLICY "Users can view own threads"
    ON chat_threads
    FOR SELECT
    TO authenticated
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own threads"
    ON chat_threads
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own threads"
    ON chat_threads
    FOR DELETE
    TO authenticated
    USING (auth.uid() = user_id);

-- Usuarios solo ven mensajes de sus threads
CREATE POLICY "Users can view own messages"
    ON chat_messages
    FOR SELECT
    TO authenticated
    USING (
        thread_id IN (
            SELECT id FROM chat_threads WHERE user_id = auth.uid()
        )
    );

CREATE POLICY "Users can insert messages to own threads"
    ON chat_messages
    FOR INSERT
    TO authenticated
    WITH CHECK (
        thread_id IN (
            SELECT id FROM chat_threads WHERE user_id = auth.uid()
        )
    );

-- Service role tiene acceso completo
CREATE POLICY "Service role full access to threads"
    ON chat_threads
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

CREATE POLICY "Service role full access to messages"
    ON chat_messages
    FOR ALL
    TO service_role
    USING (true)
    WITH CHECK (true);

-- ============================================================================
-- COMENTARIOS
-- ============================================================================
COMMENT ON TABLE chat_threads IS 'Conversaciones del asistente IA por usuario';
COMMENT ON TABLE chat_messages IS 'Mensajes individuales de cada conversación';
COMMENT ON COLUMN chat_messages.meta_json IS 'Metadata: picks, quick_replies, etc.';
