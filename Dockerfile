ARG ALPINE_VER=3.17

#--------------#

FROM ghcr.io/linuxserver/baseimage-alpine:${ALPINE_VER} AS base

#--------------#

FROM golang:1.19-alpine${ALPINE_VER} AS wireproxy-builder

RUN go install github.com/octeep/wireproxy/cmd/wireproxy@latest

#--------------#

FROM base AS wgcf-builder

RUN curl -fsSL https://git.io/wgcf.sh | bash

#--------------#

FROM base AS collector

COPY --from=wireproxy-builder /go/bin/wireproxy /bar/usr/local/bin/wireproxy
COPY --from=wgcf-builder /usr/local/bin/wgcf /bar/usr/local/bin/wgcf

COPY root/ /bar/

RUN chmod a+x \
        /bar/usr/local/bin/* \
        /bar/etc/s6-overlay/s6-rc.d/*/run \
        /bar/etc/s6-overlay/s6-rc.d/*/finish \
        /bar/etc/s6-overlay/s6-rc.d/*/data/*

#--------------#

FROM base As publisher

LABEL maintainer="hua-ying"
LABEL org.opencontainers.image.source https://github.com/hua-ying/warproxy

COPY --from=collector /bar/ /

RUN apk add --no-cache grep sed python3

RUN \
    if [ ! -e /usr/bin/python ]; then ln -sf /usr/bin/python3 /usr/bin/python; fi && \
    python3 -m ensurepip && \
    rm -r /usr/lib/python*/ensurepip && \
    if [ ! -e /usr/bin/pip ]; then ln -s pip3 /usr/bin/pip; fi

RUN pip3 install --no-cache --upgrade pip requests toml

RUN \
    rm -rf \
        /tmp/* \
        /root/.cache

ENV \
    S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    PYTHONUNBUFFERED=1 \
    TZ=Asia/Shanghai \
    WARP_ENABLED=true \
    PROXY_PORT=1080

EXPOSE ${PROXY_PORT}
VOLUME /config
WORKDIR /config

HEALTHCHECK --interval=5m --timeout=30s --start-period=2m --retries=3 \
    CMD /usr/local/bin/healthcheck

ENTRYPOINT ["/init"]
