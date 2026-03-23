-- =========================================
-- 🧠 PASO 1: Crear tablas
-- =========================================

-- Tabla principal con documentos
CREATE TABLE docs01 (
    id SERIAL,
    doc TEXT,
    PRIMARY KEY(id)
);

-- Tabla de índice invertido (palabra → documento)
CREATE TABLE invert01 (
    keyword TEXT,
    doc_id INTEGER REFERENCES docs01(id) ON DELETE CASCADE
);

-- =========================================
-- 🧠 PASO 2: Insertar documentos
-- =========================================

INSERT INTO docs01 (doc) VALUES
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
-- 🧠 PASO 3: Limpiar tabla invertida (por si ya tenía datos)
-- =========================================

DELETE FROM invert01;

-- =========================================
-- 🧠 PASO 4: Crear índice invertido correctamente
-- =========================================

-- 🔥 Claves:
-- 1. LOWER() → evita problemas de mayúsculas
-- 2. regexp_split_to_array() → separa palabras
-- 3. unnest() → convierte array en filas
-- 4. DISTINCT → evita duplicados por documento

INSERT INTO invert01 (keyword, doc_id)
SELECT DISTINCT
       keyword,
       id
FROM (
    SELECT 
        unnest(regexp_split_to_array(LOWER(doc), '\s+')) AS keyword,
        id
    FROM docs01
) AS sub;

-- =========================================
-- 🧠 PASO 5: Verificar resultados
-- =========================================

-- Vista general ordenada
SELECT keyword, doc_id
FROM invert01
ORDER BY keyword, doc_id
LIMIT 10;

-- =========================================
-- 🧠 PASO 6: Verificar que NO haya duplicados
-- =========================================

-- Si esto devuelve filas → hay error
-- Si devuelve (0 filas) → todo perfecto 😎

SELECT keyword, doc_id, COUNT(*) as veces
FROM invert01
GROUP BY keyword, doc_id
HAVING COUNT(*) > 1;

-- =========================================
-- 🧠 EXPLICACIÓN GENERAL (modo simple)
-- =========================================

-- Cada documento:
-- "hola mundo hola"

-- Se transforma en:
-- hola | 1
-- mundo | 1
-- hola | 1   ❌ (duplicado)

-- Con DISTINCT queda:
-- hola | 1
-- mundo | 1   ✅

-- Esto simula cómo funciona un índice invertido real (tipo GIN)