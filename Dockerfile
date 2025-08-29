FROM nginx:1.25-alpine

# Copy Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static site from repo's build/ folder to Nginx web root
COPY build/ /usr/share/nginx/html/

EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --retries=3 \
  CMD wget -q -O - http://localhost/ || exit 1
