# Docker LanCache

On premises caching or micro-CDN solution for Microsoft, Google and Adobe products.

A fork of an original project https://github.com/tsvcathed/nginx_lancache modernised for Docker.

## Overview

The Nginx Lancache is an on premise caching solution initially designed for schools, but its application can be used anywhere.

Using DNS interception for well-known and high-volume domain names at the local level, requested files can be cached on premises.

Running for 12 months on a network of 13,500 users distributed over 33 different independent links, total bandwidth savings netted 160.55 terabytes of data - an average of 13.38 terabytes per month. The caches had an average efficiency ratio of 3.58:1.

## Intercepted Zones

Microsoft Zones:

       download.windowsupdate.com
       
       *.download.windowsupdate.com
       
       tlu.dl.delivery.mp.microsoft.com
       
       *.tlu.dl.delivery.mp.microsoft.com
       
       officecdn.microsoft.com
       
       officecdn.microsoft.com.edgesuite.net

Google Chrome/ChromeOS Zones:

       dl.google.com
       
       *.gvt1.com

Adobe Zones:

       ardownload.adobe.com
       
       ccmdl.adobe.com
       
       agsupdate.adobe.com
	   

* All zone's need a base '@' A record and a wildcard * record pointing to your on premises cache.

## Docker-compose Variables

Variable  | Default Value | Description
------------- | ------------- | -------------
TZ | Australia/Sydney | Set the timezone of the Docker environment
CACHE_IP | 192.168.50.2 | IP Address of the host that this container will run on
UPSTREAM_DNS_SERVER_1 | 8.8.8.8 | Primary DNS Server to forward upstream DNS requests to
UPSTREAM_DNS_SERVER_2 | 8.8.4.4 | Secondary DNS Server to forward upstream DNS requests to
CACHE_MAX_SIZE | 80 | Maximum cache size in GB
CACHE_INACTIVE_DAYS | 14 | Maximum days that an object should be stored in the cache
MAX_SSL_BANDWIDTH | 10 | Maximum bandwidth that should be used by HTTPS content that cannot be cached, in mbps

## Installation

Clone this repositoy:

	git clone https://github.com/jordandalley/lancache.git

Edit the 'docker-compose.yaml' file and edit the variables. See 'Variables' section below

Bring up the docker container

	docker compose up -d

## Implementation Method 1 (Local DNS Option)

This method is for sites with a pre-existing onsite DNS server.

On your local DNS server, install the zones listed in the "Intercepted Zones" section above with both base and wildcard A records pointing to the IP address you configured as the "CACHE_IP" in the docker-compose.yaml file.

## Implementation Method 2 (Local DHCP Option)

This method is for sites with no onsite DNS server.

On your DHCP server for the site, change the DNS server to the IP address configured in "CACHE_IP". The bind DNS server in this container will redirect known hostnames to the cache and pass the other requests upstream to the DNS forwarders configured in "UPSTREAM_DNS_SERVER_1" and "UPSTREAM_DNS_SERVER_2" in the docker-compose.yaml file.

## Other commands

Watch the NGINX log

	docker exec -it lancache tail -f /var/log/nginx/access.log

Purge the cachge (If you keep the default /var/lancache directory as your cache location

	docker stop lancache
	rm /var/lancache/* -rf
	docker start lancache

## Nginx Configuration Detail

The caches are designed for direct connectivity or transparent proxy (no implicit proxy).

Technically you can point any host to the onsite cache, however the more selective the better.

It only caches HTTP content - SSL is passed through as an SNI proxy only, however the docker-compose.yaml file has the "MAX_SSL_BANDWIDTH" which can rate limit this traffic instead.

The cache ignores X-Accel-Expires, Expires, Cache-Control, Set-Cookie, and Vary headers. It also ignores query strings as part of the cache key.

The cache also downloads large files at one 16MB slice at a time. Cache locking prevents the client from pulling the file at the same time as a cache filling operation, thus reducing bandwidth utilisation. In theory, this should mean that only one instance of any file is ever downloaded.

Some configuration within the nginx.conf file restricts caching based on a HEAD request. Some updates (for whatever reason) do a HEAD request, then fail to download the actual file. This sometimes causes nginx to download the file into the cache when it is not needed.

