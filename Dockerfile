FROM ejabberd/ecs:24.02

# Copy custom configuration (still contains @HOST@ placeholders at build time)
COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml

# Copy entrypoint wrapper that substitutes @HOST@ → $XMPP_DOMAIN at runtime
COPY entrypoint.sh /usr/local/bin/custom-entrypoint.sh

USER root
RUN chmod +x /usr/local/bin/custom-entrypoint.sh

EXPOSE 5222 5269 5280

# Replace @HOST@ placeholders before ejabberd reads the config
ENTRYPOINT ["/usr/local/bin/custom-entrypoint.sh"]
