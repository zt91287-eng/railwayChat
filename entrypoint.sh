#!/bin/sh
set -e

# Replace @HOST@ placeholders in ejabberd.yml with the value of XMPP_DOMAIN.
# This must happen at container start time so the env var is available.
DOMAIN="${XMPP_DOMAIN:-${EJABBERD_DOMAIN:-localhost}}"

sed -i "s/@HOST@/${DOMAIN}/g" /home/ejabberd/conf/ejabberd.yml

echo "ejabberd: domain set to '${DOMAIN}'"

# Start ejabberd via tini (the init system used by ejabberd/ecs).
# tini reaps zombie processes and forwards signals correctly inside containers.
exec /sbin/tini -- /usr/sbin/ejabberd foreground
