-- Creamos la tabla con la estructura que pide el Dr. Chuck
CREATE TABLE track_raw (
    title TEXT, 
    artist TEXT, 
    album TEXT,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER
);

-- 2. Cargar los datos (La magia del CSV)
-- OJO: Asegúrate de que el nombre del archivo sea exacto
\copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;


-- 3. La prueba final (Lo que el profesor va a mirar)
SELECT title, album FROM track_raw ORDER BY title LIMIT 3