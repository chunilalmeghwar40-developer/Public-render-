FROM alpine:latest

RUN apk add --no-cache curl python3

# Download playit
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Create simple web server with python
RUN mkdir -p /www && \
    echo '<!DOCTYPE html><html><head><title>Playit</title></head><body><h1>Playit Tunnel Active</h1><div id="link">Loading...</div><script>setInterval(async()=>{let r=await fetch("/link.txt");let t=await r.text();if(t!="waiting")document.getElementById("link").innerHTML="<a href="+t+">"+t+"</a>";},3000);</script></body></html>' > /www/index.html && \
    echo "waiting" > /www/link.txt

RUN mkdir -p /root/.config/playit

EXPOSE 80

CMD sh -c "python3 -m http.server -d /www 80 & sleep 3 && /usr/local/bin/playit 2>&1 | while read line; do echo \$line; if [[ \$line =~ https://playit\.gg/[a-zA-Z0-9/]+ ]]; then echo \${BASH_REMATCH[0]} > /www/link.txt; fi; done"
