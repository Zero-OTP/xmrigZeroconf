#!/data/data/com.termux/files/usr/bin/sh
# Comprobar si la sesión de screen existe pero está DETACHED
if screen -list | grep "ssh-session.*Detached"; then
    # Si la sesión existe y está detached, adjuntarse
    screen -r ssh-session
    echo "Check screen!"
    echo "Estamos en la sesion: $STY"
fi