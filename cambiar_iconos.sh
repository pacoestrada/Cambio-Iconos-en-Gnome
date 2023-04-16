#!/bin/bash

# Mostrar la primera ventana de información y esperar a que el usuario haga clic en "Continuar"
zenity --info --text="Este script debe ejecutarse como root y requiere los paquetes Zenity e ImageMagick instalados. Los iconos deben estar en formato .png. Después de cambiar los iconos, la sesión de Gnome se reiniciará." --ok-label="Continuar"

# Mostrar la segunda ventana de información y esperar a que el usuario haga clic en "Ejecutar"
zenity --info --text="El código fuente se puede encontrar en: https://github.com/pacoestrada/Cambio-Iconos-en-Gnome/blob/master/cambiar_iconos.sh" --ok-label="Ejecutar"

# Comprobar si el script se ejecuta como root
if [[ $EUID -ne 0 ]]; then
  zenity --error --text="Por favor, ejecuta este script como root."
  exit 1
fi

# Pedir al usuario que introduzca caracteres para localizar una aplicación
busqueda=$(zenity --entry --text="Introduce caracteres para buscar una aplicación:")

# Resto del código...
# ...

# Mostrar un mensaje de éxito en Zenity
zenity --info --text="¡El icono de la aplicación ha sido cambiado con éxito!"

# Iniciar cuenta atrás de 5 segundos en segundo plano
(
  for i in $(seq 5 -1 0); do
    echo "# Reiniciando en $i segundos..."
    sleep 1
    echo $(( (5 - i) * 20 ))
  done
  gnome-session-quit --no-prompt --logout
) &

# Mostrar ventana con botón "Reiniciar ya"
zenity --question --text="Su sesión en Gnome se reiniciará para que los cambios tengan efecto. Reiniciando en 5 segundos..." --ok-label="Reiniciar ya" --cancel-label="Cancelar"

# Reiniciar sesión de Gnome si el usuario presiona "Reiniciar ya"
if [[ $? -eq 0 ]]; then
  gnome-session-quit --no-prompt --logout
fi
