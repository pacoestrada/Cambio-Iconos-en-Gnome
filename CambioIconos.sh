#!/bin/bash

# Seleccionar la aplicación a la que se le quiere cambiar el icono
echo "Selecciona la aplicación a la que quieres cambiar el icono:"
read app

# Encontrar la ubicación del archivo .desktop de la aplicación
app_file=$(locate -r "/$app.desktop$")

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Seleccionar la imagen que se usará como nuevo icono
echo "Selecciona la imagen que quieres usar como nuevo icono:"
read icon_path

# Copiar la imagen seleccionada a la carpeta de iconos de la aplicación
cp "$icon_path" "/usr/share/icons/hicolor/scalable/apps/$app_name.svg"

# Actualizar la caché de iconos
gtk-update-icon-cache -f -t /usr/share/icons/hicolor

# Actualizar el archivo .desktop con la nueva ruta del icono
sed -i "s/^Icon=.*/Icon=$app_name/" "$app_file"

echo "El icono de $app ha sido cambiado con éxito."
