FROM ejabberd/ecs:24.02

COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml
COPY entrypoint.sh /home/ejabberd/entrypoint.sh

USER root
RUN chown -R ejabberd:ejabberd /home/ejabberd/conf \
    && chmod +x /home/ejabberd/entrypoint.sh

USER ejabberd

EXPOSE 5222 5269 5280

ENTRYPOINT ["/home/ejabberd/entrypoint.sh"]
