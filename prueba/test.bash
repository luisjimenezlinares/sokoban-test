#!/bin/bash

accion=$1
archivo_in=$2
archivo_out=$3

tl=7

nl=0
# Lee el archivo línea por línea y ejecuta el comando con cada línea como parámetro

#borrar fichero de salida si existe
if [  -f "$archivo_out" ]; then
  rm $archivo_out
fi
while IFS= read -r parametro; do
  #salida=$(./sokoban validate -l "$parametro" 2>&1)
  #echo $salida>>salida2.txt
    ./sokoban $accion  "$parametro" 2>>"$archivo_out"
done < "$archivo_in"

