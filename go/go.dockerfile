# syntax=docker/dockerfile:1
FROM debian:trixie-slim AS build

ARG GO_VERSION
ARG TARGETARCH

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

# Unpack the official release under /out, then check the binary reports the
# version this kit claims to provide. A wrong pin fails the build.
RUN set -eux; \
    mkdir -p /out/usr/local; \
    curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-${TARGETARCH}.tar.gz" \
      | tar -xz -C /out/usr/local; \
    /out/usr/local/go/bin/go version | grep -q "go${GO_VERSION} "; \
    chown -R 0:0 /out

# The workload sets GOPATH=/go but doesn't create it. Ship it empty and
# agent-owned so module downloads and `go install` work without root.
RUN mkdir -p /out/go/bin /out/go/pkg/mod \
 && chown -R 1000:1000 /out/go

# The mixin's layer: /usr/local/go, an empty /go, and nothing else.
FROM scratch
COPY --from=build /out/ /
ENV PATH="/usr/local/go/bin:${PATH}"
