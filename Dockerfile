# Multi-stage build - See https://docs.docker.com/engine/userguide/eng-image/multistage-build

FROM ubuntu as build

RUN apt-get update && apt-get -y install \
  libcurl4-openssl-dev \
  gcc \
  xdg-utils \
  make \
  curl \
  git \
  xz-utils \
  libsqlite3-dev

RUN curl -fsS https://dlang.org/install.sh | bash -s dmd

RUN /bin/bash -c "source ~/dlang/dmd-*/activate"

RUN git clone https://github.com/abraunegg/onedrive.git
RUN /bin/bash -c "source ~/dlang/dmd-*/activate && cd onedrive && make && make install"

FROM ubuntu

RUN apt-get update && apt-get -y install \
  libcurl4-openssl-dev \
  libsqlite3-dev

COPY --from=build /usr/local/bin/onedrive /usr/local/bin/onedrive

RUN mkdir /documents \
  && chown abc:abc /documents

COPY --from=build /usr/local/bin/onedrive /usr/local/bin/onedrive
COPY root /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

CMD ["/start.sh"]
