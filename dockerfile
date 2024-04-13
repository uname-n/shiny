FROM ghcr.io/gleam-lang/gleam:v1.0.0-erlang-alpine AS builder
RUN apk add --no-cache build-base
WORKDIR /build
COPY src/ src/
COPY gleam.toml .
RUN gleam export erlang-shipment

FROM ghcr.io/gleam-lang/gleam:v1.0.0-erlang-alpine
WORKDIR /app
RUN mkdir -p /config
COPY --from=builder /build/build/erlang-shipment .
RUN apk add --no-cache bash
ENTRYPOINT ["/app/entrypoint.sh"]
CMD ["run"]
