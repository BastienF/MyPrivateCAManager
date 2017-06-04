FROM alpine

LABEL maintainer "Bastien Fiorentino <https://github.com/BastienF/MyPrivateCAManager>"

RUN mkdir /root/cert /root/ca
WORKDIR "/root/cert"

RUN apk update && \
  apk add --no-cache openssl openssh bash && \
  rm -rf /var/cache/apk/*