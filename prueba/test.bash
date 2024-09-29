#!/bin/bash

archivo=niveles3.txt
tl=7

nl=0
# Lee el archivo línea por línea y ejecuta el comando con cada línea como parámetro
while IFS= read -r parametro; do
  #salida=$(./sokoban validate -l "$parametro" 2>&1)
  #echo $salida>>salida2.txt
    ./sokoban validate -l "$parametro" 2>>salida3.txt
done < "$archivo"

