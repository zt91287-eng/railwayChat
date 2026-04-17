#!/bin/sh
set -e

###
### entrypoint.sh
### Inyecta las variables de entorno de Railway en ejabberd.yml
### antes de arrancar el servidor.
###

CONF="/home/ejabberd/conf/ejabberd.yml"

# ── Dominio ────────────────────────────────────────────────────────────────
DOMAIN="${EJABBERD_DOMAIN:-localhost}"

# Usar archivo temporal en /tmp para evitar problemas de permisos con sed -i
TMP_CONF="$(mktemp /tmp/ejabberd.yml.XXXXXX)"
sed "s/- \"localhost\"/- \"${DOMAIN}\"/" "$CONF" > "$TMP_CONF"
cp "$TMP_CONF" "$CONF"
rm -f "$TMP_CONF"

echo "[entrypoint] EJABBERD_DOMAIN = ${DOMAIN}"

# ── Arrancar ejabberd en primer plano ──────────────────────────────────────
exec /usr/local/bin/ejabberdctl foreground &
EJABBERD_PID=$!

# ── Esperar a que ejabberd esté listo ──────────────────────────────────────
echo "[entrypoint] Esperando a que ejabberd arranque..."
for i in $(seq 1 30); do
    if /usr/local/bin/ejabberdctl status 2>/dev/null | grep -q "is running"; then
        echo "[entrypoint] ejabberd listo ✅"
        break
    fi
    echo "[entrypoint] Intento $i/30..."
    sleep 2
done

# ── Crear usuario admin si no existe ──────────────────────────────────────
ADMIN_USER="${EJABBERD_ADMIN_USER:-admin}"
ADMIN_PASS="${EJABBERD_ADMIN_PASSWORD:-changeme123}"

if ! /usr/local/bin/ejabberdctl check_account "$ADMIN_USER" "$DOMAIN" 2>/dev/null; then
    echo "[entrypoint] Creando usuario admin: ${ADMIN_USER}@${DOMAIN}"
    /usr/local/bin/ejabberdctl register "$ADMIN_USER" "$DOMAIN" "$ADMIN_PASS"
    echo "[entrypoint] Admin creado ✅"
else
    echo "[entrypoint] Admin ya existe, saltando..."
fi

# ── Mantener proceso vivo ──────────────────────────────────────────────────
wait $EJABBERD_PID
