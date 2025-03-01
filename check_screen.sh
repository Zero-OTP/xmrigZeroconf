#!/data/data/com.termux/files/usr/bin/sh
# Comprobar si la sesión de screen está adjunta
if ! screen -list | grep -q "ssh-session.*(Attached)"; then
    # Si no está adjunta, intentar adjuntarse
    screen -r ssh-session
fi