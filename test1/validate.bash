#!/bin/bash
cd sokoban-test/test1

# Verifica si los archivos de entrada y resultado existen
if [ ! -f "input.txt" ] || [ ! -f "salida.txt" ]; then
  echo "Error: 'input.txt' o 'salida.txt' no se encuentran."
  exit 1
fi

# Número de líneas de salida del comando
numlineas=8  # Cambiar este valor al número correcto de líneas de salida

# Variables para controlar la posición en resultado.txt
linea_actual=1
valid=true
ntest=1

# Itera sobre cada línea de input.txt
while IFS= read -r parametro; do
  # Ejecuta el comando con el parámetro actual
  salida=$(../bin/sokoban validate -l "$parametro" 2>&1)
  
  # Extrae las líneas correspondientes de resultado.txt
  resultado_esperado=$(sed -n "${linea_actual},$(($linea_actual + $numlineas - 1))p" salida.txt)

    #echo "salida:" $ntest ":" $parametro
    #echo $salida
    #echo "resultado"
    #echo $resultado_esperado
    
    ntest=$(($ntest+1))
  
  # Compara la salida con el resultado esperado
  if [ "$salida" != "$resultado_esperado" ]; then
    #echo "Error: El resultado del comando para el parámetro '$parametro' no coincide."
    valid=false
    echo $ntest ":" $parametro >>../../error.txt
    echo "salida:" >>../../error.txt
    echo $salida >>../../error.txt
    echo "resultado" >>../../error.txt
    echo $resultado_esperado >>../../error.txt
  fi
  
  # Actualiza la línea actual para la siguiente comparación
  linea_actual=$(($linea_actual + $numlineas))

done < "input.txt"

# Mensaje final
if [ "$valid" = true ]; then
  echo "0"
else
  echo "1"
fi

