#!/bin/bash

comando=$1
archivo_out=$3
array_out=()
archivo_in=$2
archivo_error=$4
array_in=()


# Verifica si se proporciona los parametros de entrada
if [ $# -ne 4 ]; then
  echo "Uso: $0 comando <archivo_entrada> <archivo_salida> <archivo_error>"
  exit 1
fi

#Construimos el array de entrada

#Verificamos que el archivo in exista
if [ ! -f "$archivo_in" ]; then
   echo "Error:El archivo '$archivo_in' no existe"
   exit 1
fi

# Leemos el fichero de entrada
while IFS= read -r linea; do
  array_in+=("$linea")
done < "$archivo_in"

# Determinamos la cantidad de entradas en elficero de entrada
nentradas=${#array_in[@]}

# Verifica que el archivo out exista
if [ ! -f "$archivo_out" ]; then
  echo "Error: El archivo '$archivo_out' no existe."
  exit 1
fi

# Inicializa una variable para acumular el bloque de líneas
bloque=""

# Leer el archivo línea por línea
while IFS= read -r linea; do
  if [ -z "$linea" ]; then
    # Si la línea es vacía, procesa el bloque acumulado y reinicia
    array_out+=("$bloque")
    #echo "Procesando bloque:"
    #echo "$bloque"
    #echo "--------------------"
    
    # Limpia el bloque para el siguiente conjunto de líneas
    bloque=""
  else
    # Si la línea no está vacía, acumúlala en el bloque
    bloque+="$linea"$'\n'
  fi
done < "$archivo_out"

# Procesa el último bloque si no termina en línea vacía
if [ -n "$bloque" ]; then
  #echo "Procesando último bloque:"
  #echo "$bloque"
  #echo "--------------------"
  array_out+=$bloque
fi

nfail=0
#Comprobamos entradas y salida
for ((i=0;i<$nentradas;i++)) do
    
    
    ./sokoban  $comando ${array_in[$i]}
    echo "${array_in[$i]}"
    salida=$(./sokoban  $comando "${array_in[$i]}" 2>&1)
    salida+=$'\n'

    if [ "$salida" != "${array_out[$i]}" ]; then
        echo "$nfail:${array_in[$i]}" >>"$archivo_error"
        echo "Tu salida:">>"$archivo_error"
        echo "$salida">>"$archivo_error"
        echo "Salida correcta">>"$archivo_error"
        echo "${array_out[$i]}">>"$archivo_error"
        nfail=$(($nfail+1))
    fi
done
echo "$nfail"

