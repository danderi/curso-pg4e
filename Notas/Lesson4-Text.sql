-- ============================================
-- MODULO 4: TEXT IN POSTGRESQL - pg4e
-- ============================================


-- ============================================
-- 1. GENERATING TEST DATA
-- Generar datos de prueba masivos
-- ============================================

-- generate_series → genera filas (como range() en Python)
SELECT generate_series(1,5);
-- RESULTADO:
-- generate_series
-- -----------------
--  1
--  2
--  3
--  4
--  5

-- random() → número aleatorio entre 0 y 1
-- trunc() → elimina los decimales
SELECT trunc(random()*100);
-- RESULTADO:
-- trunc
-- -------
--  73

-- repeat() → repite un string N veces
SELECT repeat('Neon ', 3);
-- RESULTADO:
--        repeat
-- -------------------
--  Neon Neon Neon

-- Combinado → insertar 100.000 filas de una sola vez
INSERT INTO textfun (content)
SELECT 'https://pg4e.com/neon/' || trunc(random()*1000000)
|| generate_series(1, 100000);
-- RESULTADO:
-- INSERT 0 100000


-- ============================================
-- 2. TEXT FUNCTIONS
-- Funciones para manipular texto
-- ============================================

-- LIKE → buscar texto
SELECT content FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
--              content
-- ------------------------------------
--  https://pg4e.com/neon/225845150000

-- upper() / lower() → mayúsculas / minúsculas
SELECT upper(content) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- HTTPS://PG4E.COM/NEON/225845150000

SELECT lower(content) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- https://pg4e.com/neon/225845150000

-- left() / right() → extraer caracteres del inicio o final
SELECT left(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- http

SELECT right(content, 4) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- 0000

-- split_part() → dividir texto por separador
-- split_part(texto, separador, posicion)
SELECT split_part(content, '/', 4) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- neon

-- strpos() → posición de un substring dentro del texto
SELECT strpos(content, 'ttps://') FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- 2

-- substr() → extraer substring desde posicion N, largo M
SELECT substr(content, 2, 4) FROM textfun WHERE content LIKE '%150000%';
-- RESULTADO:
-- ttps


-- ============================================
-- 3. CHARACTER SETS / UTF-8
-- Como se representan los caracteres
-- ============================================

-- ASCII → cada letra tiene un número entre 0-127
SELECT ascii('H'), ascii('e'), ascii('l');
-- RESULTADO:
-- ascii | ascii | ascii
-- -------+-------+-------
--    72  |  101  |  108

-- chr() → convierte número a caracter
SELECT chr(72), chr(231), chr(20013);
-- RESULTADO:
--  chr | chr | chr
-- -----+-----+-----
--  H   |  ç  |  中

-- Ver encoding del servidor (siempre debería ser UTF8)
SHOW SERVER_ENCODING;
-- RESULTADO:
--  server_encoding
-- -----------------
--  UTF8


-- ============================================
-- 4. HASHES
-- Convertir texto en un número de tamaño fijo
-- ============================================

-- md5() → hash rápido de 128 bits (no usar para contraseñas)
SELECT md5('hello');
-- RESULTADO:
--               md5
-- ----------------------------------
--  5d41402abc4b2a76b9719d911017c592

-- sha256() → hash moderno y seguro
SELECT sha256('hello'::bytea);
-- RESULTADO:
-- \x2cf24dba5fb0a30e26e83b2ac5b9e29e1b161e5c1fa7425e73043362938b9824

-- Uso práctico: crear índice sobre el hash de una URL larga
-- para búsquedas más rápidas y eficientes
CREATE INDEX cr2_md5 ON cr2 (md5(url));

SELECT * FROM cr2 WHERE md5(url) = md5('https://pg4e.com/neon/12345');
-- RESULTADO:
-- Index Scan using cr2_md5 → MUY RÁPIDO ✅


-- ============================================
-- 5. INDEXES AND PERFORMANCE
-- Hacer búsquedas más rápidas
-- ============================================

-- Sin índice → Seq Scan (revisa TODA la tabla) → LENTO
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE '%racing%';
-- RESULTADO:
--  Seq Scan on textfun
--    Filter: (content ~~ '%racing%')
--    Rows Removed by Filter: 100001
--  Execution Time: 10.271 ms   ← LENTO ❌

-- Crear índice B-Tree (el más común y versátil)
CREATE INDEX textfun_b ON textfun (content);

-- Con índice + LIKE 'algo%' (empieza con) → Index Scan → RÁPIDO
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE 'racing%';
-- RESULTADO:
--  Index Only Scan using textfun_b on textfun
--  Execution Time: 0.011 ms   ← RÁPIDO ✅

-- IMPORTANTE: LIKE '%algo%' (contiene) NO usa el índice aunque exista
EXPLAIN ANALYZE SELECT content FROM textfun WHERE content LIKE '%racing%';
-- RESULTADO:
--  Seq Scan on textfun  ← sigue siendo lento ❌
--  Execution Time: 10.271 ms

-- Crear índice HASH (solo para búsquedas exactas, más pequeño)
CREATE INDEX textfun_h ON textfun USING HASH (content);

SELECT content FROM textfun WHERE content = 'https://pg4e.com/neon/12345';
-- RESULTADO:
--  Bitmap Index Scan on textfun_h
--  Execution Time: 0.045 ms   ← RÁPIDO ✅

-- Comparación de estrategias de índice:
-- Sin índice:          SELECT = 1.784 ms
-- MD5 index on url:   SELECT = 0.142 ms
-- uuid column + index: SELECT = 0.030 ms  ← el más rápido


-- ============================================
-- 6. REGULAR EXPRESSIONS
-- Búsqueda avanzada de patrones en texto
-- ============================================

-- ~ → busca el patrón en cualquier parte del texto
SELECT email FROM em WHERE email ~ 'umich';
-- RESULTADO:
--       email
-- ------------------
--  csev@umich.edu
--  coleen@umich.edu

-- ^ → empieza con
SELECT email FROM em WHERE email ~ '^c';
-- RESULTADO:
--       email
-- ------------------
--  csev@umich.edu
--  coleen@umich.edu

-- $ → termina con
SELECT email FROM em WHERE email ~ 'edu$';
-- RESULTADO:
--       email
-- ------------------
--  csev@umich.edu
--  coleen@umich.edu
--  sally@uiuc.edu
--  ted79@umuc.edu

-- [0-9] → contiene un número
SELECT email FROM em WHERE email ~ '[0-9]';
-- RESULTADO:
--       email
-- ----------------
--  ted79@umuc.edu
--  glenn1@apple.com

-- [0-9][0-9] → contiene DOS números seguidos
SELECT email FROM em WHERE email ~ '[0-9][0-9]';
-- RESULTADO:
--     email
-- ----------------
--  ted79@umuc.edu

-- substring() con regex → extraer parte del texto
-- Extraer el dominio del email (.+@  → todo hasta el @, (.*)$ → captura lo que sigue)
SELECT substring(email FROM '.+@(.*)$') FROM em;
-- RESULTADO:
--  substring
-- -----------
--  umich.edu
--  umich.edu
--  uiuc.edu
--  umuc.edu
--  apple.com
--  apple.com

-- regexp_matches() → encontrar TODOS los matches en un texto
-- 'g' = global, busca todas las ocurrencias
SELECT id, regexp_matches(tweet, '#([A-Za-z0-9_]+)', 'g') FROM tw;
-- RESULTADO:
--  id | regexp_matches
-- ----+----------------
--   1 | {SQL}
--   1 | {FUN}
--   2 | {SQL}
--   2 | {UMSI}
--   3 | {UMSI}
--   3 | {PYTHON}

-- Combinando regex + GROUP BY → contar dominios de email
SELECT substring(email FROM '.+@(.*)$'), 
       count(substring(email FROM '.+@(.*)$'))
FROM em 
GROUP BY substring(email FROM '.+@(.*)$');
-- RESULTADO:
--  substring | count
-- -----------+-------
--  apple.com |   2
--  uiuc.edu  |   1
--  umuc.edu  |   1
--  umich.edu |   2