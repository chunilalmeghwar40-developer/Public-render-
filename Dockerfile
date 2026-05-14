FROM alpine:latest

# Install sab kuch
RUN apk add --no-cache curl ca-certificates lighttpd bash

# Download playit
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Create HTML page
RUN mkdir -p /var/www/localhost/htdocs && \
    echo '<!DOCTYPE html>' > /var/www/localhost/htdocs/index.html && \
    echo '<html>' >> /var/www/localhost/htdocs/index.html && \
    echo '<head><title>Playit Tunnel</title>' >> /var/www/localhost/htdocs/index.html && \
    echo '<style>' >> /var/www/localhost/htdocs/index.html && \
    echo 'body{font-family:monospace;background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);display:flex;justify-content:center;align-items:center;height:100vh;margin:0}' >> /var/www/localhost/htdocs/index.html && \
    echo '.box{background:white;padding:40px;border-radius:20px;text-align:center}' >> /var/www/localhost/htdocs/index.html && \
    echo '.link{background:#f0f0f0;padding:15px;border-radius:10px;margin:20px 0;word-break:break-all;color:#3b82f6}' >> /var/www/localhost/htdocs/index.html && \
    echo 'button{background:#3b82f6;color:white;border:none;padding:10px 20px;border-radius:5px;cursor:pointer}' >> /var/www/localhost/htdocs/index.html && \
    echo '.status{color:#10b981;font-weight:bold}' >> /var/www/localhost/htdocs/index.html && \
    echo '</style></head>' >> /var/www/localhost/htdocs/index.html && \
    echo '<body><div class="box">' >> /var/www/localhost/htdocs/index.html && \
    echo '<h1>🚀 Playit Tunnel</h1>' >> /var/www/localhost/htdocs/index.html && \
    echo '<p class="status">✅ Active</p>' >> /var/www/localhost/htdocs/index.html && \
    echo '<div class="link" id="tunnelLink">Loading tunnel link...</div>' >> /var/www/localhost/htdocs/index.html && \
    echo '<button onclick="copyLink()">📋 Copy Link</button>' >> /var/www/localhost/htdocs/index.html && \
    echo '<p style="font-size:12px;margin-top:20px;">Refresh page to update</p>' >> /var/www/localhost/htdocs/index.html && \
    echo '</div><script>' >> /var/www/localhost/htdocs/index.html && \
    echo 'function copyLink(){' >> /var/www/localhost/htdocs/index.html && \
    echo 'const link=document.getElementById("tunnelLink").innerText;' >> /var/www/localhost/htdocs/index.html && \
    echo 'navigator.clipboard.writeText(link);' >> /var/www/localhost/htdocs/index.html && \
    echo 'alert("Link copied!");}' >> /var/www/localhost/htdocs/index.html && \
    echo 'async function fetchLink(){' >> /var/www/localhost/htdocs/index.html && \
    echo 'try{const res=await fetch("/api/link");' >> /var/www/localhost/htdocs/index.html && \
    echo 'const data=await res.json();' >> /var/www/localhost/htdocs/index.html && \
    echo 'if(data.link){document.getElementById("tunnelLink").innerHTML="<a href='+data.link+' target=_blank>"+data.link+"</a>";}}' >> /var/www/localhost/htdocs/index.html && \
    echo 'catch(e){document.getElementById("tunnelLink").innerText="Waiting for tunnel...";}}' >> /var/www/localhost/htdocs/index.html && \
    echo 'fetchLink();setInterval(fetchLink,5000);' >> /var/www/localhost/htdocs/index.html && \
    echo '</script></body></html>' >> /var/www/localhost/htdocs/index.html

# Lighttpd config
RUN echo 'server.document-root = "/var/www/localhost/htdocs"' > /etc/lighttpd/lighttpd.conf && \
    echo 'server.port = 80' >> /etc/lighttpd/lighttpd.conf && \
    echo 'server.bind = "0.0.0.0"' >> /etc/lighttpd/lighttpd.conf

# Create API endpoint
RUN mkdir -p /var/www/localhost/htdocs/api && \
    echo '#!/bin/sh' > /var/www/localhost/htdocs/api/link && \
    echo 'echo "Content-Type: application/json"' >> /var/www/localhost/htdocs/api/link && \
    echo 'echo ""' >> /var/www/localhost/htdocs/api/link && \
    echo 'if [ -f /tmp/playit_link.txt ]; then' >> /var/www/localhost/htdocs/api/link && \
    echo '    LINK=$(cat /tmp/playit_link.txt)' >> /var/www/localhost/htdocs/api/link && \
    echo '    echo "{\"link\":\"$LINK\"}"' >> /var/www/localhost/htdocs/api/link && \
    echo 'else' >> /var/www/localhost/htdocs/api/link && \
    echo '    echo "{\"link\":\"waiting...\"}"' >> /var/www/localhost/htdocs/api/link && \
    echo 'fi' >> /var/www/localhost/htdocs/api/link && \
    chmod +x /var/www/localhost/htdocs/api/link

# Master script
RUN echo '#!/bin/bash' > /master.sh && \
    echo 'lighttpd -D -f /etc/lighttpd/lighttpd.conf &' >> /master.sh && \
    echo 'sleep 2' >> /master.sh && \
    echo '/usr/local/bin/playit 2>&1 | while IFS= read -r line; do' >> /master.sh && \
    echo '    echo "$line"' >> /master.sh && \
    echo '    if [[ "$line" =~ https://playit\.gg/[a-zA-Z0-9]+ ]]; then' >> /master.sh && \
    echo '        echo "${BASH_REMATCH[0]}" > /tmp/playit_link.txt' >> /master.sh && \
    echo '    fi' >> /master.sh && \
    echo 'done' >> /master.sh && \
    chmod +x /master.sh

RUN mkdir -p /root/.config/playit

EXPOSE 80

CMD ["/master.sh"]
