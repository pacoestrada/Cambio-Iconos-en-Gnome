#!/bin/bash

# Establecer la variable de entorno DBUS_SESSION_BUS_ADDRESS
export DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/$(id -u)/bus

# Seleccionar la aplicación a la que se le quiere cambiar el icono
app=$(zenity --entry --title="Cambiar icono de aplicación" --text="Introduce el nombre de la aplicación:")

# Encontrar la ubicación del archivo .desktop de la aplicación con cadena de caracteres coincidentes
app_files=$(find / -name "*$app*.desktop" 2>/dev/null)

if [ -z "$app_files" ]; then
    zenity --error --title="Error" --text="No se encontró ningún archivo .desktop que coincida con \"$app\"."
    exit 1
fi

# Ofrecer las opciones de aplicaciones encontradas
app_file=$(zenity --list --title="Selecciona la aplicación" --text="Se encontraron varias aplicaciones que coinciden con \"$app\".\nSelecciona la aplicación a la que quieres cambiar el icono:" --column="Archivo" $app_files)

if [ -z "$app_file" ]; then
    exit 1
fi

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Seleccionar la imagen que se usará como nuevo icono
icon_path=$(zenity --file-selection --title="Selecciona una imagen" --file-filter="Imágenes (*.png *.jpg *.svg *.ico)")

if [ -z "$icon_path" ]; then
    exit 1
fi

# Copiar la imagen seleccionada a la carpeta de iconos de la aplicación
cp "$icon_path" "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"

# Actualizar la caché de iconos
gtk-update-icon-cache -f -t /usr/share/icons/hicolor

# Actualizar el archivo .desktop con la nueva ruta del icono
sed -i "s/^Icon=.*/Icon=$app_name/" "$app_file"

zenity --info --title="Cambio de icono exitoso" --text="El icono de \"$app\" ha sido cambiado con éxito."
