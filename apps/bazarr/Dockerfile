# Use the official Alpine Linux base image
FROM alpine:3.20.3@sha256:1e42bbe2508154c9126d48c2b8a75420c3544343bf86fd041fb7527e017a4b4a

# Set build arguments
ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

# Set environment variables
ENV PIP_NO_CACHE_DIR=1 \
    LANG=C.UTF-8 \
    BAZARR__PORT=6767 \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

WORKDIR /app

# Install system dependencies (runtime + build)
RUN echo "**** Installing build and runtime dependencies ****" && \
    apk add --no-cache \
    build-base \
    cargo \
    libffi-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev \
    ffmpeg \
    libxml2 \
    libxslt \
    bash \
    jo \
    jq \
    trurl \
    tzdata \
    unzip \
    mediainfo \
    python3 \
    curl \
    coreutils \
    ca-certificates \
    catatonit && \
    echo "**** Downloading and extracting Bazarr ****" && \
    curl -fsSL -o /tmp/bazarr.zip "https://github.com/morpheus65535/bazarr/releases/download/v${VERSION}/bazarr.zip" && \
    unzip -q /tmp/bazarr.zip -d /app/bin && \
    rm /tmp/bazarr.zip && \
    echo "**** Setting Bazarr package info ****" && \
    printf "UpdateMethod=docker\nBranch=master\nPackageVersion=%s\nPackageAuthor=[Darkfella](https://github.com/darkfella91)\n" "${VERSION}" > /app/package_info && \
    echo "**** Setting up Python virtual environment and installing dependencies ****" && \
    python3 -m venv /app/venv && \
    /app/venv/bin/pip install --upgrade --no-cache-dir pip wheel && \
    /app/venv/bin/pip install --upgrade --no-cache-dir certifi && \
    /app/venv/bin/pip install --upgrade --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ \
    -r /app/bin/requirements.txt \
    -r /app/bin/postgres-requirements.txt && \
    echo "Dynamically setting REQUESTS_CA_BUNDLE to: $REQUESTS_CA_BUNDLE" && \
    PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:3])))') && \
    export REQUESTS_CA_BUNDLE=/app/venv/lib/python$PYTHON_VERSION/site-packages/certifi/cacert.pem && \
    echo "**** Cleaning up build dependencies and unnecessary files ****" && \
    # Clean up unnecessary dependencies and temporary files
    apk del --purge build-base cargo libffi-dev libpq-dev libxml2-dev libxslt-dev python3-dev unzip && \
    rm -rf /root/.cache /root/.cargo /tmp/* && \
    echo "**** Setting proper ownership and permissions for /app ****" && \
    chown -R root:root /app && \
    chmod -R 755 /app

USER nobody:nogroup

WORKDIR /config
VOLUME ["/config"]

# Copy unrar binary from the unrar image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

# Entrypoint to use Catatonit for process management
ENTRYPOINT ["/usr/bin/catatonit", "--"]

# Command to run Bazarr
CMD ["/app/venv/bin/python3", "/app/bin/bazarr.py", "--no-update", "--config", "/config"]
