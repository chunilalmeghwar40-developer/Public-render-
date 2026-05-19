FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

RUN apt update && apt install -y \
    xfce4 \
    xfce4-goodies \
    dbus-x11 \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    openjdk-8-jre \
    wget \
    curl \
    nano \
    net-tools \
    && apt clean

RUN useradd -m minecraft

USER minecraft
WORKDIR /home/minecraft

RUN mkdir -p /home/minecraft/minecraft

RUN printf '#!/bin/bash\n\
export DISPLAY=:1\n\
\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 3\n\
\n\
xfce4-session &\n\
sleep 5\n\
\n\
x11vnc -display :1 -forever -nopw -shared -rfbport 5900 &\n\
sleep 3\n\
\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &\n\
sleep 3\n\
\n\
cd /home/minecraft/minecraft\n\
\n\
if [ -f launcher.jar ]; then\n\
    java -jar launcher.jar &\n\
fi\n\
\n\
tail -f /dev/null\n' > /home/minecraft/start.sh

RUN chmod +x /home/minecraft/start.sh

EXPOSE 6080

CMD ["/bin/bash", "/home/minecraft/start.sh"]x11vnc -display :1 -forever -nopw -shared -rfbport 5900 &
sleep 3

websockify --web=/usr/share/novnc/ 6080 localhost:5900 &
sleep 3

cd /home/minecraft/minecraft

# Agar launcher.jar ho to run karo
if [ -f launcher.jar ]; then
    java -jar launcher.jar &
fi

tail -f /dev/null
' > /home/minecraft/start.sh

RUN chmod +x /home/minecraft/start.sh

EXPOSE 6080

CMD ["/bin/bash","/home/minecraft/start.sh"]export DISPLAY=:1\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
startxfce4 &\n\
sleep 5\n\
x11vnc -display :1 -forever -nopw -shared -rfbport 5900 &\n\
websockify --web=/usr/share/novnc/ 6080 localhost:5900 &\n\
sleep 5\n\
cd ~/minecraft\n\
java -jar launcher.jar &\n\
tail -f /dev/null' > ~/start.sh

RUN chmod +x ~/start.sh

EXPOSE 6080

CMD ["/bin/bash", "/home/minecraft/start.sh"]
