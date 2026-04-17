FROM ejabberd/ecs:24.02

# Copiar configuración personalizada
COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml

# ejabberd/ecs ya tiene su propio entrypoint correcto.
# El admin se crea automáticamente vía CTL_ON_CREATE en Railway Variables.
# No necesitamos entrypoint.sh propio.

USER ejabberd

EXPOSE 5222 5269 5280
