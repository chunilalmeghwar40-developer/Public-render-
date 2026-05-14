FROM alpine:latest

# Install playit dependencies and lighttpd web server
RUN apk add --no-cache curl ca-certificates lighttpd

# Download playit binary
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Create blank HTML page
RUN echo "<html><body><h1>Playit Tunnel Active</h1><p>This is a dummy web page</p></body></html>" > /var/www/localhost/htdocs/index.html

# Create config directory for playit
RUN mkdir -p /root/.config/playit

# Expose web port (playit iske through tunnel banayega)
EXPOSE 80

# Create startup script
RUN echo '#!/bin/sh' > /start.sh && \
    echo '# Start web server in background' >> /start.sh && \
    echo 'lighttpd -D -f /etc/lighttpd/lighttpd.conf &' >> /start.sh && \
    echo '# Wait a moment for web server to start' >> /start.sh && \
    echo 'sleep 2' >> /start.sh && \
    echo '# Start playit (it will find port 80)' >> /start.sh && \
    echo 'echo "Playit tunnel starting... Web server running on port 80"' >> /start.sh && \
    echo 'exec /usr/local/bin/playit' >> /start.sh && \
    chmod +x /start.sh

# Run startup script
CMD ["/start.sh"]
