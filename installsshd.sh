#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecurtar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade
pkg install openssh -y
sshd

#-- Regenerar llaves manualmente....
#mkdir -p ~/.ssh
#ssh-keygen -A

#-- Editar config si queremos que este cambiada....
#nano $PREFIX/etc/ssh/sshd_config

# Crear el script con la nueva estructura
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
EOF

#-- mostrar IP
ifconfig

#-- Para conectarse desde otro dispositivo ....
#ssh -p 8022 usuario@IP_DEL_DISPOSITIVO