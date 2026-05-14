FROM alpine:latest

# Install sab kuch
RUN apk add --no-cache curl ca-certificates lighttpd bash jq

# Download playit
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Web server setup
RUN mkdir -p /var/www/localhost/htdocs

# Create dynamic HTML page jo playit link dikhaye
RUN echo '<!DOCTYPE html>
<html>
<head>
    <title>Playit Tunnel</title>
    <style>
        body {
            font-family: monospace;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            margin: 0;
        }
        .box {
            background: white;
            padding: 40px;
            border-radius: 20px;
            text-align: center;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
        }
        .link {
            background: #f0f0f0;
            padding: 15px;
            border-radius: 10px;
            margin: 20px 0;
            word-break: break-all;
            color: #3b82f6;
            font-size: 14px;
        }
        button {
            background: #3b82f6;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 5px;
            cursor: pointer;
        }
        .status {
            color: #10b981;
            font-weight: bold;
        }
    </style>
</head>
<body>
    <div class="box">
        <h1>🚀 Playit Tunnel</h1>
        <p class="status">✅ Active</p>
        <div class="link" id="tunnelLink">Loading tunnel link...</div>
        <button onclick="copyLink()">📋 Copy Link</button>
        <p style="font-size:12px; margin-top:20px;">Refresh page to update</p>
    </div>
    <script>
        function copyLink() {
            const link = document.getElementById("tunnelLink").innerText;
            navigator.clipboard.writeText(link);
            alert("Link copied!");
        }
        async function fetchLink() {
            try {
                const res = await fetch("/api/link");
                const data = await res.json();
                if(data.link) {
                    document.getElementById("tunnelLink").innerHTML = \'<a href="\'+data.link+\'" target="_blank">\'+data.link+\'</a>\';
                }
            } catch(e) {
                document.getElementById("tunnelLink").innerText = "Waiting for tunnel...";
            }
        }
        fetchLink();
        setInterval(fetchLink, 5000);
    </script>
</body>
</html>' > /var/www/localhost/htdocs/index.html

# Lighttpd config
RUN echo 'server.document-root = "/var/www/localhost/htdocs"' > /etc/lighttpd/lighttpd.conf && \
    echo 'server.port = 80' >> /etc/lighttpd/lighttpd.conf && \
    echo 'server.bind = "0.0.0.0"' >> /etc/lighttpd/lighttpd.conf && \
    echo 'server.modules += ("mod_cgi")' >> /etc/lighttpd/lighttpd.conf && \
    echo 'cgi.assign = (".sh" => "/bin/sh")' >> /etc/lighttpd/lighttpd.conf

# Create API endpoint jo playit link return kare
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

# Create master script
RUN echo '#!/bin/bash' > /master.sh && \
    echo '' >> /master.sh && \
    echo '# Start web server' >> /master.sh && \
    echo 'lighttpd -D -f /etc/lighttpd/lighttpd.conf &' >> /master.sh && \
    echo 'sleep 2' >> /master.sh && \
    echo '' >> /master.sh && \
    echo '# Start playit and capture link' >> /master.sh && \
    echo 'echo "Starting playit..."' >> /master.sh && \
    echo '/usr/local/bin/playit 2>&1 | while IFS= read -r line; do' >> /master.sh && \
    echo '    echo "$line"' >> /master.sh && \
    echo '    if [[ "$line" =~ https://playit\.gg/[a-zA-Z0-9]+ ]]; then' >> /master.sh && \
    echo '        LINK="${BASH_REMATCH[0]}"' >> /master.sh && \
    echo '        echo "$LINK" > /tmp/playit_link.txt' >> /master.sh && \
    echo '        echo "✅ Tunnel link saved: $LINK"' >> /master.sh && \
    echo '    fi' >> /master.sh && \
    echo 'done' >> /master.sh && \
    chmod +x /master.sh

RUN mkdir -p /root/.config/playit

EXPOSE 80

CMD ["/master.sh"]
