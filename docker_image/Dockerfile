FROM mcr.microsoft.com/oss/go/microsoft/golang:1.26.4 AS builder
WORKDIR /src
COPY . /src

RUN go mod tidy && go build -o /telemetry ./telemetry

FROM mcr.microsoft.com/azurelinux/base/core:3.0
COPY --from=builder /telemetry /

RUN tdnf update -y libarchive nghttp2 && \
    tdnf install -y ca-certificates && \
    update-ca-trust force-enable && \
    tdnf clean all

ENTRYPOINT ["/telemetry"]