# syntax=docker/dockerfile:1@sha256:ecfaec9ed6d810b56388c508f4121597bfbba70d41a6dfeee4d8cad5f295fc32

ARG BUILD_FROM=ghcr.io/chukysoria/baseimage-alpine:v2.0.3-3.24@sha256:02d4fe6acb6a4bee8fbb24889bb5c038888a722372511965f642be72685c0d95
FROM ${BUILD_FROM} 

# set version label
ARG BUILD_DATE
ARG BUILD_VERSION
ARG BUILD_EXT_RELEASE="v3.7.13"
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
