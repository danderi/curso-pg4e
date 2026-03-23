-- =========================================
-- 🧠 PASO 1: Crear tabla
-- =========================================

CREATE TABLE docs03 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

-- =========================================
-- 🧠 PASO 2: Insertar documentos base
-- =========================================

INSERT INTO docs03 (doc) VALUES
('as an intermediary between you the end user and me the programmer'),
('Python is a way for us to exchange useful instruction sequences ie'),
('programs in a common language that can be used by anyone who installs'),
('Python on their computer So neither of us are talking to'),
('Python instead we are communicating with each other'),
('The building blocks of programs'),
('In the next few chapters we will learn more about the vocabulary'),
('sentence structure paragraph structure and story structure of Python'),
('We will learn about the powerful capabilities of Python and how to'),
('compose those capabilities together to create useful programs');

-- =========================================
-- 🧠 PASO 3: Crear índice GIN para Full Text Search
-- =========================================

-- 🔥 Convierte texto en estructura optimizada para búsqueda
-- y crea un índice invertido automáticamente
CREATE INDEX fulltext03 
ON docs03 
USING gin(to_tsvector('english', doc));

-- =========================================
-- 🧠 PASO 4: Insertar muchos datos (forzar uso del índice)
-- =========================================

-- 💡 Esto hace que PostgreSQL prefiera usar el índice
INSERT INTO docs03 (doc)
SELECT 'Neon ' || generate_series(10000,20000);

-- =========================================
-- 🧠 PASO 5: Query de búsqueda inteligente
-- =========================================

-- 🔍 Busca documentos que contengan la idea "communicating"
-- (no importa si cambia la forma de la palabra)
SELECT id, doc 
FROM docs03 
WHERE to_tsquery('english', 'communicating') 
@@ to_tsvector('english', doc);

-- =========================================
-- 🧠 PASO 6: Verificar uso del índice
-- =========================================

EXPLAIN
SELECT id, doc 
FROM docs03 
WHERE to_tsquery('english', 'communicating') 
@@ to_tsvector('english', doc);

-- =========================================
-- 🧠 EXPLICACIÓN GENERAL
-- =========================================

-- 1. to_tsvector('english', doc)
--    → convierte texto en palabras clave (sin stop words + con stemming)
--
-- 2. to_tsquery('english', 'communicating')
--    → convierte la búsqueda en su raíz ('commun')
--
-- 3. @@
--    → compara si el documento contiene esa idea
--
-- 4. GIN INDEX
--    → crea un índice invertido (palabra → documentos)
--
-- 5. EXPLAIN
--    → verifica si usa:
--       ❌ Seq Scan (lento)
--       ✅ Bitmap Index Scan (rápido)
--
-- 💀 Esto es básicamente cómo funcionan los buscadores reales