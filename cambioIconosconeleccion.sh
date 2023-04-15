#!/bin/bash

# Preguntar al usuario por la cadena de caracteres a buscar
app_str=$(zenity --entry --title="Seleccionar aplicación" --text="Introduce la cadena de caracteres para buscar la aplicación:")

# Encontrar la ubicación de todos los archivos .desktop que coincidan con la cadena
app_files=$(find / -name "*$app_str*.desktop" 2>/dev/null)

# Verificar si se encontraron archivos .desktop coincidentes
if [ -z "$app_files" ]; then
    zenity --error --title="Error" --text="No se encontró ningún archivo .desktop que coincida con \"$app_str\"."
    exit 1
fi

# Mostrar un cuadro de diálogo para que el usuario seleccione el archivo .desktop deseado
app_file=$(zenity --list --title="Seleccionar archivo .desktop" --column="Archivo" $app_files)

# Verificar si se seleccionó un archivo .desktop
if [ -z "$app_file" ]; then
    zenity --error --title="Error" --text="No se seleccionó ningún archivo .desktop."
    exit 1
fi

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Seleccionar la imagen que se usará como nuevo icono
icon_path=$(zenity --file-selection --title="Seleccionar imagen para el icono de $app_name" --file-filter="*.svg")

# Verificar si se seleccionó un archivo de imagen
if [ -z "$icon_path" ]; then
    zenity --error --title="Error" --text="No se seleccionó ninguna imagen para el icono de $app_name."
    exit 1
fi

# Copiar la imagen seleccionada a la carpeta de iconos de la aplicación
cp "$icon_path" "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"

# Actualizar la caché de iconos
gtk-update-icon-cache -f -t /usr/share/icons/hicolor

# Actualizar el archivo .desktop con la nueva ruta del icono
sed -i "s/^Icon=.*/Icon=$app_name/" "$app_file"

zenity --info --title="Icono cambiado" --text="El icono de $app_name ha sido cambiado con éxito."
