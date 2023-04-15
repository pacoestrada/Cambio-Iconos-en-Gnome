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

# Obtener la ruta de la aplicación
app_path=$(grep -oP '(?<=^Exec=).*' "$app_file" | sed 's/%.//g;s/ .*$//g')

# Obtener la ruta del icono
icon_path=$(grep -oP '(?<=^Icon=).*' "$app_file" | sed 's/%.//g;s/ .*$//g')

# Cambiar el icono de la aplicación
gsettings set org.gnome.desktop.interface icon-theme "$(gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g")"
gtk-update-icon-cache -f "$HOME/.icons/$(basename "$icon_path" .png)"
sed -i "s#Icon=$icon_path#Icon=$HOME/.icons/$(basename "$icon_path" .png).svg#g" "$app_file"

# Ejecutar la aplicación
eval "$app_path" &>/dev/null & disown

# Mostrar un mensaje de éxito
zenity --info --title="Éxito" --text="La aplicación \"$app_name\" se ha iniciado correctamente."
