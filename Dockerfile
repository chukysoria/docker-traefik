# syntax=docker/dockerfile:1@sha256:9857836c9ee4268391bb5b09f9f157f3c91bb15821bb77969642813b0d00518d

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v0.8.6-3.22@sha256:1d415ee7f5b6b09b37ed324db7de383bdee2f2f46c55fc0736c8f7e35762ef9d
FROM ${BUILD_FROM} 

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_EXT_RELEASE="v3.5.0"
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
