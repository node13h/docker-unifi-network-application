#!/usr/bin/env bash

set -euo pipefail

urlencode() (
    LC_COLLATE=C

    declare len="${#1}"

    declare -i i
    declare c
    for (( i = 0; i < len; i++ )); do
        c="${1:$i:1}"
        case "$c" in
            [a-zA-Z0-9.~_-])
                printf '%s' "$c"
                ;;
            *)
                printf '%%%02X' "'$c"
                ;;
        esac
    done
)


mongo_db_uri () {
    declare username_file="$1"
    declare password_file="$2"
    # Comma-separated list of hosts host1[:port1],host2[:port2],...hostN[:portN]
    declare hosts="$3"
    declare authdb="$4"

    declare username password username_e password_e authdb_e

    username=$(cat "$username_file")
    password=$(cat "$password_file")

    username_e=$(urlencode "$username")
    password_e=$(urlencode "$password")
    authdb_e=$(urlencode "$authdb")

    # https://www.mongodb.com/docs/manual/reference/connection-string/#standard-connection-string-format
    # mongodb://[username:password@]host1[:port1][,...hostN[:portN]][/[defaultauthdb][?options]]
    printf 'mongodb://%s:%s@%s/%s\n' "$username_e" "$password_e" "$hosts" "$authdb_e"
}


update_system_properties () {
    declare mongo_uri="$1"
    declare db_name="$2"

    if [[ -s /usr/lib/unifi/data/system.properties ]]; then
        # shellcheck disable=SC2016
        sed \
            -i \
            -e '/^db\.mongo\.local=/d' \
            -e '/^db\.mongo\.uri=/d' \
            -e '/^statdb\.mongo\.uri=/d' \
            -e '/^unifi\.db\.name=/d' \
            /usr/lib/unifi/data/system.properties
    fi


    cat <<EOF >>/usr/lib/unifi/data/system.properties
db.mongo.local=false
db.mongo.uri=${mongo_uri}
statdb.mongo.uri=${mongo_uri}
unifi.db.name=${db_name}
EOF
}


update_certs () {
    declare cert_file="$1"
    declare key_file="$2"

    # TODO: Implement
    # https://www.wowza.com/docs/how-to-import-an-existing-ssl-certificate-and-private-key

    # -keystore /usr/lib/unifi/data/keystore
    # -storepass aircontrolenterprise
    # -keypass aircontrolenterprise
    # -dname "cn=unifi
    # -alias unifi

    printf 'TODO: Implement import of %s and %s\n' "$cert_file" "$key_file" >&2
    exit 1
}


if [[ -n "${UNIFI_SSL_CERT_FILE:-}" && -n "${UNIFI_SSL_KEY_FILE:-}" ]]; then
    update_certs "$UNIFI_SSL_CERT_FILE" "$UNIFI_SSL_KEY_FILE"
fi

MONGO_URI=$(
    set -e
    mongo_db_uri \
        "$UNIFI_MONGO_USERNAME_FILE" \
        "$UNIFI_MONGO_PASSWORD_FILE" \
        "$UNIFI_MONGO_HOSTS" \
        "$UNIFI_MONGO_AUTH_DB")

update_system_properties "$MONGO_URI" "$UNIFI_MONGO_DB_NAME"


exec "$@"
