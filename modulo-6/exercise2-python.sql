-- Paso 1: La tabla ya fue creada por gmane.py
-- pero si la quisieras crear manualmente sería:
CREATE TABLE IF NOT EXISTS messages (
    id SERIAL, 
    email TEXT, 
    sent_at TIMESTAMPTZ,
    subject TEXT, 
    headers TEXT, 
    body TEXT
);

-- Paso 2: Crear el índice GIN para búsqueda de texto
-- Sin este índice las búsquedas serían lentas
CREATE INDEX messages_gin ON messages 
USING gin(to_tsvector('english', body));

-- Paso 3: Buscar y rankear por relevancia con ts_rank
-- Busca emails que contengan "personal" Y "learning"
-- y los ordena por cuántas veces aparecen las palabras
SELECT id, subject, email,
  ts_rank(to_tsvector('english', body), 
          to_tsquery('english', 'personal & learning')) AS ts_rank
FROM messages
WHERE to_tsquery('english', 'personal & learning') 
      @@ to_tsvector('english', body)
ORDER BY ts_rank DESC;

-- Paso 4: Buscar y rankear con ts_rank_cd
-- Igual que el anterior pero ordena por
-- qué tan CERCA están las palabras entre sí
SELECT id, subject, email,
  ts_rank_cd(to_tsvector('english', body), 
             to_tsquery('english', 'personal & learning')) AS ts_rank
FROM messages
WHERE to_tsquery('english', 'personal & learning') 
      @@ to_tsvector('english', body)
ORDER BY ts_rank DESC;