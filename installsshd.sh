#!/bin/bash

echo "Necesitamos instalar Termux:Boot antes de empezar."
echo "¡¡Ve e instálala ahora!!"
echo "No abras la aplicación hasta que se haya creado la configuración."
echo
read -p "¿Está Termux:Boot instalado? [s/N] " respuesta

# Convertimos la respuesta a minúsculas para evitar problemas con mayúsculas
respuesta=${respuesta,,}

# Si la respuesta no es "s", terminamos el script
[[ "$respuesta" != "s" ]] && { echo "Instala Termux:Boot y ejecuta el script nuevamente. Saliendo..."; exit 1; }

#-- Instalar y ejecurtar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade
pkg install openssh
sshd

#-- Regenerar llaves manualmente....
#mkdir -p ~/.ssh
#ssh-keygen -A

#-- Editar config si queremos que este cambiada....
#nano $PREFIX/etc/ssh/sshd_config

#-- Crear script de auto inicio
mkdir -p ~/.termux/boot/
echo "sshd" > ~/.termux/boot/start-ssh
chmod +x ~/.termux/boot/start-ssh

#-- mostrar IP
ifconfig

#-- Para conectarse desde otro dispositivo ....
#ssh -p 8022 usuario@IP_DEL_DISPOSITIVO