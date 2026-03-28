import psycopg2
import hidden

# 1. Cargamos tus llaves secretas [5]
secrets = hidden.secrets()

# 2. Conectamos Python con la base de datos [5, 6]
conn = psycopg2.connect(host=secrets['host'],
        port=secrets['port'],
        database=secrets['database'], 
        user=secrets['user'], 
        password=secrets['pass'], 
        connect_timeout=3,
        sslmode='require')

cur = conn.cursor() # El mensajero [3]

# 5. Creamos la "estantería" (la tabla) para el libro [2]
# Le ponemos de nombre 'monte_cristo' para que sea fácil
print("Limpiando y creando la tabla...")
cur.execute('DROP TABLE IF EXISTS monte_cristo CASCADE;')
cur.execute('CREATE TABLE monte_cristo (id SERIAL, body TEXT);')
conn.commit()

# 6. Abrimos el archivo del libro y lo leemos
# IMPORTANTE: El archivo tiene que llamarse exactamente así en tu carpeta
nombre_archivo = "The Count of Monte Cristo.txt"

print(f"Leyendo el libro: {nombre_archivo}...")

with open(nombre_archivo, "r", encoding='utf-8') as libro:
    parrafo = ""
    contador = 0
    
    for linea in libro:
        linea = linea.strip()
        if len(linea) < 1: # Si la línea está vacía, es que terminó un párrafo
            if len(parrafo) > 1:
                # Usamos el cursor para meter el párrafo en la base de datos [1, 2]
                sql = 'INSERT INTO monte_cristo (body) VALUES (%s);'
                cur.execute(sql, (parrafo, ))
                
                parrafo = "" # Vaciamos para el siguiente párrafo
                contador = contador + 1
                
                # Cada 50 párrafos, le damos al botón de "Guardar" (commit) [3]
                if contador % 50 == 0:
                    conn.commit()
                    print(f"Guardados {contador} párrafos...")
        else:
            parrafo = parrafo + " " + linea

# Un último commit para guardar lo que falte
conn.commit()
print(f"¡Terminado! Se cargaron {contador} párrafos de El Conde de Montecristo.")

cur.close()
conn.close()