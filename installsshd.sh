#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecutar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade -y
pkg install openssh screen -y

#-- Auto-arranque

#-- Asegurarse de que el directorio existe
mkdir -p ~/.termux/boot/
#-- Crear el script de auto-arranque
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
# Iniciar o adjuntar a la sesión de screen
screen -S ssh-session -d -m || screen -r ssh-session
EOF

# Dar permisos de ejecución al script de inicio
chmod +x ~/.termux/boot/start-ssh

# Iniciar SSH
sshd
# Iniciar o adjuntar a la sesión de screen
screen -S ssh-session -d -m || screen -r ssh-session