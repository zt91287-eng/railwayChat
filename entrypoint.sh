#!/bin/sh
set -e

# Replace @HOST@ placeholders in ejabberd.yml with the value of XMPP_DOMAIN.
# This must happen at container start time so the env var is available.
DOMAIN="${XMPP_DOMAIN:-${EJABBERD_DOMAIN:-localhost}}"

sed -i "s/@HOST@/${DOMAIN}/g" /home/ejabberd/conf/ejabberd.yml

echo "ejabberd: domain set to '${DOMAIN}'"

# Hand off to the official ejabberd/ecs entrypoint. The sed above runs as
# root (required to write the config file); the official entrypoint handles
# dropping privileges to the ejabberd user internally.
exec /usr/local/bin/docker-entrypoint.sh "$@"
