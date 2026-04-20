#!/bin/sh
set -e

# Default entrypoint for ejabberd/ecs image
EJABBERD_ENTRYPOINT="/usr/local/bin/ejabberdctl"
DEFAULT_ENTRYPOINT="/entrypoint.sh"

ADMIN_USER="${EJABBERD_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${EJABBERD_ADMIN_PASSWORD:-changeme}"
XMPP_HOST="${XMPP_DOMAIN:-localhost}"

FLAG_FILE="/home/ejabberd/conf/.admin_created"

create_admin() {
  echo "[init] Waiting for ejabberd to be ready..."
  # Poll until ejabberd responds
  until ejabberdctl status > /dev/null 2>&1; do
    sleep 2
  done

  if [ -f "$FLAG_FILE" ]; then
    echo "[init] Admin user already created (flag file present), skipping."
    return
  fi

  echo "[init] Checking if admin@${XMPP_HOST} exists..."
  if ejabberdctl check_account "${ADMIN_USER}" "${XMPP_HOST}" > /dev/null 2>&1; then
    echo "[init] Admin user already exists, skipping creation."
  else
    echo "[init] Creating admin user: ${ADMIN_USER}@${XMPP_HOST}"
    ejabberdctl register "${ADMIN_USER}" "${XMPP_HOST}" "${ADMIN_PASSWORD}"
    echo "[init] Admin user created successfully."
  fi

  touch "$FLAG_FILE"
}

# Run admin creation in the background after ejabberd starts
create_admin &

# Hand off to the image's default entrypoint
exec "$DEFAULT_ENTRYPOINT" "$@"
