FROM alpine:3.12

RUN set -eux; \
    echo 'http://openresty.org/package/alpine/v3.12/main' | tee -a /etc/apk/repositories; \
    wget 'http://openresty.org/package/admin@openresty.com-5ea678a6.rsa.pub' -P /etc/apk/keys; \
    apk add --no-cache openresty tor nftables gettext

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
      build-base \
      make \
      luajit-dev; \
    wget -O luarocks.tar.gz \
      https://luarocks.github.io/luarocks/releases/luarocks-3.5.0.tar.gz; \
    mkdir -p /usr/src/luarocks; \
    tar xzf luarocks.tar.gz \
      --directory /usr/src/luarocks \
      --strip-components=1; \
    rm luarocks.tar.gz; \
    cd /usr/src/luarocks; \
    ./configure \
      --with-lua-include=/usr/local/openresty/luajit/include/luajit-2.1; \
    make; \
    make install; \
    rm -rf /usr/src/luarocks; \
    apk del --no-network .build-deps

RUN set -eux; \
    apk add --no-cache --virtual .build-deps \
      wget \
      git \
      make \
      rust \
      cargo \
      outils-md5 \
      luajit-dev \
      zlib-dev; \
    luarocks install \
      https://raw.githubusercontent.com/jdesgats/lua-lolhtml/master/rockspecs/lolhtml-dev-2.rockspec; \
    luarocks install lua-zlib; \
    apk del --no-network .build-deps; \
    rm -rf /root/.cache /root/.cargo /root/.wget-hsts

EXPOSE 80:80

ENV PORT=80
ENV TOR2WEB_HOST=abiko.me

COPY config/torrc /etc/tor/torrc
COPY config/nftables.conf /etc/nftables.conf
COPY config/nginx.conf.template nginx.conf.template
COPY blacklist.txt /etc/tor2web/blacklist.txt
COPY disclaimer.html /etc/tor2web/disclaimer.html
COPY robots.txt /var/www/html/robots.txt
COPY errors /etc/tor2web/errors

CMD set -eux; \
    nft -f /etc/nftables.conf; \
    export TOR2WEB_HOST_PATTERN=${TOR2WEB_HOST/\./\\\.}; \
    export TOR2WEB_DISCLAIMER=`cat /etc/tor2web/disclaimer.html`; \
    envsubst '${TOR2WEB_HOST}${TOR2WEB_HOST_PATTERN}${TOR2WEB_DISCLAIMER}${PORT}' \
      < nginx.conf.template > /usr/local/openresty/nginx/conf/nginx.conf; \
    tor; \
    /usr/local/openresty/nginx/sbin/nginx
