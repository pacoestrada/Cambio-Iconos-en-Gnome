#!/bin/bash

# Comprobar si el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
  zenity --error --text="Por favor, ejecuta este script como root."
  exit 1
fi

# Pedir al usuario que introduzca caracteres para localizar una aplicación
busqueda=$(zenity --entry --text="Introduce caracteres para buscar una aplicación:")

# Localizar aplicaciones que coinciden y permitir al usuario elegir una
aplicaciones=$(find /usr/share/applications -iname "*${busqueda}*.desktop")
lista=$(basename -a $aplicaciones | sed 's/\.desktop//g' | awk '{print NR,$0}')

app_elegida=$(zenity --list --text="Elige la aplicación que deseas modificar:" --column="#" --column="Aplicación" $lista)

if [[ -z "$app_elegida" ]]; then
  zenity --error --text="No se seleccionó ninguna aplicación."
  exit 1
fi

app_final=$(echo "$aplicaciones" | sed -n "${app_elegida}p")

# Pedir confirmación de que es la aplicación correcta
zenity --question --text="¿Quieres cambiar el icono de $(basename $app_final | sed 's/\.desktop//g')?"
if [[ $? -ne 0 ]]; then
  exit 1
fi

# Localizar la ruta del icono predeterminado de la aplicación
icon_path=$(grep -Po 'Icon=\K.*' "$app_final")

# Permitir al usuario seleccionar un nuevo icono y almacenar la ruta absoluta
new_icon=$(zenity --file-selection --file-filter='*.png' --title="Selecciona un nuevo icono (debe ser .png)")

if [[ -z "$new_icon" ]]; then
  zenity --error --text="No se seleccionó ningún icono."
  exit 1
fi

# Redimensionar el icono .png a 32x32px
convert "$new_icon" -resize 32x32! "$new_icon"

# Cambiar el icono de la aplicación de forma permanente
sed -i "s|Icon=$icon_path|Icon=$new_icon|g" "$app_final"

# Mostrar un mensaje parpadeante de éxito en Zenity
(
  for i in $(seq 1 3); do
    echo "# Cambiando el icono..."
    sleep 0.5
  done
  echo "100"
) | zenity --progress --title="Cambio de icono" --text="Cambiando el icono..." --auto-close --pulsate

zenity --info --text="¡El icono de la aplicación ha sido cambiado con éxito!"

