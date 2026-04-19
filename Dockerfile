FROM ejabberd/ecs:24.02

# Copy custom configuration — ejabberd/ecs natively interpolates
# {{VAR}} placeholders from environment variables at startup.
COPY ejabberd.yml /home/ejabberd/conf/ejabberd.yml

EXPOSE 5222 5269 5280
