-- Creamos la tabla con la estructura que pide el Dr. Chuck
CREATE TABLE track_raw (
    title TEXT, 
    artist TEXT, 
    album TEXT,
    count INTEGER, 
    rating INTEGER, 
    len INTEGER
);

\copy track_raw(title,artist,album,count,rating,len) FROM 'library.csv' WITH DELIMITER ',' CSV;

SELECT title, album FROM track_raw ORDER BY title LIMIT 3