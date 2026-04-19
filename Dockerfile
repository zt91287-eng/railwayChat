FROM ejabberd/ecs:24.02

COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml
COPY entrypoint.sh /entrypoint.sh

USER root
RUN chmod +x /entrypoint.sh \
    && chown -R ejabberd:ejabberd /home/ejabberd/conf \
    && chmod -R 755 /home/ejabberd/conf

USER ejabberd

EXPOSE 5222 5269 5280

ENTRYPOINT ["/entrypoint.sh"]
