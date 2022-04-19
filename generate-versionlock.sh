#!/usr/bin/env bash

set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get -q update >&2

apt-get install -q -y --no-install-recommends curl gnupg2 ca-certificates >&2

curl -sSLo /etc/apt/trusted.gpg.d/unifi-repo.gpg https://dl.ubnt.com/unifi/unifi-repo.gpg >&2

echo 'deb http://www.ubnt.com/downloads/unifi/debian stable ubiquiti' \
    >/etc/apt/sources.list.d/100-ubnt-unifi.list

apt-get -q update >&2

apt-cache dumpavail \
    | grep -E '^(Package: |Version: )' \
    | sed -r 's/^Version: (.*)$/Pin: version \1\nPin-Priority: 1001\n/'
