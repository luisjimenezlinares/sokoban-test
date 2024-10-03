#!/bin/bash

# Asignación de variables de entrada a variables locales
comando=$1
archivo_in=$2
archivo_out=$3
archivo_error=$(pwd)/$4
archivo_config="configure_test.txt"
array_in=()
array_out=()

PATH_LOCAL=$(pwd)

# Verifica si se proporcionan los parámetros de entrada correctos
if [ $# -ne 4 ]; then
  echo "Uso: $0 <comando> <archivo_entrada> <archivo_salida> <archivo_error>"
  exit 1
fi

# Verificamos que el archivo de entrada exista
if [ ! -f "$archivo_in" ]; then
  echo "Error: El archivo '$archivo_in' no existe."
  exit 1
fi

# Leemos el archivo de entrada en un array
while IFS= read -r linea; do
  array_in+=("$linea")
done < "$archivo_in"

# Verificamos que el archivo de salida de resultados exista
if [ ! -f "$archivo_out" ]; then
  echo "Error: El archivo '$archivo_out' no existe."
  exit 1
fi

# Eliminamos el fichero de error si existe
if [  -f "$archivo_error" ]; then
  rm "$archivo_error"
fi

# Identificamos lenguaje de programación y carpeta del ejecutable
if [ ! -f "$archivo_config" ]; then
  echo "Error: El archivo de configuración no existe."
  exit 1
fi

# Leemos el archivo de configuración
# Primera línea: lenguaje de programación [C#|PYTHON|JAVA|C++|GO]
# la leemos con sed y la guardamos en la variable lenguaje
lenguaje=$(sed -n '1p' "$archivo_config")

# Segunda línea: carpeta del ejecutable
# la leemos con sed y la guardamos en la variable carpeta
carpeta=$(sed -n '2p' "$archivo_config")

# Comprobamos que la carpeta del ejecutable exista
if [ ! -d "$carpeta" ]; then
  echo "Error: La carpeta '$carpeta' no existe."
  exit 1
fi

# Nos situamos en la carpeta del ejecutable
cd "$carpeta"

# Construimos el programa para ejecutar el programa
# en función del lenguaje de programación
case $lenguaje in
  C#)
    programa="./sokoban.exe"
    ;;
  PYTHON)
    programa="python3 ./sokoban.py"
    ;;
  JAVA)
    programa="java -jar ./sokoban.jar"
    ;;
  C++)
    programa="./sokoban"
    ;;
  GO)
    programa="./sokoban"
    ;;
  *)
    echo "Error: Lenguaje de programación no soportado."
    exit 1
    ;;
esac



# Leemos el archivo de salida en un array
bloque=""
while IFS= read -r linea; do
  if [ -z "$linea" ]; then
    array_out+=("$bloque")
    bloque=""
  else
    bloque+="$linea"$'\n'
  fi
done < "$PATH_LOCAL"/"$archivo_out"

# Procesar el último bloque si no termina en línea vacía
if [ -n "$bloque" ]; then
  array_out+=("$bloque")
fi

# Inicializar contador de fallos
nfail=0


# Comprobamos entradas y salidas
nentradas=${#array_in[@]}
i=0
for linea in "${array_in[@]}";do


    salida=$("$programa" "$comando" "$linea" 2>&1)
    salida+=$'\n'
    
    if ! diff <(echo "$salida") <(echo "${array_out[$i]}") > /dev/null; then
        echo "$nfail: ./sokoban $comando $linea" >>"$archivo_error"
        echo "Tu salida:" >>"$archivo_error"
        echo "$salida" >>"$archivo_error"
        echo "Salida correcta:" >>"$archivo_error"
        echo "${array_out[$i]}" >>"$archivo_error"
        ((nfail++))
    fi
    ((i++))
done

# Si hay fallos añadimos al repositorio el fichero de error
# y lo sincronizamos con el repositorio remoto
# if [ $nfail -gt 0 ]; then
#   cd $PATH_LOCAL
#   git add "$archivo_error" > /dev/null
#   git commit -m "Añadir fichero de error" > /dev/null
#   git push origin main > /dev/null
#  fi
# Mostrar el número de fallos
echo "$nfail"

