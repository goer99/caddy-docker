FROM alpine:edge AS builder
RUN apk upgrade&&apk add go git
WORKDIR /data
RUN git clone https://github.com/caddyserver/xcaddy.git --depth 1 
WORKDIR /data/xcaddy/cmd/xcaddy
RUN go run main.go build latest \
--with github.com/caddy-dns/cloudflare \
--with github.com/caddy-dns/namesilo \
--with github.com/caddy-dns/alidns \

RUN /data/xcaddy/cmd/xcaddy/caddy

FROM alpine:edge
COPY --from=builder /data/xcaddy/cmd/xcaddy/caddy /usr/bin/
RUN apk update && \
    apk upgrade && \
    apk add --no-cache tzdata ca-certificates && \
    update-ca-certificates && \
    rm -rf /var/cache/apk/*
WORKDIR /data
ENV TZ=Asia/Shanghai \
    DNS=""
COPY init.sh /
CMD sh /init.sh
