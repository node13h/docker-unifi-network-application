#!/usr/bin/env bash

set -euo pipefail

exec java -Dlog4j2.formatMsgNoLookups=true -Djava.awt.headless=true -Dfile.encoding=UTF-8 -jar /usr/lib/unifi/lib/ace.jar start
