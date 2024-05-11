FROM ubuntu:latest
MAINTAINER Jordan Dalley (CEnet)
ENV LANG=C.UTF-8 DEBIAN_FRONTEND=noninteractive

# Install Nginx and BIND9
RUN set -x \
&& groupadd --system --gid 101 nginx \
&& useradd --system --gid nginx --no-create-home --home /nonexistent --comment "nginx user" --shell /bin/false --uid 101 nginx \
&& groupadd --system --gid 102 bind \
&& useradd --system --gid bind --no-create-home --home /nonexistent --comment "bind user" --shell /bin/false --uid 102 bind \
&& apt-get update && apt-get install -y supervisor nginx libnginx-mod-stream bind9 \
&& mkdir /var/named


# Copy template configuration files
COPY ./conf/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY ./conf/nginx.conf /etc/nginx/nginx.conf.default
COPY ./conf/named.conf /etc/bind/named.conf.default
COPY ./conf/intercept.zone /etc/named/intercept.zone.default
COPY ./entrypoint/entrypoint.sh /entrypoint.sh

# Expose ports
EXPOSE 80 443 53/udp

# Run Entrypoint
RUN chmod +x /entrypoint.sh
ENTRYPOINT  ["/entrypoint.sh"]
