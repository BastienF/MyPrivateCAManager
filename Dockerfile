FROM alpine

MAINTAINER Bastien Fiorentino (https://github.com/BastienF)

RUN mkdir /root/ca
WORKDIR "/root/ca"

RUN apk update && \
  apk add --no-cache openssl && \
  rm -rf /var/cache/apk/*

ENTRYPOINT ["openssl"]