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

# Pedir al usuario que seleccione un archivo de imagen
img_file=$(zenity --file-selection --title="Seleccionar archivo de imagen para icono" --file-filter="Imágenes png|*.png")

# Obtener la ruta del archivo .desktop de la aplicación
desktop_file=$(grep -r -l "$app_path" /usr/share/applications | head -n 1)

# Obtener la clave de gsettings para el icono de la aplicación
gsettings_key=$(grep -oP '(?<=Icon=).*' "$desktop_file")

# Establecer el nuevo icono con gsettings
gsettings set org.gnome.desktop.interface icon-theme 'Adwaita'
gsettings set org.gnome.desktop.interface icon-theme 'gnome'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-dark'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-light'
gsettings set org.gnome.desktop.interface icon-theme 'Humanity-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Humanity'

gsettings set org.gnome.desktop.interface icon-theme 'gnome'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-dark'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-light'
gsettings set org.gnome.desktop.interface icon-theme 'Humanity-Dark'
gsettings set org.gnome.desktop.interface icon-theme 'Humanity'

gsettings set org.gnome.desktop.interface icon-theme 'gnome'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-dark'
gsettings set org.gnome.desktop.interface icon-theme 'ubuntu-mono-light'
