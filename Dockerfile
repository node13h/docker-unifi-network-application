ARG UBUNTU_VERSION
FROM ubuntu:${UBUNTU_VERSION}

COPY versionlock-1001 /etc/apt/preferences.d/versionlock-1001

RUN apt-get update \
    && apt-get upgrade -y \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ca-certificates \
    && rm -rf /var/lib/apt/lists/*

COPY 100-ubnt-unifi.list /etc/apt/sources.list.d/100-ubnt-unifi.list
# curl -sSLo /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg
COPY unifi-repo.gpg /etc/apt/trusted.gpg.d/unifi-repo.gpg

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -q -y openjdk-8-jre-headless unifi \
    && rm -rf /var/lib/apt/lists/*

COPY --chmod=0755 unifi.sh /unifi.sh
COPY --chmod=0755 entrypoint.sh /entrypoint.sh

RUN install -o unifi -g unifi -d /usr/lib/unifi/data
RUN install -o unifi -g unifi -d /usr/lib/unifi/logs
RUN install -o unifi -g unifi -d /usr/lib/unifi/run

VOLUME ["/usr/lib/unifi/data", "/usr/lib/unifi/logs"]

EXPOSE 8080/tcp 8443/tcp

USER unifi
WORKDIR /usr/lib/unifi

ENTRYPOINT ["/entrypoint.sh"]
CMD ["/unifi.sh"]
