FROM golang:1.25.8 AS builder
WORKDIR /src
COPY . /src

RUN go mod tidy && CGO_ENABLED=0 go build -o /telemetry ./telemetry

FROM mcr.microsoft.com/azurelinux/base/core:3.0
COPY --from=builder /telemetry /

RUN tdnf update -y libarchive && \
    tdnf install -y ca-certificates && \
    update-ca-trust force-enable && \
    tdnf clean all

ENTRYPOINT ["/telemetry"]