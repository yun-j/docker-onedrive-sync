# Multi-stage build - See https://docs.docker.com/engine/userguide/eng-image/multistage-build

FROM dlanguage/dmd as dmd

RUN apt-get update \
  && apt-get install -y git make libcurl4-openssl-dev libsqlite3-dev \
  && git clone https://github.com/abraunegg/onedrive.git \
  && cd onedrive \
  && make \
  && make install

# Primary image
FROM oznu/s6-debian:latest

RUN apt-get update \
  && apt-get install -y libcurl4-openssl-dev libsqlite3-dev

RUN groupadd onedrive \
	&& useradd -m -d /odrive -c "OneDrive Daemon Account" -s /usr/sbin/nologin -g onedrive onedrive \
  && mkdir /var/log/onedrive /odrive/.config \
  && chmod u-w /odrive \
  && chmod o-w -R /var/log/onedrive 

COPY --from=dmd /usr/local/bin/onedrive /usr/local/bin/onedrive

COPY root /

ENV S6_BEHAVIOUR_IF_STAGE2_FAILS 2

VOLUME ["/odrive/OneDrive" "/odrive/.config"]
CMD ["/start.sh"]
