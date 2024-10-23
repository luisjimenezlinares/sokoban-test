#!/bin/bash

# Asignación de variables de entrada a variables locales
comando=$1
archivo_in=$2
archivo_out=$3
archivo_config=$(pwd)"/configure_test.txt"
array_in=()
array_out=()

PATH_LOCAL=$(pwd)

# Verifica si se proporcionan los parámetros de entrada correctos
if [ $# -ne 3 ]; then
  echo "Uso: $0 <comando> <archivo_entrada> <archivo_salida>"
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
    programa="./sokoban"
    ;;
  PYTHON)
    # Verificamos si existe el archivo requirements.txt
    if [ -f "requirements.txt" ]; then
      echo "Instalando dependencias desde requirements.txt..."
      pip install -r requirements.txt
    fi
    programa="python3 ./sokoban.py"
    ;;
  JAVA)
    programa="java --enable-preview -jar ./sokoban.jar"
    if [ ! -f INSTALLEDJAVA ]; then
      touch INSTALLEDJAVA
      #wget download.oracle.com/java/23/latest/jdk-23_linux-x64_bin.deb > /dev/null
      #sudo dpkg -i jdk-23_linux-x64_bin.deb
      #sudo update-alternatives --set java /usr/lib/jvm/jdk-23.0.1-oracle-x64/bin/java
      #java --version
      sudo apt-get install openjdk-21-jdk > /dev/null
      java --version
    fi
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

    salida=$(eval $programa $comando "$linea" )
    
    # Eliminar espacios en blanco, tabuladores y retornos de carro
    salida_limpia=$(echo "$salida" | tr -d '[:space:]')
    salida_correcta_limpia=$(echo "${array_out[$i]}" | tr -d '[:space:]')

    if ! diff <(echo "$salida_limpia") <(echo "$salida_correcta_limpia") > /dev/null; then
        echo "$nfail: $programa $comando $linea"
        echo "Tu salida:"
        echo "$salida_limpia"
        echo "Salida correcta:"
        echo "$salida_correcta_limpia"
        ((nfail++))
    fi
    ((i++))
done
echo "Número de fallos: $nfail"
exit $nfail

