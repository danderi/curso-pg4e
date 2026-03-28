-- ============================================================
-- PROYECTO: CARGA Y BÚSQUEDA FULL-TEXT CON PYTHON + POSTGRESQL
-- ============================================================

-- ------------------------------------------------------------
-- 1. CONFIGURACIÓN EN PYTHON
-- ------------------------------------------------------------

-- Se crea archivo hidden.py con credenciales:

-- hidden.py
-- def secrets():
--     return {
--         "host": "pg.pg4e.com",
--         "port": 5432,
--         "database": "pg4e_xxxxx",
--         "user": "pg4e_xxxxx",
--         "pass": "xxxxxx"
--     }

-- Se usa psycopg2 para conectar con PostgreSQL:
-- IMPORTANTE: sslmode='require' para evitar timeout

-- conn = psycopg2.connect(
--     host=secrets['host'],
--     port=secrets['port'],
--     database=secrets['database'],
--     user=secrets['user'],
--     password=secrets['pass'],
--     connect_timeout=3,
--     sslmode='require'
-- )

-- ------------------------------------------------------------
-- 2. CREACIÓN DE TABLA DESDE PYTHON
-- ------------------------------------------------------------

DROP TABLE IF EXISTS monte_cristo CASCADE;

CREATE TABLE monte_cristo (
    id SERIAL,
    body TEXT
);

-- Python inserta párrafos del libro en la tabla
-- Se hace commit cada 50 inserts para mejorar performance

-- ------------------------------------------------------------
-- 3. BÚSQUEDA SIN ÍNDICE (LENTA)
-- ------------------------------------------------------------

EXPLAIN ANALYZE
SELECT id, body
FROM monte_cristo
WHERE to_tsquery('english', 'prison')
@@ to_tsvector('english', body);

-- Resultado:
-- Seq Scan (escaneo completo)
-- Tiempo aprox: 500 ms
-- Se revisan todas las filas (~15000)

-- ------------------------------------------------------------
-- 4. CREACIÓN DE ÍNDICE GIN (OPTIMIZACIÓN)
-- ------------------------------------------------------------

CREATE INDEX monte_cristo_gin
ON monte_cristo
USING gin(to_tsvector('english', body));

-- ------------------------------------------------------------
-- 5. BÚSQUEDA CON ÍNDICE
-- ------------------------------------------------------------

EXPLAIN ANALYZE
SELECT id, body
FROM monte_cristo
WHERE to_tsquery('english', 'prison')
@@ to_tsvector('english', body);

-- Resultado:
-- Bitmap Index Scan
-- Tiempo aprox: 0.17 ms
-- Mejora: ~3000x más rápido

-- ------------------------------------------------------------
-- 6. OPTIMIZACIÓN AVANZADA (TSVECTOR PRECALCULADO)
-- ------------------------------------------------------------

-- Agregar columna tsvector
ALTER TABLE monte_cristo
ADD COLUMN body_tsv tsvector;

-- Llenar la columna
UPDATE monte_cristo
SET body_tsv = to_tsvector('english', body);

-- Crear índice sobre la nueva columna
CREATE INDEX monte_cristo_gin2
ON monte_cristo
USING gin(body_tsv);

-- ------------------------------------------------------------
-- 7. BÚSQUEDA FINAL OPTIMIZADA
-- ------------------------------------------------------------

EXPLAIN ANALYZE
SELECT id, body
FROM monte_cristo
WHERE to_tsquery('english', 'prison')
@@ body_tsv;

-- Resultado:
-- Bitmap Index Scan
-- Tiempo aprox: ~0.20 ms
-- Ventaja: evita recalcular to_tsvector en cada query
-- Mejor para grandes volúmenes de datos

-- ------------------------------------------------------------
-- 8. OPCIONAL: ACTUALIZACIÓN AUTOMÁTICA
-- ------------------------------------------------------------

CREATE TRIGGER tsv_update
BEFORE INSERT OR UPDATE ON monte_cristo
FOR EACH ROW EXECUTE FUNCTION
tsvector_update_trigger(body_tsv, 'pg_catalog.english', body);

-- Esto mantiene el tsvector actualizado automáticamente

-- ============================================================
-- CONCLUSIÓN
-- ============================================================

-- 1. Sin índice → lento (Seq Scan)
-- 2. Con GIN → extremadamente rápido
-- 3. Con tsvector persistente → más eficiente y escalable

-- Se implementó un sistema básico de búsqueda tipo motor de búsqueda.
