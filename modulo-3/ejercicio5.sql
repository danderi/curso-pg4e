-- ============================================
-- EJERCICIO 5: NORMALIZACION UNESCO - pg4e
-- ============================================
-- Objetivo: cargar datos crudos de un CSV y 
-- distribuirlos en tablas limpias y relacionadas
-- Concepto: ETL con multiples tablas de lookup
-- ============================================
-- PATRON:
-- CSV → unesco_raw → category + state + region + iso → unesco
-- ============================================


-- PASO 1: CREAR LA TABLA CRUDA Y LAS TABLAS DE LOOKUP
-- ============================================

-- Tabla temporal para cargar el CSV crudo
-- Incluye todos los campos como texto plano
DROP TABLE IF EXISTS unesco_raw;
CREATE TABLE unesco_raw
 (name TEXT, description TEXT, justification TEXT, year INTEGER,
    longitude FLOAT, latitude FLOAT, area_hectares FLOAT,
    category TEXT, category_id INTEGER, state TEXT, state_id INTEGER,
    region TEXT, region_id INTEGER, iso TEXT, iso_id INTEGER);

-- Tablas de lookup — cada una guarda valores unicos
-- UNIQUE evita duplicados, SERIAL genera el ID automaticamente
CREATE TABLE category (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE state (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE region (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);

CREATE TABLE iso (
  id SERIAL,
  name VARCHAR(128) UNIQUE,
  PRIMARY KEY(id)
);


-- PASO 2: CARGAR EL CSV EN UNESCO_RAW
-- ============================================
-- HEADER indica que la primera linea del CSV son los nombres de columnas
-- y debe ser saltada
-- category_id, state_id, region_id, iso_id quedan vacios por ahora
\copy unesco_raw(name,description,justification,year,longitude,latitude,area_hectares,category,state,region,iso) FROM 'whc-sites-2018-small.csv' WITH DELIMITER ',' CSV HEADER;


-- PASO 3: LLENAR LAS TABLAS DE LOOKUP CON DISTINCT
-- ============================================
-- DISTINCT evita insertar el mismo valor mas de una vez
-- ya que en el CSV hay muchas filas con la misma categoria, estado, etc.
INSERT INTO category (name) SELECT DISTINCT category FROM unesco_raw;
INSERT INTO state (name) SELECT DISTINCT state FROM unesco_raw;
INSERT INTO region (name) SELECT DISTINCT region FROM unesco_raw;
INSERT INTO iso (name) SELECT DISTINCT iso FROM unesco_raw;


-- PASO 4: ACTUALIZAR LOS IDs EN UNESCO_RAW
-- ============================================
-- Para cada fila de unesco_raw, busca en la tabla de lookup
-- el ID que corresponde al texto que ya tenemos guardado
-- y lo pone en la columna _id correspondiente
-- Es el puente entre el texto repetido y el numero de referencia
UPDATE unesco_raw SET category_id = (
    SELECT category.id FROM category 
    WHERE category.name = unesco_raw.category
);

UPDATE unesco_raw SET state_id = (
    SELECT state.id FROM state 
    WHERE state.name = unesco_raw.state
);

UPDATE unesco_raw SET region_id = (
    SELECT region.id FROM region 
    WHERE region.name = unesco_raw.region
);

UPDATE unesco_raw SET iso_id = (
    SELECT iso.id FROM iso 
    WHERE iso.name = unesco_raw.iso
);


-- PASO 5: CREAR LA TABLA UNESCO LIMPIA
-- ============================================
-- Solo guarda IDs como foreign keys, no texto repetido
-- REFERENCES garantiza integridad entre tablas
CREATE TABLE unesco (
  id SERIAL,
  name TEXT,
  description TEXT,
  justification TEXT,
  year INTEGER,
  longitude FLOAT,
  latitude FLOAT,
  area_hectares FLOAT,
  category_id INTEGER REFERENCES category(id),
  state_id INTEGER REFERENCES state(id),
  region_id INTEGER REFERENCES region(id),
  PRIMARY KEY(id)
);

-- iso_id agregado con ALTER TABLE como practica
-- demuestra que se puede modificar una tabla existente
ALTER TABLE unesco ADD COLUMN iso_id INTEGER REFERENCES iso(id);


-- PASO 6: COPIAR DATOS LIMPIOS A LA TABLA UNESCO
-- ============================================
-- Copia los datos de unesco_raw a unesco
-- descartando los campos de texto crudo (category, state, region, iso)
-- y quedandose solo con los IDs de referencia
INSERT INTO unesco (name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id)
SELECT name, description, justification, year, longitude, latitude, area_hectares, category_id, state_id, region_id, iso_id
FROM unesco_raw;


-- PASO 7: VERIFICAR EL RESULTADO
-- ============================================
-- Verifica que todos los JOINs funcionen correctamente
-- Deberia devolver 3 filas ordenadas por categoria y nombre
SELECT unesco.name, year, category.name, state.name, region.name, iso.name
  FROM unesco
  JOIN category ON unesco.category_id = category.id
  JOIN iso ON unesco.iso_id = iso.id
  JOIN state ON unesco.state_id = state.id
  JOIN region ON unesco.region_id = region.id
  ORDER BY category.name, unesco.name
  LIMIT 3;


-- ============================================
-- RESULTADO ESPERADO:
-- Khomani Cultural Landscape  | 2017 | Cultural | South Africa | Africa          | za
-- Al Saflieni Hypogeum        | 1980 | Cultural | Malta        | Europe and N.A  | mt
-- Thingvellir National Park   | 2004 | Cultural | Iceland      | Europe and N.A  | is
-- ============================================