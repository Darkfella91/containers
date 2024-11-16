FROM docker.io/library/python:3.11-alpine

ARG TARGETPLATFORM
ARG VERSION
ARG CHANNEL

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

ENV UMASK="0002" \
    TZ="Etc/UTC"

ENV BAZARR__PORT=6767

USER root
WORKDIR /app

#hadolint ignore=DL3018,DL3013
RUN \
    apk add --no-cache \
        bash \
        ca-certificates \
        catatonit \
        coreutils \
        curl \
        ffmpeg \
        jo \
        jq \
        libxml2 \
        libxslt \
        mediainfo \
        nano \
        trurl \
        tzdata \
        unzip \
        libpq \
    && \
    apk add --no-cache --virtual .build-deps \
        build-base \
        cargo \
        libffi-dev \
        libpq-dev \
        libxml2-dev \
        libxslt-dev \
    && \
    chmod +x /usr/bin/catatonit \
    && \
    curl -fsSL -o /tmp/app.zip "https://github.com/morpheus65535/bazarr/releases/download/v${VERSION}/bazarr.zip" \
    && unzip -q /tmp/app.zip -d /app/bin \
    && \
    rm -rf /app/bin/bin \
    && \
    printf "UpdateMethod=docker\nBranch=master\nPackageVersion=%s\nPackageAuthor=[onedr0p](https://github.com/onedr0p)\n" "${VERSION}" > /app/package_info \
    && pip install --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ \
        --requirement /app/bin/requirements.txt \
        --requirement /app/bin/postgres-requirements.txt \
    && chown -R root:root /app && chmod -R 755 /app \
    && apk del --purge .build-deps \
    && rm -rf /root/.cache /root/.cargo /tmp/*

# Ensure the entrypoint script is executable and belongs to nobody:nogroup
COPY ./apps/bazarr/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown nobody:nogroup /entrypoint.sh

# Copy unrar-alpine binary from another image
COPY --from=ghcr.io/linuxserver/unrar:latest /usr/bin/unrar-alpine /usr/bin/unrar

# Ensure that catatonit and the app have the correct permissions
RUN chown nobody:nogroup /usr/bin/catatonit && chmod 755 /usr/bin/catatonit

# Switch to a non-root user
USER nobody:nogroup
WORKDIR /config
VOLUME ["/config"]

# Run the entrypoint with catatonit
ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]

LABEL org.opencontainers.image.source="https://github.com/morpheus65535/bazarr"
