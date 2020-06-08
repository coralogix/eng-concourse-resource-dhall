FROM alpine:3.12

LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.name="eng-concourse-resource-dhall" \
      org.label-schema.description="A Concourse resource for fetching remote Dhall expressions." \
      org.label-schema.vcs-url="https://github.com/coralogix/eng-concourse-resource-dhall" \
      org.label-schema.vendor="Coralogix, Inc." \
      org.label-schema.version="v1.32.0"

ENV DHALL_VERSION=1.32.0

RUN set -euo pipefail; \
  apk --no-cache add \
    bash \
    bzip2 \
    curl \
    jq && \
  mkdir -p /tmp && \
  curl -L --output /tmp/dhall.tar.bz2 \
    https://github.com/dhall-lang/dhall-haskell/releases/download/$DHALL_VERSION/dhall-$DHALL_VERSION-x86_64-linux.tar.bz2 && \
  tar -xjvf /tmp/dhall.tar.bz2 -C /usr/local && \
  rm -f /tmp/dhall.tar.bz2 && \
  /usr/local/bin/dhall version && \
  apk --no-cache del \
    bzip2 \
    curl

WORKDIR /opt/resource

COPY ./check ./in ./out /opt/resource/
