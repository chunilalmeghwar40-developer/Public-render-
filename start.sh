#!/bin/bash

# unzip server
unzip -o bedrock-server.zip -d server

cd server

chmod +x bedrock_server

# start bedrock server
LD_LIBRARY_PATH=. ./bedrock_server &

cd ..

# download playit
curl -L https://github.com/playit-cloud/playit-agent/releases/latest/download/playit-linux-amd64 -o playit

chmod +x playit

# start playit
./playit

wait
