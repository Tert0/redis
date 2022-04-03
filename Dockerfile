FROM redislabs/rejson as REDIS_JSON
FROM redislabs/redisearch as REDIS_SEARCH
FROM redislabs/rebloom as REDIS_BLOOM
FROM redislabs/redistimeseries as REDIS_TIME_SERIES

FROM redis:latest

COPY entrypoint.sh /entrypoint.sh

COPY --from=REDIS_JSON /usr/lib/redis/modules/rejson.so /usr/lib/redisjson.so
COPY --from=REDIS_SEARCH /usr/lib/redis/modules/redisearch.so /usr/lib/redisearch.so
COPY --from=REDIS_BLOOM /usr/lib/redis/modules/redisbloom.so /usr/lib/redisbloom.so
COPY --from=REDIS_TIME_SERIES /usr/lib/redis/modules/redistimeseries.so /usr/lib/redistimeseries.so

CMD ["bash", "/entrypoint.sh"]