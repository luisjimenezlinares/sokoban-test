#!/bin/bash

# Asignación de variables
comando=$1
archivo_in=$2
archivo_out=$3
archivo_error=$4
array_in=()
array_out=()

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

# Leemos el archivo de salida en un array
bloque=""
while IFS= read -r linea; do
  if [ -z "$linea" ]; then
    array_out+=("$bloque")
    bloque=""
  else
    bloque+="$linea"$'\n'
  fi
done < "$archivo_out"

# Procesar el último bloque si no termina en línea vacía
if [ -n "$bloque" ]; then
  array_out+=("$bloque")
fi

# Inicializar contador de fallos
nfail=0

# Crear o limpiar el archivo de error
> "$archivo_error"

# Comprobamos entradas y salidas
nentradas=${#array_in[@]}
i=0
for linea in "${array_in[@]}";do

    ejecuta="$comando $linea"
./sokoban $ejecuta
    salida=$(./sokoban $ejecuta 2>&1)
    
    if ! diff <(echo "$salida") <(echo "${array_out[$i]}") > /dev/null; then
        echo "$nfail: ./sokoban $ejecuta" >>"$archivo_error"
        echo "Tu salida:" >>"$archivo_error"
        echo "$salida" >>"$archivo_error"
        echo "Salida correcta:" >>"$archivo_error"
        echo "${array_out[$i]}" >>"$archivo_error"
        ((nfail++))
    fi
    ((i++))
done

# Mostrar el número de fallos
echo "$nfail"

