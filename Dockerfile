# Lightweight base image
FROM alpine:latest

# Install dependencies: curl (to download script) and libgcc (required for static binary)
RUN apk add --no-cache curl libgcc

# Install SSHX using the official script
RUN curl -sSf https://sshx.io/get | sh -s -- -y

# Ensure sshx is in PATH (script usually installs to /usr/local/bin)
ENV PATH="/root/.local/bin:${PATH}"

# Expose default ports (optional: 8080 for web, 8051 for gRPC)
EXPOSE 8080 8051

# Run SSHX when container starts
CMD ["sshx"]
