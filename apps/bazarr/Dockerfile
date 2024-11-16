FROM ghcr.io/linuxserver/unrar:latest AS unrar

FROM ghcr.io/linuxserver/baseimage-alpine:3.20

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BAZARR_VERSION
LABEL build_version="DarkfellaNET version:- 1.4.5 Build-date:- 2024"
LABEL maintainer="Darkfella"
LABEL org.opencontainers.image.source="https://github.com/morpheus65535/bazarr"
# hard set UTC in case the user does not define it

ENV TZ="Etc/UTC"
ENV BAZARR__PORT=6767
ENV UMASK="0002"

ENV \
    PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_ROOT_USER_ACTION=ignore \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_BREAK_SYSTEM_PACKAGES=1 \
    CRYPTOGRAPHY_DONT_BUILD_RUST=1

RUN \
  echo "**** install build packages ****" && \
  apk add --no-cache --virtual=build-dependencies \
    build-base \
    cargo \
    libffi-dev \
    libpq-dev \
    libxml2-dev \
    libxslt-dev \
    python3-dev \
    py3-pip && \
  echo "**** install packages ****" && \
  apk add --no-cache \
    ffmpeg \
    libxml2 \
    libxslt \
    mediainfo \
    python3 && \
  echo "**** install bazarr ****" && \
  mkdir -p \
    /app/bazarr/bin && \
  curl -o \
    /tmp/bazarr.zip -L \
    "https://github.com/morpheus65535/bazarr/releases/download/v1.4.5/bazarr.zip" && \
  unzip \
    /tmp/bazarr.zip -d \
    /app/bazarr/bin && \
  rm -Rf /app/bazarr/bin/bin && \
  echo "UpdateMethod=docker\nBranch=master\nPackageVersion=v1.4.5\nPackageAuthor=linuxserver.io" > /app/bazarr/package_info && \
  curl -o \
    /app/bazarr/bin/postgres-requirements.txt -L \
    "https://raw.githubusercontent.com/morpheus65535/bazarr/v1.4.5/postgres-requirements.txt" && \
  echo "**** Install requirements ****" && \
  pip install -U --no-cache-dir \
    pip \
    wheel && \
  pip install -U --no-cache-dir --find-links https://wheel-index.linuxserver.io/alpine-3.20/ \
    -r /app/bazarr/bin/requirements.txt \
    -r /app/bazarr/bin/postgres-requirements.txt && \
  printf "Linuxserver.io version: v1.4.5\nBuild-date: 2024" > /build_version && \
  echo "**** clean up ****" && \
  apk del --purge \
    build-dependencies && \
  rm -rf \
    $HOME/.cache \
    $HOME/.cargo \
    /tmp/*


COPY ./apps/bazarr/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown nobody:nogroup /entrypoint.sh

RUN chown nobody:nogroup /usr/bin/catatonit && chmod 755 /usr/bin/catatonit

COPY --from=unrar /usr/bin/unrar-alpine /usr/bin/unrar

USER nobody:nogroup
VOLUME /config

ENTRYPOINT ["/usr/bin/catatonit", "--", "/entrypoint.sh"]
