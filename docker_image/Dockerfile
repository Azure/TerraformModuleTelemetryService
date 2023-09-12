FROM golang:1.20.6-alpine3.18 as builder
WORKDIR /src
COPY . /src

RUN go mod tidy && CGO_ENABLED=0 go build -o /telemetry ./telemetry

FROM mcr.microsoft.com/cbl-mariner/base/core:1.0
COPY --from=builder /telemetry /

RUN yum install -y ca-certificates && \
    update-ca-trust force-enable

ENTRYPOINT ["/telemetry"]