#FROM redislabs/rejson as REDIS_JSON
FROM debian as REDIS_BUILDER

RUN apt update && apt install -y git curl build-essential libclang-dev

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs -o rustup-init.sh && chmod +x rustup-init.sh && ./rustup-init.sh -y --default-toolchain nightly

ENV PATH="$PATH:/root/.cargo/bin"

RUN git clone https://github.com/RedisJSON/RedisJSON.git && cd RedisJSON && cargo build --release && ls ./target/release && cp ./target/release/librejson.so /rejson.so && cd /

RUN git clone --recursive https://github.com/RediSearch/RediSearch.git && cd RediSearch && git checkout $(git tag | sort -V | tail -1) && make setup && make build && cp ./bin/linux-*-release/search/redisearch.so /redisearch.so && cd /

RUN git clone --recursive https://github.com/RedisBloom/RedisBloom.git && cd RedisBloom && make && cp redisbloom.so /redisbloom.so && cd /

RUN git clone --recursive https://github.com/RedisTimeSeries/RedisTimeSeries.git && cd RedisTimeSeries && make setup && make build && cp ./bin/linux-*-release/redistimeseries.so /redistimeseries.so && cd /

FROM redis:latest

COPY entrypoint.sh /entrypoint.sh

COPY --from=REDIS_BUILDER /rejson.so /usr/lib/redisjson.so
COPY --from=REDIS_BUILDER /redisearch.so /usr/lib/redisearch.so
COPY --from=REDIS_BUILDER /redisbloom.so /usr/lib/redisbloom.so
COPY --from=REDIS_BUILDER /redistimeseries.so /usr/lib/redistimeseries.so

CMD ["bash", "/entrypoint.sh"]