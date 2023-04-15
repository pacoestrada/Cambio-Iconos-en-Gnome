#!/bin/bash

# Encontrar la ubicación del archivo .desktop de la aplicación con cadena de caracteres coincidentes
echo "Ingresa una cadena de caracteres que coincida con el nombre de la aplicación:"
read app_str

app_file=$(find / -name "*$app_str*.desktop" 2>/dev/null)

if [ -z "$app_file" ]; then
    echo "No se encontró ningún archivo .desktop que coincida con \"$app_str\"."
    exit 1
fi

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Confirmar que es la aplicación a la que se le quiere cambiar el icono
echo "¿Deseas cambiar el icono de la aplicación \"$app_name\"? [s/n]"
read confirm

if [ "$confirm" != "s" ]; then
    echo "Operación cancelada."
    exit 1
fi

# Seleccionar la imagen que se usará como nuevo icono
echo "Selecciona la imagen que quieres usar como nuevo icono:"
read icon_path

# Copiar la imagen seleccionada a la carpeta de iconos de la aplicación
cp "$icon_path" "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"

# Actualizar la caché de iconos
gtk-update-icon-cache -f -t /usr/share/icons/hicolor

# Actualizar el archivo .desktop con la nueva ruta del icono
sed -i "s/^Icon=.*/Icon=$app_name/" "$app_file"

echo "El icono de $app_name ha sido cambiado con éxito."
