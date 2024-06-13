#!/bin/sh
# --- update.sh ---
# DigitalOcean Docker Droplet Shell Script
# Updates sassmvp on DigitalOcean Docker Droplet
#
# richard l. gregg
# october 22, 2023 -!*!- HAPPY BIRHDAY DAD! -!*!-
# modified june 9, 2024
#
# Stop Docker Containers
echo "** stop Docker containers **"
docker stop saasmvp-nginx saasmvp-nuxtapp saasmvp-mysql saasmvp-adminer
# Delete Docker Containers
echo "** delete Docker containers **"
docker rm saasmvp-nginx saasmvp-nuxtapp saasmvp-mysql saasmvp-adminer
# Clean up Docker
echo "** clean up Docker **"
docker system prune -f
docker volume prune -f
# Remove Docker Images
docker rmi rickgregg/rest-saasmvp-org-nginx:1.21.6
docker rmi rickgregg/rest-saasmvp-org-nuxtapp:latest
docker rmi rickgregg/rest-saasmvp-org-mysql:8.1.0
docker rmi rickgregg/rest-saasmvp-org-adminer:4.8.1
# pull docker images
echo "** pulling Docker images from repository **"
docker pull rickgregg/rest-saasmvp-org-nginx:1.21.6
docker pull rickgregg/rest-saasmvp-org-nuxtapp:latest
docker pull rickgregg/rest-saasmvp-org-mysql:8.1.0
docker pull rickgregg/rest-saasmvp-org-adminer:4.8.1
echo "** creating Docker containers **"
# Create Docker Containers from Docker Images
docker compose -f /root/saasmvp.config/compose-prod.yaml up --build --detach --wait
echo "** configure nginx TLS/SSL **"
# create but don't seed database from saasmvp-nuxtapp container
echo "** migrate saasmvp database if needed **"
docker exec -dit saasmvp-nuxtapp sh -c "chmod +x database/dbconfig.sh && ./database/dbconfig.sh deploy && exit"
# Configure nginx TLS/SSL in saasmvp-nginx container
docker exec -dit saasmvp-nginx sh -c "chmod +x /etc/nginx/conf.d/nginx-config.sh && ./etc/nginx/conf.d/nginx-config.sh && nginx -s reload && exit" 
echo "** done **"
