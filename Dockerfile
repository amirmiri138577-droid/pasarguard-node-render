# Pin the upstream PasarGuard Node image for reproducible deployments.
ARG PASARGUARD_NODE_IMAGE=pasarguard/node:v0.5.4
FROM ${PASARGUARD_NODE_IMAGE}

USER root
ARG RATHOLE_VERSION=v0.5.0
ARG RATHOLE_ARCH=x86_64-unknown-linux-gnu

# The official Rathole release avoids a source clone during Render builds.
# gcompat lets the x86_64 GNU release run on the Alpine-based node image.
RUN apk add --no-cache openssl ca-certificates curl unzip gcompat \
    && curl -fsSL -o /tmp/rathole.zip \
       "https://github.com/rathole-org/rathole/releases/download/${RATHOLE_VERSION}/rathole-${RATHOLE_ARCH}.zip" \
    && unzip -j /tmp/rathole.zip rathole -d /usr/local/bin \
    && chmod 0755 /usr/local/bin/rathole \
    && rm -f /tmp/rathole.zip

COPY entrypoint.sh /entrypoint.sh
RUN chmod 0755 /entrypoint.sh /usr/local/bin/rathole

ENV NODE_HOST=0.0.0.0 \
    SSL_CERT_FILE=/var/lib/pg-node/certs/ssl_cert.pem \
    SSL_KEY_FILE=/var/lib/pg-node/certs/ssl_key.pem \
    GENERATED_CONFIG_PATH=/var/lib/pg-node/generated \
    SERVICE_PROTOCOL=grpc

ENTRYPOINT ["/entrypoint.sh"]
