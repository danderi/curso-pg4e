-- ============================================
-- RESUMEN: FULL TEXT SEARCH EN POSTGRESQL
-- ============================================

-- 1. PostgreSQL permite hacer búsquedas de texto tipo "Google"
-- usando funciones internas y índices especializados.

-- --------------------------------------------
-- 2. FUNCIONES PRINCIPALES
-- --------------------------------------------

-- Convierte texto en un formato optimizado:
-- - separa palabras
-- - elimina stop words (and, the, etc)
-- - aplica stemming (teaching -> teach)

SELECT to_tsvector('english', 'UMSI also teaches Python and also SQL');

-- Convierte una búsqueda en formato entendible por el sistema

SELECT to_tsquery('english', 'teaching');  -- → 'teach'

-- --------------------------------------------
-- 3. OPERADOR DE BÚSQUEDA
-- --------------------------------------------

-- @@ compara:
-- ¿coincide la búsqueda con el documento?

SELECT to_tsquery('english', 'learn') @@
       to_tsvector('english', 'More people should learn SQL');

-- --------------------------------------------
-- 4. ÍNDICE GIN (CLAVE PARA PERFORMANCE)
-- --------------------------------------------

-- Crea un índice invertido automático

CREATE INDEX idx_docs_search
ON docs
USING gin(to_tsvector('english', doc));

-- --------------------------------------------
-- 5. QUERY FINAL OPTIMIZADA
-- --------------------------------------------

SELECT id, doc
FROM docs
WHERE to_tsquery('english', 'learn')
@@ to_tsvector('english', doc);

-- PostgreSQL usará:
-- Bitmap Index Scan → índice GIN
-- Bitmap Heap Scan → lectura de datos

-- --------------------------------------------
-- 6. CONCEPTOS CLAVE
-- --------------------------------------------

-- - GIN: índice ideal para texto (rápido en búsqueda, pesado en inserts)
-- - GiST: alternativa más liviana pero menos precisa
-- - B-Tree: para búsquedas exactas o por prefijo
-- - Stop Words: palabras sin valor (and, the, is)
-- - Stemming: reduce palabras a su raíz (teaching -> teach)

-- --------------------------------------------
-- 7. TIPOS DE BÚSQUEDA (tsquery)
-- --------------------------------------------

-- AND
-- 'python & sql'

-- OR
-- 'python | sql'

-- NOT
-- 'python & !sql'

-- --------------------------------------------
-- 8. IDEA FINAL
-- --------------------------------------------

-- PostgreSQL puede funcionar como motor de búsqueda
-- sin necesidad de herramientas externas.

-- Elegir el índice correcto = mejor performance