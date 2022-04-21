FROM --platform=${BUILDPLATFORM} golang:1.18-alpine AS base
ENV CGO_ENABLED=0
WORKDIR /go/src/app
COPY go.* .
RUN --mount=type=cache,target=/go/pkg/mod \
    go mod download


FROM base AS build
ARG TARGETOS        # This variable is automatically set by the docker build platform flag
ARG TARGETARCH      # This variable is automatically set by the docker build platform flag
ARG output_bin
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -o /out/${output_bin} .


FROM base AS unit-test
RUN --mount=target=. \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    mkdir /out && go test -v -coverprofile=/out/cover.out .


FROM golangci/golangci-lint:v1.45-alpine AS lint-base

FROM base AS lint
RUN --mount=target=. \
    --mount=from=lint-base,src=/usr/bin/golangci-lint,target=/usr/bin/golangci-lint \
    --mount=type=cache,target=/go/pkg/mod \
    --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/root/.cache/golangci-lint \
    golangci-lint run --timeout 10m0s .


FROM scratch as binary-unix
ARG output_bin
COPY --from=build /out/${output_bin} /

FROM binary-unix AS binary-linux
FROM binary-unix AS binary-darwin

FROM scratch as binary-windows
ARG output_bin
COPY --from=build /out/${output_bin} /${output_bin}.exe

FROM binary-${TARGETOS} as binary