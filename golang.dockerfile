FROM golang:1.23.5-alpine AS builder

# позволяет сохранять кэш сборки внутри самого образа, чтобы он мог 
# использоваться как источник кэша в будущем при сборке других образов
ARG BUILDKIT_INLINE_CACHE=0

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download


COPY cmd cmd
COPY pkg pkg
COPY internal internal
# COPY other code files

# Кэширования для ускорения повторных сборок --mount=type=cache,target=/gocache GOCACHE=/gocache
RUN --mount=type=cache,target=/gocache GOCACHE=/gocache \ 
# указание архитектуры приложения
GOOS=linux GOARCH=amd64 \
# убираем всю отладочную информацию используя -ldflags="-w -s"
go build -ldflags="-w -s" -o main ./cmd/main/

# bash:4.4.23 - 17МБ; alpine:3.18 - 11.5МБ
FROM bash:4.4.23

COPY --from=builder /app/main /main

EXPOSE 80
CMD ["./main"]
