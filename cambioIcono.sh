#!/bin/bash

# Establecer la variable de entorno DBUS_SESSION_BUS_ADDRESS
export $(dbus-launch)

# Pedir al usuario que ingrese el nombre de la aplicación
app_str=$(zenity --entry --title="Buscar aplicación" --text="Ingrese el nombre de la aplicación:")

# Encontrar la ubicación del archivo .desktop de la aplicación con cadena de caracteres coincidentes
app_files=($(find / -name "*$app_str*.desktop" 2>/dev/null))
if [ ${#app_files[@]} -eq 0 ]; then
    zenity --error --title="Error" --text="No se encontró ningún archivo .desktop que coincida con \"$app_str\"."
    exit 1
elif [ ${#app_files[@]} -eq 1 ]; then
    app_file=${app_files[0]}
else
    options=()
    for app_file in "${app_files[@]}"; do
        app_name=$(basename "$app_file" .desktop)
        options+=(FALSE "$app_name")
    done
    app_index=$(zenity --list --title="Múltiples aplicaciones encontradas" --text="Seleccione una aplicación:" --column="Selección" --column="Aplicación" --radiolist "${options[@]}")
    if [ -z "$app_index" ]; then
        exit 1
    fi
    app_file=${app_files[$((app_index-1))]}
fi

# Obtener el nombre del archivo sin la extensión
app_name=$(basename "$app_file" .desktop)

# Obtener la ruta de la aplicación y ejecutarla
app_path=$(grep -oP '(?<=^Exec=).*' "$app_file" | sed 's/%.//g;s/ .*$//g')
eval "$app_path" &>/dev/null & disown

# Esperar a que la aplicación se inicie completamente
sleep 5

# Encontrar la ventana de la aplicación recién iniciada
win_str="$app_name"
win_id=$(xdotool search --name "$win_str" | tail -1)

# Mostrar una ventana de diálogo para elegir un archivo de imagen
icon_path=$(zenity --file-selection --title="Seleccionar imagen" --file-filter="Archivos de imagen (*.png *.jpg *.jpeg *.ico) | *.png; *.jpg; *.jpeg; *.ico")
if [ -z "$icon_path" ]; then
    zenity --error --title="Error" --text="No se ha seleccionado ningún archivo de imagen."
    exit 1
fi

# Cambiar el icono de la ventana de la aplicación
xprop -id "$win_id" -f _NET_WM_ICON_NAME 8u -set _NET_WM_ICON_NAME "$icon_path"

# Mostrar un mensaje de éxito
zenity --info --title="Éxito" --text="El icono de la aplicación \"$app_name\" se ha cambiado correctamente."
