-- ============================================
-- EJERCICIO 6: MUSICAL TRACK DATABASE + ARTISTS - pg4e
-- ============================================
-- Objetivo: crear una relacion many-to-many
-- entre tracks y artists usando una tabla junction
-- Diferencia con ejercicios anteriores: no se usa
-- tabla _raw separada, se usa ALTER TABLE para limpiar
-- ============================================
-- PATRON:
-- CSV → track (con texto) → album + artist + tracktoartist → limpiar con ALTER TABLE
-- ============================================


-- PASO 1: CREAR LAS TABLAS
-- ============================================

-- Tabla de albumes
DROP TABLE IF EXISTS album CASCADE;
CREATE TABLE album (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

-- Tabla de tracks — incluye artist y album como texto por ahora
-- Se eliminaran con ALTER TABLE una vez que tengamos los IDs
DROP TABLE IF EXISTS track CASCADE;
CREATE TABLE track (
    id SERIAL,
    title TEXT, 
    artist TEXT, 
    album TEXT, 
    album_id INTEGER REFERENCES album(id) ON DELETE CASCADE,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER,
    PRIMARY KEY(id)
);

-- Tabla de artistas
DROP TABLE IF EXISTS artist CASCADE;
CREATE TABLE artist (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

-- Tabla junction para relacion many-to-many entre track y artist
-- Un track puede tener varios artistas
-- Un artista puede tener varios tracks
DROP TABLE IF EXISTS tracktoartist CASCADE;
CREATE TABLE tracktoartist (
    id SERIAL,
    track VARCHAR(128),
    track_id INTEGER REFERENCES track(id) ON DELETE CASCADE,
    artist VARCHAR(128),
    artist_id INTEGER REFERENCES artist(id) ON DELETE CASCADE,
    PRIMARY KEY(id)
);


-- PASO 2: CARGAR EL CSV DIRECTO EN TRACK
-- ============================================
-- A diferencia de ejercicios anteriores, cargamos
-- directo en track sin tabla raw separada
\copy track(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;


-- PASO 3: LLENAR LA TABLA ALBUM
-- ============================================
-- DISTINCT evita insertar el mismo album mas de una vez
INSERT INTO album (title) SELECT DISTINCT album FROM track;

-- Actualizar album_id en track
UPDATE track SET album_id = (
    SELECT album.id FROM album 
    WHERE album.title = track.album
);


-- PASO 4: LLENAR TRACKTOARTIST CON TEXTO PRIMERO
-- ============================================
-- Primero llenamos con texto, luego actualizamos los IDs
-- Es el mismo patron que venimos usando
INSERT INTO tracktoartist (track, artist) 
SELECT DISTINCT title, artist FROM track;


-- PASO 5: LLENAR LA TABLA ARTIST
-- ============================================
INSERT INTO artist (name) 
SELECT DISTINCT artist FROM tracktoartist;


-- PASO 6: ACTUALIZAR LOS IDs EN TRACKTOARTIST
-- ============================================
-- UPDATE porque las filas ya existen, solo les falta el ID
-- Si usaramos INSERT creariamos filas duplicadas
UPDATE tracktoartist SET track_id = (
    SELECT track.id FROM track 
    WHERE track.title = tracktoartist.track
);

UPDATE tracktoartist SET artist_id = (
    SELECT artist.id FROM artist 
    WHERE artist.name = tracktoartist.artist
);


-- PASO 7: BORRAR COLUMNAS DE TEXTO QUE YA NO NECESITAMOS
-- ============================================
-- Una vez que tenemos los IDs, el texto es redundante
ALTER TABLE track DROP COLUMN album;
ALTER TABLE track DROP COLUMN artist;
ALTER TABLE tracktoartist DROP COLUMN track;
ALTER TABLE tracktoartist DROP COLUMN artist;


-- PASO 8: VERIFICAR EL RESULTADO
-- ============================================
SELECT track.title, album.title, artist.name
FROM track
JOIN album ON track.album_id = album.id
JOIN tracktoartist ON track.id = tracktoartist.track_id
JOIN artist ON tracktoartist.artist_id = artist.id
ORDER BY track.title
LIMIT 3;


-- ============================================
-- RESULTADO ESPERADO:
-- A Boy Named Sue (live) | The Legend Of Johnny Cash | Johnny Cash
-- A Brief History of Packets | Computing Conversations | IEEE Computer Society
-- Aguas De Marco | Natural Wonders Music Sampler 1999 | Rosa Passos
-- ============================================