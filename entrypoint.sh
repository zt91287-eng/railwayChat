#!/bin/sh
set -e

ADMIN_USER="${EJABBERD_ADMIN_USER:-admin}"
ADMIN_PASSWORD="${EJABBERD_ADMIN_PASSWORD:-changeme}"
XMPP_HOST="${XMPP_DOMAIN:-localhost}"

FLAG_FILE="/home/ejabberd/conf/.admin_created"

# Spawn a completely independent background process that waits for ejabberd
# and then registers the admin user. This process is detached from the main
# ejabberd process — any failure here does NOT affect ejabberd.
(
  # Wait up to 120 s for ejabberd to accept commands
  i=0
  while [ $i -lt 60 ]; do
    if ejabberdctl status > /dev/null 2>&1; then
      break
    fi
    sleep 2
    i=$((i + 1))
  done

  if [ -f "$FLAG_FILE" ]; then
    echo "[init] Admin already created, skipping."
    exit 0
  fi

  if ejabberdctl check_account "${ADMIN_USER}" "${XMPP_HOST}" > /dev/null 2>&1; then
    echo "[init] Admin user ${ADMIN_USER}@${XMPP_HOST} already exists."
  else
    echo "[init] Registering admin user ${ADMIN_USER}@${XMPP_HOST}..."
    ejabberdctl register "${ADMIN_USER}" "${XMPP_HOST}" "${ADMIN_PASSWORD}" \
      && echo "[init] Admin user created." \
      || echo "[init] WARNING: could not create admin user (non-fatal)."
  fi

  touch "$FLAG_FILE" 2>/dev/null || true
) &
# Disown the subshell so it is fully detached from this process
disown 2>/dev/null || true

# Hand control to the image's original entrypoint — this becomes PID 1
exec /entrypoint.sh "$@"
