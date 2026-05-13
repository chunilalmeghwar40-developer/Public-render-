FROM ubuntu:22.04

RUN apt update && apt install -y \
    curl \
    unzip \
    libcurl4 \
    libssl3

WORKDIR /app

COPY . .

RUN chmod +x start.sh

EXPOSE 19132/udp

CMD ["./start.sh"]
