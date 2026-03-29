import psycopg2
import requests
import hidden

# Conexión
secrets = hidden.secrets()
conn = psycopg2.connect(
    host=secrets['host'],
    port=secrets['port'],
    database=secrets['database'],
    user=secrets['user'],
    password=secrets['pass'],
    connect_timeout=3
)
cur = conn.cursor()

# Crear la tabla
cur.execute('CREATE TABLE IF NOT EXISTS pokeapi (id INTEGER, body JSONB);')
conn.commit()

# Loop del 1 al 100
for i in range(1, 101):
    url = f'https://pokeapi.co/api/v2/pokemon/{i}'
    
    response = requests.get(url)
    texto = response.text
    
    print(f'Descargando pokemon {i}...')
    
    cur.execute('INSERT INTO pokeapi (id, body) VALUES (%s, %s)', (i, texto))

conn.commit()
print('Listo! 100 pokemons cargados.')
cur.close()