# syntax=docker/dockerfile:1@sha256:4edf897a3ffa55b89f906fc8cc78afdb3f1834cc9c7083565e611a8a7d5fe99e

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v2.0.8-3.24@sha256:420476ff9783bad94c6c6cc88fb2bbe9227176f1ead8536e2fcc6d2f1c905759
FROM ${BUILD_FROM} 

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_EXT_RELEASE="v3.7.17"
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
