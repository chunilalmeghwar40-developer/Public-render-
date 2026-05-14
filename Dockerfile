FROM alpine:latest

# Install dependencies
RUN apk add --no-cache curl ca-certificates lighttpd bash

# Download playit
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Setup dummy web server
RUN mkdir -p /var/www/localhost/htdocs && \
    echo "Playit Tunnel Active" > /var/www/localhost/htdocs/index.html

# Configure lighttpd
RUN echo 'server.document-root = "/var/www/localhost/htdocs"' > /etc/lighttpd/lighttpd.conf && \
    echo 'server.port = 80' >> /etc/lighttpd/lighttpd.conf && \
    echo 'server.bind = "0.0.0.0"' >> /etc/lighttpd/lighttpd.conf

# Create playit config directory
RUN mkdir -p /root/.config/playit

EXPOSE 80

# Simple CMD - directly run both
CMD sh -c "lighttpd -D -f /etc/lighttpd/lighttpd.conf & sleep 2 && /usr/local/bin/playit"
