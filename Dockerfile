FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1

# Install desktop + VNC + Java
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
    unzip \
    nano \
    firefox \
    && apt clean

# Create user
RUN useradd -m minecraft
USER minecraft
WORKDIR /home/minecraft

# Create folders
RUN mkdir -p ~/minecraft

# Download old Minecraft launcher
RUN wget -O ~/minecraft/launcher.jar \
https://launcher.mojang.com/download/Minecraft.jar

# Create startup script
RUN echo '#!/bin/bash\n\
export DISPLAY=:1\n\
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
