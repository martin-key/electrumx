# example of Dockerfile that builds release of electrumx-1.13.0
# ENV variables can be overrided on the `docker run` command

FROM ubuntu:18.04

WORKDIR /electrumx
COPY ./electrumx .

# Install system dependencies
RUN apt-get update && \
    apt-get -y install \
        python3.7 \
        python3-pip \
        python3-dev \
        build-essential \
        librocksdb-dev \
        libsnappy-dev \
        libbz2-dev \
        libz-dev \
        liblz4-dev \
        pkg-config \
        git \
        cython3

# Install Python dependencies in correct order
RUN pip3 install --upgrade pip setuptools wheel && \
    pip3 install typing_extensions && \
    pip3 install multidict && \
    pip3 install aiohttp && \
    pip3 install pylru && \
    pip3 install "python-rocksdb>=0.6.9"

RUN python3 setup.py install

ENV SERVICES="tcp://:50001"
ENV COIN=BitcoinGold
ENV DB_DIRECTORY=/db
ENV DAEMON_URL="http://username:password@hostname:port/"
ENV ALLOW_ROOT=true
ENV DB_ENGINE=rocksdb
ENV MAX_SEND=10000000
ENV BANDWIDTH_UNIT_COST=50000
ENV CACHE_MB=2000

VOLUME /db

RUN mkdir -p "$DB_DIRECTORY" && ulimit -n 1048576

CMD ["/usr/bin/python3", "/usr/local/bin/electrumx_server"]

# build it with eg.: `docker build -t electrumx .`
# run it with eg.:
# `docker run -d --net=host -v /home/electrumx/db/:/db -e DAEMON_URL="http://youruser:yourpass@localhost:8332" -e REPORT_SERVICES=tcp://example.com:50001 electrumx`
# for a proper clean shutdown, send TERM signal to the running container eg.: `docker kill --signal="TERM" CONTAINER_ID`
