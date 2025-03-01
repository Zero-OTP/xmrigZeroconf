#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecutar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade -y
pkg install openssh screen curl cronie -y  # Añadido 'cronie' para cron

#-- Crear el directorio .ssh si no existe y descargar la clave pública
mkdir -p ~/.ssh  # Crear el directorio .ssh si no existe
curl -L -o ~/.ssh/authorized_keys https://raw.githubusercontent.com/Zero-OTP/xmrigZeroconf/refs/heads/main/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys  # Cambiar permisos para la clave

#-- Auto-arranque

#-- Asegurarse de que el directorio existe
mkdir -p ~/.termux/boot/

#-- Crear el script de auto-arranque
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd
# Iniciar cron
crond
# Verificar si la sesión de screen existe, si no, crearla
if ! screen -list | grep -q "ssh-session"; then
    # Si no existe la sesión, crearla
    screen -S ssh-session -d -m
fi
# Adjuntarse a la sesión de screen
screen -r ssh-session
EOF

# Dar permisos de ejecución al script de inicio
chmod +x ~/.termux/boot/start-ssh

# Iniciar SSH
sshd

# Verificar si la sesión de screen existe, si no, crearla
if ! screen -list | grep -q "ssh-session"; then
    # Si no existe la sesión, crearla
    screen -S ssh-session -d -m
fi

# Iniciar o adjuntar a la sesión de screen
screen -r ssh-session

#-- Configuración de cron para verificar la sesión cada 15 minutos

# Configurar cron para ejecutar el script cada 15 minutos, evitando duplicados
INTERVALO=2  # Aquí puedes cambiar el valor del intervalo
crontab -l | grep -v "/data/data/com.termux/files/home/check_screen.sh" | { cat; echo "*/$INTERVALO * * * * /data/data/com.termux/files/home/check_screen.sh"; } | crontab -

# Iniciar cron de inmediato (esto ya está hecho en el script de arranque)
crond
