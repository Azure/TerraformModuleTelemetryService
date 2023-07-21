FROM golang:1.20.6-alpine3.18 as builder
WORKDIR /src
COPY . /src

RUN go mod tidy && CGO_ENABLED=0 go build -o /telemetry ./telemetry

FROM scratch
COPY --from=builder /telemetry /

ENTRYPOINT ["/telemetry"]