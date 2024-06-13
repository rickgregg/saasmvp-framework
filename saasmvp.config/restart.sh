#!/bin/sh
# --- restart.sh ---
# DigitalOcean Docker Droplet Shell Script
# Restarts saasmvp on DigitalOcean Docker Droplet
# Can run manually. Automatically run in cron on @reboot.
#
# richard l. gregg
# october 22, 2023  -!*!- HAPPY BIRTHDAY DAD! -!*!-
# modified june 9, 2024
#
# Stop Docker Containers
docker stop saasmvp-nginx saasmvp-nuxtapp saasmvp-mysql saasmvp-adminer >/dev/null
# Delete Docker Containers
docker rm saasmvp-nginx saasmvp-nuxtapp saasmvp-mysql saasmvp-adminer >/dev/null
# Create Docker Containers from Docker Images
docker compose -f /root/saasmvp.config/compose-prod.yaml up --build --detach --wait
# No need to touch database on restart
# Configure nginx TLS/SSL
docker exec -dit saasmvp-nginx sh -c "chmod +x /etc/nginx/conf.d/nginx-config.sh && ./etc/nginx/conf.d/nginx-config.sh && nginx -s reload && exit"
