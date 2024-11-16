# Use the official Alpine Linux base image
FROM alpine:3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a


ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# Set environment variables
ENV PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 \
    USERNAME=nobody \
    BAZARR__PORT=6767

WORKDIR /app
# Install system dependencies
RUN \
  echo "**** Install build dependencies ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    libffi-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev && \
  echo "**** Install runtime dependencies ****" && \
  apk add --no-cache \
    ffmpeg \
    libxml2 \
    libxslt \
    mediainfo \
    python3 \
    curl \
    catatonit && \
  echo "**** Create Bazarr directory and user ****" && \
  mkdir -p /app/bazarr && \
  echo "**** Download Bazarr ****" && \
  curl -fsSL -o /tmp/bazarr.zip \
    "https://github.com/morpheus65535/bazarr/releases/latest/download/v${VERSION}/bazarr.zip" && \
  unzip /tmp/bazarr.zip -d /app/bazarr && \
  rm -rf /tmp/bazarr.zip && \
  echo "**** Set up virtual environment and install Python dependencies ****" && \
  python3 -m venv /app/bazarr/venv && \
  . /app/bazarr/venv/bin/activate && \
  pip install --upgrade pip wheel && \
  pip install --no-cache-dir \
    -r /app/bazarr/requirements.txt \
    -r /app/bazarr/postgres-requirements.txt && \
  deactivate && \
  echo "**** Clean up ****" && \
  apk del --purge build-dependencies && \
  rm -rf /var/cache/apk/*

USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

# Expose Bazarr's default port
EXPOSE 6767

COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

# Entrypoint to use Catatonit for process management
ENTRYPOINT ["/usr/bin/catatonit", "--"]
# Command to run Bazarr
CMD ["/app/bazarr/venv/bin/python3", "/app/bazarr/bazarr.py", "--no-update", "--config", "/config"]
