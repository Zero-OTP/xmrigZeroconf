#!/data/data/com.termux/files/usr/bin/sh

#-- Instalar y ejecutar
echo "Actualizando paquetes e instalando..."
pkg update && pkg upgrade -y
pkg install openssh screen curl -y  # Añadido 'cronie' para cron

#-- Crear el directorio .ssh si no existe y descargar la clave pública
mkdir -p ~/.ssh
curl -L -o ~/.ssh/authorized_keys https://raw.githubusercontent.com/Zero-OTP/xmrigZeroconf/refs/heads/main/id_rsa.pub
chmod 600 ~/.ssh/authorized_keys  # Cambiar permisos para la clave

#-- Auto-arranque
mkdir -p ~/.termux/boot/

# Crear el script de auto-arranque (revisado)
cat <<EOF > ~/.termux/boot/start-ssh
#!/data/data/com.termux/files/usr/bin/sh

LOCKFILE=~/.termux/boot/startup.lock
if [ -e "$LOCKFILE" ]; then
    echo "El script ya se está ejecutando. Saliendo..."
    exit 1
fi
touch "$LOCKFILE"
trap 'rm -f "$LOCKFILE"' EXIT  # Elimina el lock al salir

# Solo ejecuta esto si NO estamos dentro de una sesión de screen
sleep 5
if [ -z "$STY" ]; then  
    sshd

    # Eliminar sesiones de screen muertas SOLO si no hay una activa
    if ! screen -list | grep -q "\.ssh-session"; then
        rm -rf ~/.screen/*
        screen -dmS ssh-session
        sleep 1  # Esperar un segundo para evitar inconsistencias
        echo "Sesión ssh-session creada."
    else
        echo "Sesión ssh-session ya en ejecución."
        if screen -list | grep -qE "\.ssh-session\s+\(Dead|Remote or dead\)"; then
            echo "Sesión muerta, destruyendo..."
            rm -rf ~/.screen/*
            screen -dmS ssh-session  # Reiniciar sesión si estaba muerta
            sleep 1
        fi

        # Solo adjuntar si NO estás dentro de screen y no está ya adjunta
        if [ -z "$STY" ] && ! screen -list | grep -q "\.ssh-session.*(Attached)"; then
            screen -r ssh-session
            echo "Start-SSH - Entro en la sesión automáticamente!"
        else
            echo "Ya estás dentro de una sesión de screen o ya está adjunta."
        fi
    fi
fi
EOF

# Dar permisos de ejecución al script de inicio
chmod +x ~/.termux/boot/start-ssh
chmod 755 ~/.termux/boot/start-ssh

# Iniciar SSH
sshd

#-- Configuración de cron para verificar la sesión cada 2 minutos
#chmod +x ~/check_screen.sh
#INTERVALO=2
#crontab -l | grep -v "check_screen.sh" | { cat; echo "*/$INTERVALO * * * * ~/check_screen.sh"; } | crontab -

# Iniciar cron de inmediato
#if ! pgrep -x "crond" > /dev/null; then
#    rm -f /data/data/com.termux/files/usr/var/run/crond.pid
#    crond
#fi

# Agregar el script de inicio a ~/.bashrc solo si no está ya agregado
if ! grep -Fxq "bash ~/.termux/boot/start-ssh" ~/.bashrc; then
    echo "bash ~/.termux/boot/start-ssh" >> ~/.bashrc
fi

# **Eliminar sesiones de screen solo si no hay ninguna activa**
rm -rf ~/.screen/*
screen -dmS ssh-session
echo "Sesión ssh-session creada. Usa 'screen -r -d ssh-session' para utilizarla y arrancar ./xmrig-mine"
#screen -r ssh-session