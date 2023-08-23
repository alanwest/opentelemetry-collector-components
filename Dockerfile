FROM golang:1.20 as builder

WORKDIR /build

COPY go.mod go.sum ./
COPY receiver/nopreceiver ./receiver/nopreceiver
RUN go mod download -x

COPY . ./

WORKDIR /build/cmd/nrotelcomponents

RUN CGO_ENABLED=0 GOOS=linux go build -v -a .

WORKDIR /dist
RUN cp /build/cmd/nrotelcomponents/nrotelcomponents ./nrotelcomponents
COPY otel-collector-config.yaml ./

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /dist /

ENTRYPOINT ["/nrotelcomponents"]
CMD ["--config", "/otel-collector-config.yaml"]
EXPOSE 4317
