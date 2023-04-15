#!/bin/bash

# Solicitar al usuario la cadena de caracteres que coincida con el nombre de la aplicación
app_str=$(zenity --entry --title="Cambiar icono de aplicación" --text="Ingresa una cadena de caracteres que coincida con el nombre de la aplicación:")

# Encontrar la ubicación del archivo .desktop de la aplicación con cadena de caracteres coincidentes
app_file=$(find / -name "*$app_str*.desktop" 2>/dev/null)

if [ -z "$app_file" ]; then
    zenity --error --title="Error" --text="No se encontró ningún archivo .desktop que coincida con \"$app_str\"."
    exit 1
fi

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Confirmar que es la aplicación a la que se le quiere cambiar el icono
confirm=$(zenity --question --title="Confirmar" --text="¿Deseas cambiar el icono de la aplicación \"$app_name\"?")

if [ "$?" = "1" ] || [ "$confirm" = "false" ]; then
    zenity --info --title="Operación cancelada" --text="No se ha cambiado el icono de \"$app_name\"."
    exit 1
fi

# Solicitar al usuario la ruta de la imagen que se usará como nuevo icono
icon_path=$(zenity --file-selection --title="Seleccionar imagen" --file-filter="Imágenes (*.png *.jpg *.jpeg *.svg) | *.png *.jpg *.jpeg *.svg")

if [ -z "$icon_path" ]; then
    zenity --error --title="Error" --text="No se ha seleccionado ninguna imagen."
    exit 1
fi

# Copiar la imagen seleccionada a la carpeta de iconos de la aplicación
cp "$icon_path" "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"

# Actualizar la caché de iconos
gtk-update-icon-cache -f -t /usr/share/icons/hicolor

# Actualizar el archivo .desktop con la nueva ruta del icono
sed -i "s/^Icon=.*/Icon=$app_name/" "$app_file"

zenity --info --title="Operación completada" --text="El icono de \"$app_name\" ha sido cambiado con éxito."
