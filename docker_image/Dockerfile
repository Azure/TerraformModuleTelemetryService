FROM mcr.microsoft.com/devcontainers/go:1.22-bullseye as builder
WORKDIR /src
COPY . /src

RUN go mod tidy && CGO_ENABLED=0 go build -o /telemetry ./telemetry

FROM mcr.microsoft.com/cbl-mariner/base/core:2.0
COPY --from=builder /telemetry /

RUN yum install -y ca-certificates && \
    update-ca-trust force-enable

ENTRYPOINT ["/telemetry"]