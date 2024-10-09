#!/bin/bash

prog=$1
accion=$2
archivo_in=$3
archivo_out=$4

tl=7

nl=0
# Lee el archivo línea por línea y ejecuta el comando con cada línea como parámetro

#borrar fichero de salida si existe
if [  -f "$archivo_out" ]; then
  rm $archivo_out
fi
while IFS= read -r parametro; do
    eval $prog $accion  "$parametro" >>"$archivo_out"
done < "$archivo_in"

