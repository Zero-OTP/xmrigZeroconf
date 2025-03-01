#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecutar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade -y
pkg install openssh screen -y

# Crear el script de auto-arranque con la nueva estructura
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