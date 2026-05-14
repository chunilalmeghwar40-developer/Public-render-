FROM alpine:latest

# Install sab kuch
RUN apk add --no-cache curl ca-certificates lighttpd bash

# Download playit
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Create HTML page properly
RUN mkdir -p /var/www/localhost/htdocs && \
    cat > /var/www/localhost/htdocs/index.html << 'EOF'
<!DOCTYPE html>
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
        }
        .link a {
            color: #3b82f6;
            text-decoration: none;
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
        .loading {
            color: #666;
        }
    </style>
</head>
<body>
    <div class="box">
        <h1>🚀 Playit Tunnel</h1>
        <p class="status">✅ Active</p>
        <div class="link" id="tunnelLink" class="loading">Loading tunnel link...</div>
        <button onclick="copyLink()">📋 Copy Link</button>
        <p style="font-size:12px; margin-top:20px;">Auto-refreshes every 5 seconds</p>
    </div>
    <script>
        function copyLink() {
            const linkEl = document.getElementById("tunnelLink");
            const link = linkEl.innerText || linkEl.textContent;
            if(link && link !== "Loading tunnel link..." && link !== "Waiting for tunnel...") {
                navigator.clipboard.writeText(link);
                alert("Link copied!");
            } else {
                alert("No link yet. Please wait...");
            }
        }
        
        async function fetchLink() {
            try {
                const res = await fetch("/api/link");
                const data = await res.json();
                if(data.link && data.link !== "waiting...") {
                    document.getElementById("tunnelLink").innerHTML = '<a href="'+data.link+'" target="_blank">'+data.link+'</a>';
                }
            } catch(e) {
                // Keep waiting
            }
        }
        fetchLink();
        setInterval(fetchLink, 5000);
    </script>
</body>
</html>
EOF

# Lighttpd config - FIXED
RUN cat > /etc/lighttpd/lighttpd.conf << 'EOF'
server.document-root = "/var/www/localhost/htdocs"
server.port = 80
server.bind = "0.0.0.0"
server.modules = ("mod_cgi")
index-file.names = ("index.html")
mimetype.assign = (
    ".html" => "text/html",
    ".css" => "text/css",
    ".js" => "application/javascript"
)
cgi.assign = (
    "/api/link" => "/bin/sh"
)
EOF

# Create API endpoint
RUN mkdir -p /var/www/localhost/htdocs/api && \
    cat > /var/www/localhost/htdocs/api/link << 'EOF'
#!/bin/sh
echo "Content-Type: application/json"
echo ""
if [ -f /tmp/playit_link.txt ]; then
    LINK=$(cat /tmp/playit_link.txt)
    echo "{\"link\":\"$LINK\"}"
else
    echo "{\"link\":\"waiting...\"}"
fi
EOF
    chmod +x /var/www/localhost/htdocs/api/link

# Create master startup script
RUN cat > /master.sh << 'EOF'
#!/bin/bash

# Start web server
echo "Starting web server on port 80..."
lighttpd -D -f /etc/lighttpd/lighttpd.conf &
sleep 2

# Start playit and capture link
echo "Starting playit tunnel..."
/usr/local/bin/playit 2>&1 | while IFS= read -r line; do
    echo "$line"
    # Extract playit URL
    if [[ "$line" =~ (https://playit\.gg/[a-zA-Z0-9/]+) ]]; then
        LINK="${BASH_REMATCH[1]}"
        echo "$LINK" > /tmp/playit_link.txt
        echo "✅ Tunnel link saved: $LINK"
    fi
done
EOF
    chmod +x /master.sh

RUN mkdir -p /root/.config/playit

EXPOSE 80

CMD ["/master.sh"]
