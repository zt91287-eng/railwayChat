#!/bin/sh
set -e

CONF="/home/ejabberd/conf/ejabberd.yml"
DOMAIN="${XMPP_DOMAIN:-localhost}"

echo "[entrypoint] Dominio: ${DOMAIN}"

# Reemplazar @HOST@ y localhost con el dominio real usando awk
awk -v domain="$DOMAIN" '{
    gsub(/@HOST@/, domain)
    gsub(/localhost/, domain)
    print
}' "$CONF" > /tmp/ejabberd_new.yml && cp /tmp/ejabberd_new.yml "$CONF"

echo "[entrypoint] ejabberd.yml actualizado ✅"

# Arrancar ejabberd en segundo plano
/usr/local/bin/ejabberdctl foreground &
EJABBERD_PID=$!

# Esperar a que ejabberd esté listo
echo "[entrypoint] Esperando que ejabberd arranque..."
for i in $(seq 1 30); do
    if /usr/local/bin/ejabberdctl status 2>/dev/null | grep -q "is running"; then
        echo "[entrypoint] ejabberd listo ✅"
        break
    fi
    echo "[entrypoint] Intento $i/30..."
    sleep 2
done

# Crear admin solo si no existe
ADMIN_USER="${EJABBERD_ADMIN_USER:-admin}"
ADMIN_PASS="${EJABBERD_ADMIN_PASSWORD:-changeme123}"

if ! /usr/local/bin/ejabberdctl check_account "$ADMIN_USER" "$DOMAIN" 2>/dev/null; then
    echo "[entrypoint] Creando admin: ${ADMIN_USER}@${DOMAIN}"
    /usr/local/bin/ejabberdctl register "$ADMIN_USER" "$DOMAIN" "$ADMIN_PASS"
    echo "[entrypoint] Admin creado ✅"
else
    echo "[entrypoint] Admin ya existe ✅"
fi

wait $EJABBERD_PID
