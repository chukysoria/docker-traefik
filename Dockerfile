# syntax=docker/dockerfile:1@sha256:4c68376a702446fc3c79af22de146a148bc3367e73c25a5803d453b6b3f722fb

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.7.11-3.21@sha256:50e0188b7ee5c3596fd200a60e3234c0f82ca286ab6e68feba6aabf075ca6ecb
FROM ${BUILD_FROM} 

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_EXT_RELEASE="v3.3.4"
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
