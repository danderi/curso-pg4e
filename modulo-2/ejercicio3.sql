--Estamos aprendiendo a crear tablas y a llenarlas de información con la relación Many to Many
--Creamos las siguientes tablas
CREATE TABLE student (
    id SERIAL,
    name VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE course CASCADE;
CREATE TABLE course (
    id SERIAL,
    title VARCHAR(128) UNIQUE,
    PRIMARY KEY(id)
);

DROP TABLE roster CASCADE;
CREATE TABLE roster (
    id SERIAL,
    student_id INTEGER REFERENCES student(id) ON DELETE CASCADE,
    course_id INTEGER REFERENCES course(id) ON DELETE CASCADE,
    role INTEGER,
    UNIQUE(student_id, course_id),
    PRIMARY KEY (id)
);

--Insertamos los datos de la tabla student
INSERT INTO student (name) VALUES ('Isabell');
INSERT INTO student (name) VALUES ('Camerin');
INSERT INTO student (name) VALUES ('Davie');
INSERT INTO student (name) VALUES ('Rio');
INSERT INTO student (name) VALUES ('Zennon');
INSERT INTO student (name) VALUES ('Masson');
INSERT INTO student (name) VALUES ('Caitlinn');
INSERT INTO student (name) VALUES ('Christina');
INSERT INTO student (name) VALUES ('Rhuaridh');
INSERT INTO student (name) VALUES ('Siyona');
INSERT INTO student (name) VALUES ('Hector');
INSERT INTO student (name) VALUES ('Atli');
INSERT INTO student (name) VALUES ('Caley');
INSERT INTO student (name) VALUES ('Jonah');
INSERT INTO student (name) VALUES ('Miles');

--Insertamos los datos de la tabla course:
INSERT INTO course (title) VALUES ('si106');
INSERT INTO course (title) VALUES ('si110');
INSERT INTO course (title) VALUES ('si206');

--id |   name              
------+-----------
--  1 | Isabell
--  2 | Camerin
--  3 | Davie
--  4 | Rio
--  5 | Zennon
--  6 | Masson
--  7 | Caitlinn
--  8 | Christina
--  9 | Rhuaridh
-- 10 | Siyona
-- 11 | Hector
-- 12 | Atli
-- 13 | Caley
-- 14 | Jonah
-- 15 | Miles
--(15 rows)

--id | title 
------+-------
--  1 | si106
--  2 | si110
--  3 | si206

--Insertamos la información correspondiente a la tabla roster

INSERT INTO roster (student_id, course_id, role) VALUES (1,1,1);
INSERT INTO roster (student_id, course_id, role) VALUES (2,1,0);
INSERT INTO roster (student_id, course_id, role) VALUES (3,1,0);
INSERT INTO roster (student_id, course_id, role) VALUES (4,1,0);
INSERT INTO roster (student_id, course_id, role) VALUES (5,1,0);
INSERT INTO roster (student_id, course_id, role) VALUES (6,2,1);
INSERT INTO roster (student_id, course_id, role) VALUES (7,2,0);
INSERT INTO roster (student_id, course_id, role) VALUES (8,2,0);
INSERT INTO roster (student_id, course_id, role) VALUES (9,2,0);
INSERT INTO roster (student_id, course_id, role) VALUES (10,2,0);
INSERT INTO roster (student_id, course_id, role) VALUES (11,3,1);
INSERT INTO roster (student_id, course_id, role) VALUES (12,3,0);
INSERT INTO roster (student_id, course_id, role) VALUES (13,3,0);
INSERT INTO roster (student_id, course_id, role) VALUES (14,3,0);
INSERT INTO roster (student_id, course_id, role) VALUES (15,3,0);

--Observamos la información de las tablas combinando nombre, curso y rol
SELECT student.name, course.title, roster.role
FROM student 
JOIN roster ON student.id = roster.student_id
JOIN course ON roster.course_id = course.id
ORDER BY course.title, roster.role DESC, student.name;

--   name    | title | role 
-------------+-------+------
-- Isabell   | si106 |    1
-- Camerin   | si106 |    0
-- Davie     | si106 |    0
-- Rio       | si106 |    0
-- Zennon    | si106 |    0
-- Masson    | si110 |    1
-- Caitlinn  | si110 |    0
-- Christina | si110 |    0
-- Rhuaridh  | si110 |    0
-- Siyona    | si110 |    0
-- Hector    | si206 |    1
-- Atli      | si206 |    0
-- Caley     | si206 |    0
-- Jonah     | si206 |    0
-- Miles     | si206 |    0