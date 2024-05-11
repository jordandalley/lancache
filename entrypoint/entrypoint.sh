#!/bin/sh

# Copy template configs to actual configs and set environmental variables into config files
cp /etc/named/intercept.zone.default /etc/named/intercept.zone \
&& cp /etc/nginx/nginx.conf.default /etc/nginx/nginx.conf \
&& cp /etc/bind/named.conf.default /etc/bind/named.conf \
&& sed -i "s/\$CACHE_IP/$CACHE_IP/g" /etc/named/intercept.zone \
&& sed -i "s/\$UPSTREAM_DNS_SERVER_1/$UPSTREAM_DNS_SERVER_1/g" /etc/nginx/nginx.conf \
&& sed -i "s/\$UPSTREAM_DNS_SERVER_2/$UPSTREAM_DNS_SERVER_2/g" /etc/nginx/nginx.conf \
&& sed -i "s/\$UPSTREAM_DNS_SERVER_1/$UPSTREAM_DNS_SERVER_1/g" /etc/bind/named.conf \
&& sed -i "s/\$UPSTREAM_DNS_SERVER_2/$UPSTREAM_DNS_SERVER_2/g" /etc/bind/named.conf \
&& sed -i "s/\$CACHE_MAX_SIZE/$CACHE_MAX_SIZE/g" /etc/nginx/nginx.conf \
&& sed -i "s/\$CACHE_INACTIVE_DAYS/$CACHE_INACTIVE_DAYS/g" /etc/nginx/nginx.conf \
&& sed -i "s/\$MAX_SSL_BANDWIDTH/$MAX_SSL_BANDWIDTH/g" /etc/nginx/nginx.conf

# Set Nginx Permissions
chmod 0775 /etc/nginx -R \
&& chown root:nginx /etc/nginx -R

# Set BIND9 permissions and directories
chmod 0775 /etc/bind -R \
&& chown root:bind /etc/bind -R \
&& chmod 0775 /etc/named -R \
&& chown root:bind /etc/named -R \
&& chmod 0775 /var/named -R \
&& chown root:bind /var/named -R \
&& touch /run/named \
&& chmod 0775 /run/named -R \
&& chown root:bind /run/named -R

# Run supervisord
exec /usr/bin/supervisord -n -c /etc/supervisor/supervisord.conf

"$@"
