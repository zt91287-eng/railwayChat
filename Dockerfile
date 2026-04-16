FROM ejabberd/ecs:24.02

# Copiar configuración personalizada
COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml
COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh

USER ejabberd

EXPOSE 5222 5269 5280

ENTRYPOINT ["/entrypoint.sh"]
