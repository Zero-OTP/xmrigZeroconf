#!/data/data/com.termux/files/usr/bin/sh
# Comprobar si la sesión de screen existe
if screen -list | grep -q "\.ssh-session"; then
    # Si la sesión existe, intentar adjuntarse
    screen -r ssh-session
fi