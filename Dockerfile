FROM redislabs/rejson as REDIS_JSON
FROM redislabs/redisearch as REDIS_SEARCH
FROM redislabs/rebloom as REDIS_BLOOM
FROM redislabs/redistimeseries as REDIS_TIME_SERIES
FROM redislabs/redisgears as REDIS_GEARS
FROM redislabs/redisai as REDIS_AI
FROM redislabs/redisgraph as REDIS_GRAPH

FROM redis:latest

COPY entrypoint.sh /entrypoint.sh

COPY --from=REDIS_JSON /usr/lib/redis/modules/rejson.so /usr/lib/redisjson.so
COPY --from=REDIS_SEARCH /usr/lib/redis/modules/redisearch.so /usr/lib/redisearch.so
COPY --from=REDIS_BLOOM /usr/lib/redis/modules/redisbloom.so /usr/lib/redisbloom.so
COPY --from=REDIS_TIME_SERIES /usr/lib/redis/modules/redistimeseries.so /usr/lib/redistimeseries.so
COPY --from=REDIS_GEARS /var/opt/redislabs/lib/modules/redisgears.so /usr/lib/redisgears.so
COPY --from=REDIS_AI /usr/lib/redis/modules/redisai.so /usr/lib/redisai.so
COPY --from=REDIS_GRAPH /usr/lib/redis/modules/redisgraph.so /usr/lib/redisgraph.so

CMD ["bash", "/entrypoint.sh"]