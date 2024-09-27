#!/bin/bash
dirtest=1 # Cambiar este valor al número de la carpeta de test
finput=test$dirtest/input.txt
foutput=test$dirtest/salida.txt
pathbin=bin # Cambiar este valor si la carpeta de ejecutables es distinta
patherror=.. # Cambiar este valor si la carpeta de errores es distinta
numlineas=8  # Cambiar este valor al número correcto de líneas de salida para el comando


# Verifica si los archivos de entrada y resultado existen
if [ ! -f $finput ] || [ ! -f $foutput ]; then
  echo "Error: "$finput" o "$foutput" no se encuentran."
  exit 1
fi

# Si hay un fichero de errores anterior se borrar
if [ -f $patherror/error_$dirtest.txt ]; then
  rm $patherror/error_$dirtest.txt
fi



# Variables para controlar la posición en resultado.txt
linea_actual=1
valid=true
ntest=1

# Itera sobre cada línea de input.txt
while IFS= read -r parametro; do
  # Ejecuta el comando con el parámetro actual
  salida=$($pathbin/sokoban validate -l "$parametro" 2>&1)
  
  # Extrae las líneas correspondientes de resultado.txt
  resultado_esperado=$(sed -n "${linea_actual},$(($linea_actual + $numlineas - 1))p" $foutput)
    
  ntest=$(($ntest+1))
  
  # Compara la salida con el resultado esperado
  if [ "$salida" != "$resultado_esperado" ]; then
    #echo "Error: El resultado del comando para el parámetro '$parametro' no coincide."
    valid=false
    echo $ntest ":" $parametro >>$patherror/error_$dirtest.txt
    echo "salida:" >>$patherror/error_$dirtest.txt
    echo $salida >>$patherror/error_$dirtest.txt
    echo "resultado" >>$patherror/error_$dirtest.txt
    echo $resultado_esperado >>$patherror/error_$dirtest.txt
  fi
  
  # Actualiza la línea actual para la siguiente comparación
  linea_actual=$(($linea_actual + $numlineas))

done < $finput

# Mensaje final
if [ "$valid" = true ]; then
  echo "0"
else
  echo "1"
fi

