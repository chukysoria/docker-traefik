# syntax=docker/dockerfile:1@sha256:b6afd42430b15f2d2a4c5a02b919e98a525b785b1aaff16747d2f623364e39b6

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.8.14-3.22@sha256:6b5d6929895ea3d150181fcf450b4ad2778323143ae91ccbe188ce597a823f54
FROM ${BUILD_FROM} 

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_EXT_RELEASE="v3.6.2"
LABEL build_version="Chukyserver.io version:- ${BUILD_VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="chukysoria"

# environment settings
ARG TARGETOS
ARG TARGETARCH
ARG TARGETVARIANT

RUN \
  echo "**** install treafik ****" && \
  mkdir -p /app/traefik/bin && \
  mkdir -p /certs && \
  curl -o \
    /tmp/traefik.tar.gz -L \
    "https://github.com/traefik/traefik/releases/download/${BUILD_EXT_RELEASE}/traefik_${BUILD_EXT_RELEASE}_${TARGETOS}_${TARGETARCH}${TARGETVARIANT}.tar.gz" && \
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

HEALTHCHECK --interval=30s --timeout=30s --start-period=2m --start-interval=5s --retries=5 CMD ["/etc/s6-overlay/s6-rc.d/svc-traefik/data/check"]
