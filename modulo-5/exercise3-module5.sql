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
-- 🧠 PASO 3: Crear índice GIN
-- =========================================

-- 🔥 Este índice permite búsquedas rápidas sobre arrays de palabras
CREATE INDEX array03 
ON docs03 
USING gin(string_to_array(lower(doc), ' '));

-- =========================================
-- 🧠 PASO 4: Agregar muchos datos (forzar uso del índice)
-- =========================================

-- Esto hace que PostgreSQL prefiera el índice en lugar de Seq Scan
INSERT INTO docs03 (doc)
SELECT 'Neon ' || generate_series(10000,20000);

-- =========================================
-- 🧠 PASO 5: Query de búsqueda
-- =========================================

-- 🔍 Busca documentos que contengan la palabra "communicating"
SELECT id, doc
FROM docs03
WHERE '{communicating}' <@ string_to_array(lower(doc), ' ');

-- =========================================
-- 🧠 PASO 6: Verificar uso del índice
-- =========================================

EXPLAIN
SELECT id, doc
FROM docs03
WHERE '{communicating}' <@ string_to_array(lower(doc), ' ');

-- =========================================
-- 🧠 EXPLICACIÓN GENERAL
-- =========================================

-- 1. Convertimos el texto en un array de palabras
--    string_to_array(lower(doc), ' ')
--
-- 2. Usamos el operador <@
--    → verifica si una palabra está dentro del array
--
-- 3. Creamos un índice GIN
--    → permite buscar palabras dentro de arrays rápidamente
--
-- 4. Insertamos muchos datos
--    → para que PostgreSQL prefiera usar el índice
--
-- 5. EXPLAIN
--    → nos muestra si usa:
--       ❌ Seq Scan (lento)
--       ✅ Bitmap Index Scan (rápido)
--
-- Esto simula cómo funcionan los motores de búsqueda reales

--pg4e=> EXPLAIN SELECT id, doc FROM docs03 WHERE '{communicating}' <@ string_to_array(lower(doc), ' ');
--                                   QUERY PLAN
--------------------------------------------------------------------------------
-- Seq Scan on docs03  (cost=0.00..177.24 rows=35 width=36)
-- Filter: ('{communicating}'::text[] <@ string_to_array(lower(doc), ' '::text))
--(2 rows)


--TIME PASSES......


--pg4e=> EXPLAIN SELECT id, doc FROM docs03 WHERE '{communicating}' <@ string_to_array(lower(doc), ' ');
--                                        QUERY PLAN
------------------------------------------------------------------------------------------
-- Bitmap Heap Scan on docs03  (cost=12.02..21.97 rows=3 width=15)
-- Recheck Cond: ('{communicating}'::text[] <@ string_to_array(lower(doc), ' '::text))
--   ->  Bitmap Index Scan on array03  (cost=0.00..12.02 rows=3 width=0)
--   Index Cond: ('{communicating}'::text[] <@ string_to_array(lower(doc), ' '::text))
--(4 rows)