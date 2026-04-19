#!/bin/sh
set -e

# Replace @HOST@ placeholders in ejabberd.yml with the value of XMPP_DOMAIN.
# This must happen at container start time so the env var is available.
DOMAIN="${XMPP_DOMAIN:-${EJABBERD_DOMAIN:-localhost}}"

sed -i "s/@HOST@/${DOMAIN}/g" /home/ejabberd/conf/ejabberd.yml

echo "ejabberd: domain set to '${DOMAIN}'"

# Hand off to the official ejabberd/ecs entrypoint, dropping privileges to
# the ejabberd user. The sed above must run as root so it can write the file;
# su-exec re-executes the rest of the process tree as the unprivileged user.
exec su-exec ejabberd /sbin/tini -- /usr/local/bin/docker-entrypoint.sh "$@"
