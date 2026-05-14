FROM alpine:latest
RUN apk add --no-cache curl bash
# Install sshx
RUN curl -sSf https://sshx.io/get | sh
# Keep container running and start sshx (using a dummy command for example)
CMD ["shx", "run"]
