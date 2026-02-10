FROM golang:1.25.7 as builder
WORKDIR /src
COPY . /src

RUN go mod tidy && CGO_ENABLED=0 go build -o /telemetry ./telemetry

FROM mcr.microsoft.com/azurelinux/base/core:3.0
COPY --from=builder /telemetry /

RUN tdnf install -y ca-certificates && \
    update-ca-trust force-enable

ENTRYPOINT ["/telemetry"]