FROM alpine:latest

# Install curl and ca-certificates only
RUN apk add --no-cache curl ca-certificates

# Download playit binary directly for Linux (x86_64)
RUN curl -L https://github.com/playit-cloud/playit-agent/releases/download/v0.15.26/playit-linux-amd64 -o /usr/local/bin/playit && \
    chmod +x /usr/local/bin/playit

# Create config directory
RUN mkdir -p /root/.config/playit

# Run playit
CMD ["/usr/local/bin/playit"]
