#!/bin/bash

# packages folder
mkdir -p /app/server

cd /app/server

# download latest bedrock server
curl -L https://minecraft.azureedge.net/bin-linux/bedrock-server-1.21.100.7.zip -o bedrock.zip

# unzip
unzip -o bedrock.zip

chmod +x bedrock_server

# start server
LD_LIBRARY_PATH=. ./bedrock_server &

cd /app

# download playit
curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o playit

chmod +x playit

# start playit
./playit

wait
