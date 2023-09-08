# syntax=docker/dockerfile:1

FROM ghcr.io/chukysoria/baseimage-alpine:3.18

# set version label
ARG BUILD_DATE
ARG VERSION
ARG TRAEFIK_VERSION
LABEL build_version="Chukyserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"

# environment settings
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT
ARG TRAEFIK_BRANCH="master"

RUN \
  echo "**** install treafik ****" && \
  mkdir -p /app/traefik/bin && \
  mkdir -p /certs && \
  if [ -z ${TRAEFIK_VERSION+x} ]; then \
    TRAEFIK_VERSION=$(curl -sX GET "https://api.github.com/repos/traefik/traefik/releases/latest" \
    | awk '/tag_name/{print $4;exit}' FS='[""]'); \
  fi && \
  curl -o \
    /tmp/traefik.tar.gz -L \
    "https://github.com/traefik/traefik/releases/download/${TRAEFIK_VERSION}/traefik_${TRAEFIK_VERSION}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz" && \
  tar xzf \
    /tmp/traefik.tar.gz -C \
    /app/traefik/bin && \
  echo "**** cleanup ****" && \
  rm -rf \
    /tmp/* \
    /var/tmp/*

# copy local files
COPY root/ /

# ports and volumes
EXPOSE 80
EXPOSE 443
EXPOSE 8080

VOLUME /config
VOLUME /certs
