-- ============================================
-- EJERCICIO 4: NORMALIZACION CON SQL - pg4e
-- ============================================
-- Objetivo: cargar datos crudos de un CSV y 
-- distribuirlos en tablas limpias y relacionadas
-- Concepto: ETL (Extract, Transform, Load)
-- ============================================


-- PASO 1: CREAR LAS TABLAS
-- ============================================

-- Tabla final de albumes (datos limpios)
CREATE TABLE album (
  id SERIAL,
  title VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

-- Tabla final de tracks (datos limpios)
-- album_id referencia a album(id)
-- Si se borra un album, se borran sus tracks (CASCADE)
CREATE TABLE track (
    id SERIAL,
    title VARCHAR(128),
    len INTEGER, rating INTEGER, count INTEGER,
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    UNIQUE(title, album_id),
    PRIMARY KEY(id)
);

-- Tabla temporal para cargar el CSV crudo
-- Incluye todos los campos del CSV incluyendo artist y album como texto
DROP TABLE IF EXISTS track_raw;
CREATE TABLE track_raw
 (title TEXT, artist TEXT, album TEXT, album_id INTEGER,
  count INTEGER, rating INTEGER, len INTEGER);


-- PASO 2: CARGAR EL CSV EN TRACK_RAW
-- ============================================
-- \copy carga el archivo CSV en la tabla cruda
-- album_id queda vacio por ahora, se llena despues
\copy track_raw(title, artist, album, count, rating, len) FROM 'library.csv' WITH DELIMITER ',' CSV;


-- PASO 3: INSERTAR ALBUMES UNICOS EN LA TABLA ALBUM
-- ============================================
-- DISTINCT evita insertar el mismo album mas de una vez
-- ya que en el CSV hay muchos tracks del mismo album
INSERT INTO album (title) 
SELECT DISTINCT album FROM track_raw;


-- PASO 4: ACTUALIZAR EL ALBUM_ID EN TRACK_RAW
-- ============================================
-- Conecta cada fila de track_raw con su album correspondiente
-- usando un SUBQUERY que busca el id del album por titulo
UPDATE track_raw SET album_id = (
    SELECT album.id FROM album 
    WHERE album.title = track_raw.album
);


-- PASO 5: COPIAR DATOS LIMPIOS A LA TABLA TRACK
-- ============================================
-- Copia los datos de track_raw a track
-- descartando los campos artist y album (texto crudo)
-- y quedandose solo con los datos necesarios + album_id
INSERT INTO track (title, len, rating, count, album_id)
SELECT title, len, rating, count, album_id 
FROM track_raw;


-- PASO 6: VERIFICAR EL RESULTADO
-- ============================================
-- Verifica que tracks y albumes esten correctamente relacionados
-- Deberia devolver 3 filas ordenadas alfabeticamente
SELECT track.title, album.title
FROM track
JOIN album ON track.album_id = album.id
ORDER BY track.title LIMIT 3;


-- ============================================
-- RESULTADO ESPERADO:
-- A Boy Named Sue (live)      | The Legend Of Johnny Cash
-- A Brief History of Packets  | Computing Conversations
-- Aguas De Marco              | Natural Wonders Music Sampler 1999
-- ============================================