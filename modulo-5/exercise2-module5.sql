-- =========================================
-- 🧠 PASO 1: Crear tablas
-- =========================================

-- Tabla de documentos
CREATE TABLE docs02 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

-- Tabla de índice invertido
CREATE TABLE invert02 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs02(id) ON DELETE CASCADE
);

-- Tabla de stop words (palabras a ignorar)
CREATE TABLE stop_words (
    word TEXT UNIQUE
);

-- =========================================
-- 🧠 PASO 2: Insertar documentos
-- =========================================

INSERT INTO docs02 (doc) VALUES
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
-- 🧠 PASO 3: Insertar stop words
-- =========================================

INSERT INTO stop_words (word) VALUES 
('i'), ('a'), ('about'), ('an'), ('are'), ('as'), ('at'), ('be'), 
('by'), ('com'), ('for'), ('from'), ('how'), ('in'), ('is'), ('it'), ('of'), 
('on'), ('or'), ('that'), ('the'), ('this'), ('to'), ('was'), ('what'), 
('when'), ('where'), ('who'), ('will'), ('with');

-- =========================================
-- 🧠 PASO 4: Limpiar índice invertido
-- =========================================

-- Por si ya ejecutaste antes
DELETE FROM invert02;

-- =========================================
-- 🧠 PASO 5: Construir índice invertido SIN stop words
-- =========================================

INSERT INTO invert02 (keyword, doc_id)
SELECT DISTINCT
       keyword,
       id
FROM (
    -- 🔹 Separar palabras y normalizar (minúsculas)
    SELECT 
        unnest(regexp_split_to_array(LOWER(doc), '\s+')) AS keyword,
        id
    FROM docs02
) AS palabras
LEFT JOIN stop_words sw
    ON palabras.keyword = sw.word
-- 🔹 Filtrar stop words
WHERE sw.word IS NULL;

-- =========================================
-- 🧠 PASO 6: Verificar resultados
-- =========================================

-- Vista parcial ordenada
SELECT keyword, doc_id
FROM invert02
ORDER BY keyword, doc_id
LIMIT 10;

-- =========================================
-- 🧠 PASO 7: Validar que NO haya duplicados
-- =========================================

SELECT keyword, doc_id, COUNT(*) as veces
FROM invert02
GROUP BY keyword, doc_id
HAVING COUNT(*) > 1;

-- =========================================
-- 🧠 EXPLICACIÓN GENERAL
-- =========================================

-- 1. Convertimos texto en palabras (tokenización)
-- 2. Pasamos todo a minúsculas
-- 3. Eliminamos palabras irrelevantes (stop words)
-- 4. Eliminamos duplicados (DISTINCT)
-- 5. Guardamos relación palabra → documento

-- Esto simula un índice invertido real (como GIN en PostgreSQL)