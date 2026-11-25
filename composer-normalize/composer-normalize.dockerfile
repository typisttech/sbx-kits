# syntax=docker/dockerfile:1
FROM php:8-trixie AS build

ARG COMPOSER_NORMALIZE_VERSION

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*

RUN set -eux; \
    mkdir -p /out/usr/local/bin; \
    curl -fsSL "https://github.com/ergebnis/composer-normalize/releases/download/${COMPOSER_NORMALIZE_VERSION}/composer-normalize.phar" \
      -o /out/usr/local/bin/composer-normalize; \
    chmod 0755 /out/usr/local/bin/composer-normalize; \
    php /out/usr/local/bin/composer-normalize 2>/dev/null | grep -q "ergebnis/composer-normalize ${COMPOSER_NORMALIZE_VERSION}"

RUN chown -R 0:0 /out

FROM scratch
COPY --from=build /out /
