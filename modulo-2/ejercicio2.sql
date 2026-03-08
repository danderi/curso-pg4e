-- Nos conectamos al servidor del curso PG4E;
psql -h pg.pg4e.com -p 5432 -U pg4e_cf843127b6 pg4e_cf843127b6

--Luego de colocar el password seguimos la consigna;
--Creamos 2 tablas, una make y una model con la siguiente estructura;

CREATE TABLE make (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

CREATE TABLE model (
  id SERIAL,
  name VARCHAR(128),
  make_id INTEGER REFERENCES make(id) ON DELETE CASCADE,
  PRIMARY KEY(id)
);

-- Insertamos datos a la tabla make;
INSERT INTO make (name) VALUES ('BMW');
INSERT INTO make (name) VALUES ('Suzuki');

--Observamos el contenido de la tabla make
SELECT * FROM make;
-- id |  name  
----+--------
--  1 | BMW
--  2 | Suzuki
--(2 rows)

-- Insertamos datos a la tabla model;
INSERT INTO model (name, make_id) VALUES ('330ci Convertible', 1);
INSERT INTO model (name, make_id) VALUES ('330e', 1);
INSERT INTO model (name, make_id) VALUES ('330i', 1);
INSERT INTO model (name, make_id) VALUES ('Forenza', 2);
INSERT INTO model (name, make_id) VALUES ('Forenza Wagon', 2);


--Observamos el contenido de la tabla make
SELECT * FROM model;
 --id |       name        | make_id 
----+-------------------+---------
--  1 | 330ci Convertible |       1
--  2 | 330e              |       1
--  3 | 330i              |       1
--  4 | Forenza           |       2
--  5 | Forenza Wagon     |       2
--(5 rows)

--Usamos comando JOIN para observar la marca y modelo (make and model) por sus nombres
SELECT make.name, model.name FROM model JOIN make ON model.make_id = make.id ORDER BY make.name LIMIT 5;

--  name  |       name        
--------+-------------------
-- BMW    | 330ci Convertible
-- BMW    | 330e
-- BMW    | 330i
-- Suzuki | Forenza
-- Suzuki | Forenza Wagon
--(5 rows)