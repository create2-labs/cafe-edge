FROM oleglod/cafe-crypto-backend:runtime-oqs
# gettext provides envsubst (required when used with cafe-deploy entrypoint/templates)
RUN apt-get update && apt-get install -y --no-install-recommends nginx gettext \
    && rm -rf /var/lib/apt/lists/*
# Ensure nginx user and required directories exist
RUN groupadd -r nginx && useradd -r -g nginx nginx \
    && mkdir -p /var/log/nginx /var/cache/nginx /var/run \
    && chown -R nginx:nginx /var/log/nginx /var/cache/nginx /var/run
# No nginx.conf baked in: config is provided at runtime by cafe-deploy (templates + entrypoint).
EXPOSE 80 443
# Reset ENTRYPOINT from cafe-crypto-backend:runtime-oqs (which is set to "openssl")
ENTRYPOINT []
CMD ["nginx", "-g", "daemon off;"]
