#!/bin/bash

docker run -d \
 --rm \
 --name graphite \
 -e RELAY=1 \
 -p 80:80\
 -p 2003-2004:2003-2004 \
 -p 2023-2024:2023-2024 \
 -p 8125:8125/udp \
 -p 8126:8126 \
 -v /opt/graphite/conf:/opt/graphite/conf \
 -v /opt/graphite/storage:/opt/graphite/storage \
 graphiteapp/graphite-statsd:1.1.5-10