#!/bin/bash

# Verifica que se hayan pasado dos parámetros
if [ $# -ne 2 ]; then
    echo "Uso: $0 <archivo.yml> <repositorio_git>"
    exit 1
fi

# Parámetros
archivo=$1
repositorio=$2

# Verifica que el archivo YAML exista
if [ ! -f "$archivo" ]; then
    echo "Error: El archivo $archivo no existe."
    exit 1
fi

# Preparar un archivo CSV
csv_output="resultados.csv"
echo "Repositorio,Acción,Test Score,Max Score" > "$csv_output"

# Extraer los nombres de las acciones del archivo YAML, excluyendo la primera y última
acciones=$(grep -Po '(?<=  id: ).*' "$archivo" | sed '1d' | sed '$d')

# Verificar si se encontraron acciones
if [ -z "$acciones" ]; then
    echo "No se encontraron acciones en el archivo YAML después de eliminar la primera y la última."
    exit 1
fi

# Clonar el repositorio dado
#echo "Clonando el repositorio: $repositorio..."
#temp_dir=$(mktemp -d)
#git clone "$repositorio" "$temp_dir" || { echo "Error al clonar el repositorio."; exit 1; }
#cd "$temp_dir" || { echo "Error al acceder al repositorio clonado."; exit 1; }

cd $repositorio
echo "CAmbio al repositorio:"$repositorio

# Ejecutar las acciones con gh act
echo "Ejecutando acciones definidas en el archivo YAML..."
gh act -W "$archivo" > salida_act.log 2>&1

# Procesar la salida
echo "Analizando resultados..."
while read -r accion; do
    echo "Procesando resultados para acción: $accion..."
    # Buscar resultados para esta acción en la salida
    resultado=$(grep -E "│\s+$accion\s+\│\s+[0-9]+\s+\│\s+[0-9]+\s+\│" salida_act.log)
    if [[ "$resultado" =~ ^\│\ ([A-Za-z0-9]+)\ +\│\ ([0-9]+)\ +\│\ ([0-9]+)\ +\│$ ]]; then
        accion="${BASH_REMATCH[1]}"
        test_score="${BASH_REMATCH[2]}"
        max_score="${BASH_REMATCH[3]}"
        echo "$repositorio,$accion,$test_score,$max_score" >> "$csv_output"
    else
        echo "$repositorio,$accion,N/A,N/A" >> "$csv_output"
    fi
done <<< "$acciones"

# Mostrar archivo CSV generado
echo "Archivo CSV generado: $csv_output"
cat "$csv_output"

# Limpieza
echo "Limpiando el directorio temporal..."
rm -rf "$temp_dir"

