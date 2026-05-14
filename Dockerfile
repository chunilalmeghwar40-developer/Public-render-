FROM alpine:latest

# Install required dependencies: curl, ca-certificates, and bash
RUN apk add --no-cache curl ca-certificates bash

# Download and install playit.gg
RUN curl -SsL https://playit-cloud.github.io/ppa/key.gpg | gpg --dearmor | tee /etc/apk/keys/playit.gpg >/dev/null && \
    echo "https://playit-cloud.github.io/ppa/data ./" >> /etc/apk/repositories && \
    apk update && \
    apk add --no-cache playit

# Create necessary directory for playit config
RUN mkdir -p /root/.config/playit

# Expose default ports (optional - depends on your service)
EXPOSE 25565 19132 8080

# Run playit.gg
CMD ["playit"]
