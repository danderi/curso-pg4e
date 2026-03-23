-- ============================================
-- EJERCICIOS MODULO 4: TEXT IN POSTGRESQL - pg4e
-- ============================================


-- ============================================
-- EJERCICIO 1: KEYVALUE TABLE + TRIGGER
-- Crear una tabla y un trigger que actualice
-- automaticamente updated_at en cada UPDATE
-- ============================================

-- Paso 1: Crear la tabla
CREATE TABLE keyvalue ( 
  id SERIAL,
  key VARCHAR(128) UNIQUE,
  value VARCHAR(128) UNIQUE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY(id)
);

-- Paso 2: Crear el procedure
-- Define QUE hacer cuando se dispare el trigger
-- NEW = la fila que esta siendo actualizada
-- NEW.updated_at = NOW() actualiza el timestamp
-- RETURN NEW devuelve la fila con el cambio aplicado
CREATE OR REPLACE FUNCTION trigger_set_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Paso 3: Crear el trigger
-- Define CUANDO ejecutar el procedure
-- BEFORE UPDATE = antes de cada UPDATE
-- FOR EACH ROW = para cada fila afectada
CREATE TRIGGER set_timestamp
BEFORE UPDATE ON keyvalue
FOR EACH ROW
EXECUTE PROCEDURE trigger_set_timestamp();

-- Verificacion: insertar y actualizar para ver si funciona
INSERT INTO keyvalue (key, value) VALUES ('color', 'rojo');

-- updated_at deberia cambiar automaticamente
UPDATE keyvalue SET value = 'azul' WHERE key = 'color';

SELECT * FROM keyvalue;
-- RESULTADO ESPERADO:
-- id | key   | value | created_at          | updated_at (distinto al created_at)
-- ---+-------+-------+---------------------+------------------------------------
--  1 | color | azul  | 2024-03-01 10:00:00 | 2024-03-22 15:30:00  ← se actualizó


-- ============================================
-- EJERCICIO 2: REGULAR EXPRESSIONS
-- Buscar lineas con numeros de 3 digitos
-- entre parentesis como (567) o (293)
-- ============================================

-- La regex:
-- \( = parentesis que abre (escapado porque ( tiene significado especial)
-- [0-9][0-9][0-9] = exactamente tres digitos
-- \) = parentesis que cierra (escapado igual)

SELECT purpose FROM taxdata 
WHERE purpose ~ '\([0-9][0-9][0-9]\)' 
ORDER BY purpose DESC LIMIT 3;

-- La regex que ingresa el autograder:
-- \([0-9][0-9][0-9]\)


-- ============================================
-- EJERCICIO 3: GENERATING TEXT
-- Crear tabla bigtext con 100.000 filas
-- con numeros del 100000 al 199999
-- ============================================

-- Paso 1: Crear la tabla
CREATE TABLE bigtext (
    content TEXT
);

-- Paso 2: Insertar 100.000 filas usando generate_series
-- generate_series(100000, 199999) genera los numeros del 100000 al 199999
-- || concatena las partes del texto con el numero
INSERT INTO bigtext (content)
SELECT 'This is record number ' || generate_series(100000, 199999) || ' of quite a few text records.';

-- Verificacion: ver las primeras 3 filas
SELECT * FROM bigtext LIMIT 3;
-- RESULTADO ESPERADO:
-- content
-- ----------------------------------------------------------
-- This is record number 100000 of quite a few text records.
-- This is record number 100001 of quite a few text records.
-- This is record number 100002 of quite a few text records.

-- Verificacion: contar filas (debe dar 100000)
SELECT COUNT(*) FROM bigtext;
-- RESULTADO ESPERADO:
--  count
-- --------
--  100000


-- ============================================
-- EJERCICIO 4: HASH COLLISION
-- Encontrar dos strings que produzcan
-- el mismo hash value (colision)
-- ============================================

-- El algoritmo de hash:
-- pos cicla 1, 2, 3, 4, 1, 2, 3, 4...
-- hv = (hv + (pos * ord(letra))) % 1000000

-- Script Python para encontrar la colision automaticamente:
-- (correr en terminal: python hash-exercise.py)

-- def get_hash(txt):
--     hv = 0
--     pos = 0
--     for let in txt:
--         pos = (pos % 4) + 1
--         hv = (hv + (pos * ord(let))) % 1000000
--     return hv
-- 
-- import itertools
-- for largo in range(3, 6):
--     for combo1 in itertools.permutations('ABCDE', largo):
--         for combo2 in itertools.permutations('ABCDE', largo):
--             w1 = ''.join(combo1)
--             w2 = ''.join(combo2)
--             if w1 != w2 and get_hash(w1) == get_hash(w2):
--                 print(f'Colision: {w1} y {w2} → hash {get_hash(w1)}')
--                 exit()

-- CONCEPTO CLAVE:
-- pos cicla 1,2,3,4,1,2,3,4 por lo que el caracter en posicion 1
-- y el caracter en posicion 5 tienen el mismo peso (pos=1).
-- Intercambiando caracteres en posiciones de igual peso se produce la colision.
