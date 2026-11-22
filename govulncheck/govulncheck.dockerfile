# syntax=docker/dockerfile:1
FROM golang:trixie AS build

ARG GOVULNCHECK_VERSION

RUN set -eux; \
    mkdir -p /out/usr/local/bin; \
    GOBIN=/out/usr/local/bin go install golang.org/x/vuln/cmd/govulncheck@v${GOVULNCHECK_VERSION}; \
    /out/usr/local/bin/govulncheck --version | grep -q "govulncheck@v${GOVULNCHECK_VERSION}"; \
    chown -R 0:0 /out

FROM scratch
COPY --from=build /out/ /
