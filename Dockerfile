# Build the tunnel client as a static Linux binary.
FROM rust:1.89-alpine AS rathole-build
ARG RATHOLE_VERSION=v0.5.0
RUN apk add --no-cache musl-dev build-base git \
    && git clone --depth 1 --branch ${RATHOLE_VERSION} https://github.com/rathole-org/rathole.git /src/rathole \
    && cd /src/rathole \
    && cargo build --release --locked \
    && install -m 0755 target/release/rathole /rathole

# Pin the upstream PasarGuard Node image for reproducible deployments.
ARG PASARGUARD_NODE_IMAGE=pasarguard/node:v0.5.4
FROM ${PASARGUARD_NODE_IMAGE}

USER root
RUN apk add --no-cache openssl

COPY --from=rathole-build /rathole /usr/local/bin/rathole
COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh /usr/local/bin/rathole

ENV NODE_HOST=0.0.0.0 \
    SSL_CERT_FILE=/var/lib/pg-node/certs/ssl_cert.pem \
    SSL_KEY_FILE=/var/lib/pg-node/certs/ssl_key.pem \
    GENERATED_CONFIG_PATH=/var/lib/pg-node/generated \
    SERVICE_PROTOCOL=grpc

ENTRYPOINT ["/entrypoint.sh"]
