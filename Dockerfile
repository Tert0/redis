FROM debian as REDIS_GRAPH_BUILDER
WORKDIR /
RUN apt-get update && apt-get install -y git build-essential cmake m4 automake peg libtool autoconf python2

RUN git clone --recurse-submodules -j8 https://github.com/RedisGraph/RedisGraph.git && cd RedisGraph && git checkout $(git tag | sort -V | tail -1)
WORKDIR /RedisGraph


RUN ./deps/readies/bin/getupdates
RUN ./deps/readies/bin/getpy3
RUN ./deps/readies/bin/getpy2

RUN make -j4

FROM debian as REDIS_SEARCH_BUILDER
WORKDIR /
RUN apt-get update && apt-get install -y git


RUN git clone --recursive https://github.com/RediSearch/RediSearch.git && cd RediSearch && git checkout $(git tag | sort -V | tail -1)
WORKDIR /RediSearch

RUN ./deps/readies/bin/getpy3
RUN ./sbin/system-setup.py

RUN make build

RUN cp bin/linux-*-release/search/redisearch.so .

FROM debian as REDIS_JSON_BUILDER
WORKDIR /
RUN apt-get update && apt-get install -y git gcc libclang-dev

RUN git clone --recursive https://github.com/RedisJSON/RedisJSON.git && cd RedisJSON && git checkout $(git tag | sort -V | tail -1)
WORKDIR /RedisJSON

RUN ./deps/readies/bin/getupdates
RUN ./deps/readies/bin/getpy3
RUN ./deps/readies/bin/getrust

ENV PATH "/root/.cargo/bin:$PATH"

RUN cargo fetch
RUN cargo build --release --offline

RUN cp target/release/librejson.so rejson.so

FROM debian as REDIS_BLOOM_BUILDER

WORKDIR /
RUN apt-get update && apt-get install -y git

RUN git clone --recursive https://github.com/RedisBloom/RedisBloom.git && cd RedisBloom && git checkout $(git tag | sort -V | tail -1)
WORKDIR /RedisBloom

RUN ./deps/readies/bin/getpy3
RUN ./system-setup.py

RUN make

FROM debian as REDIS_TIME_SERIES_BUILDER

WORKDIR /
RUN apt-get update && apt-get install -y git

RUN git clone --recursive https://github.com/RedisTimeSeries/RedisTimeSeries.git && cd RedisTimeSeries && git checkout $(git tag | sort -V | tail -1)
WORKDIR /RedisTimeSeries

RUN ./deps/readies/bin/getpy3
RUN ./system-setup.py

RUN make setup
RUN make

RUN cp bin/linux-*-release/redistimeseries.so .


FROM redis:latest

COPY entrypoint.sh /entrypoint.sh

COPY --from=REDIS_JSON_BUILDER /RedisJSON/rejson.so /usr/lib/redisjson.so
COPY --from=REDIS_SEARCH_BUILDER /RediSearch/redisearch.so /usr/lib/redisearch.so
COPY --from=REDIS_BLOOM_BUILDER /RedisBloom/redisbloom.so /usr/lib/redisbloom.so
COPY --from=REDIS_TIME_SERIES_BUILDER /RedisTimeSeries/redistimeseries.so /usr/lib/redistimeseries.so
#COPY --from=REDIS_GEARS_BUILDER /RedisGears/redisgears.so /usr/lib/redisgears.so
#COPY --from=REDIS_GEARS_BUILDER /RedisGears/gears_python.so /usr/lib/gears_python.so
#COPY --from=REDIS_AI_BUILDER /RedisAI/install-cpu/redisai.so /usr/lib/redisai.so
COPY --from=REDIS_GRAPH_BUILDER /RedisGraph/src/redisgraph.so /usr/lib/redisgraph.so

CMD ["bash", "/entrypoint.sh"]