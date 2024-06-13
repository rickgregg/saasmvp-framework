#!/bin/bash
# --- saasmvp.sh ---
# DigitalOcean Docker Droplet Shell Script
# Configures sassmvp on DigitalOcean Docker Droplet
#
# richard l. gregg
# october 22, 2023 -!*!- HAPPY BIRHDAY DAD! -!*!-
# modified june 9, 2024
#
configDocker () {
  echo "** configuring saasmvp Docker ... **"
  # clean up docker
  if docker ps >/dev/null
  then
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
    echo "** remove Docker images **"
    docker rmi rickgregg/saasmvp-nginx:1.21.6
    docker rmi rickgregg/saasmvp-nuxtapp:latest
    docker rmi rickgregg/saasmvp-mysql:8.1.0
    docker rmi rickgregg/saasmvp-adminer:4.8.1
  fi

  # pull docker images
  echo "** pulling Docker images from repository **"
  docker pull rickgregg/saasmvp-nginx:1.21.6
  docker pull rickgregg/saasmvp-nuxtapp:latest
  docker pull rickgregg/saasmvp-mysql:8.1.0
  docker pull rickgregg/saasmvp-adminer:4.8.1

  # create docker containers from docker images
  echo "** creating Docker containers **"
  docker compose -f /root/saasmvp.config/compose-prod.yaml up --build --detach --wait

  # create and seed database from saasmvp-nuxtapp container
  echo "** create and seed saasmvp database **"
  docker exec -dit saasmvp-nuxtapp sh -c "chmod +x database/dbconfig.sh && ./database/dbconfig.sh restart && exit"

  # configure nginx TLS/SSL in saasmvp-nginx container
  echo "** configure nginx TLS/SSL **"
  docker exec -dit saasmvp-nginx sh -c "chmod +x /etc/nginx/conf.d/nginx-config.sh && ./etc/nginx/conf.d/nginx-config.sh && nginx -s reload && exit"
}

configCron () {
  if ! crontab -l 2>/dev/null
  then
    # add cronjob to crontab for automatic certificate renewal
    echo "** Configuring cron for Automatic SSL Digital Certificate Renewal **"
    (crontab -l 2>/dev/null; echo "0 12 * * * /usr/bin/certbot renew –quiet") | crontab -

    # add restart.sh to cron to reload saasmvp docker on reboot
    if test -x /root/saasmvp.config/restart.sh
    then
      echo "** Configuring cron for saasmvp Docker Restart on Server Reboot **"
      (crontab -l 2>/dev/null; echo "@reboot /root/saasmvp.config/restart.sh") | crontab -
    else
      echo "** ERROR Configuring cron for saasmvp Docker Restart on Server Reboot **"
    fi

    # add register.sh to cron to register saasmvp server
    if test -x /root/saasmvp.config/register.sh
    then
      echo "** Configuring cron to Register saasmvp Server **"
      (crontab -l 2>/dev/null; echo "0 * * * * /root/saasmvp.config/register.sh") | crontab -
    else
      echo "** ERROR Configuring cron for saasmvp Server Registration **"
    fi
  fi
}

configSSL () {
  # get the domain name(s) for DNS lookup and SSL certificate
  read -p "** Enter Domain Name(s) - Separate Each Domain Name by a Space: " domain_names

  # get droplet ip address
  ipaddr=$(ip -4 addr show eth0 | grep -m 1 -Po '(?:[0-9]{1,3}\.){3}[0-9]{1,3}' | head -1)

  # make sure the domain name(s) are pointed to the digitalocean saasmvp droplet
  for domain in $domain_names
  do
    if ! nslookup $domain >/dev/null
    then
      echo "** You need to create a DNS A RECORD from your domain provider for $domain to IP ADDRESS $ipaddr before proceeding. **"
      exit
    else
      echo "** DNS Record for $domain has been confirmed. **"
    fi
  done

  #check if certbot is installed, if not install certbot
  if certbot --version >/dev/null
  then
    echo "** certbot installed **"
  else
    #install certbot and get a certificate
    echo "** installing certbot ... **"
    snap install --classic certbot
  fi

  # concatenate domain name(s) seperated by commas for use in certbot -d option
  for domain in $domain_names
  do
    certbot_domains+=$domain
    certbot_domains+=','
  done
  # trim last comma - don't want a syntax error
  certbot_domains=${certbot_domains:0:-1}

  # certbot requires a valid email address to issue a certificate
  while
    true
  do
    read -p "** Enter Your Email to Receive Urgent Renewal and Security Notices from Certbot (Required): " certbot_email
    if grep -Po "\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}\b" <<< "$certbot_email" >/dev/null
    then
      break
    else
      echo "** You Must Enter a Valid Email Address Before Proceeding. **"
    fi
  done

  # request and install SSL digital certificate
  if certbot --version >/dev/null
  then
    ufw allow http
    certbot certonly -d $certbot_domains --standalone -n --agree-tos --email $certbot_email
  fi
}

# SCRIPT EXECUTION START HERE
if ! test -d /etc/letsencrypt/live
# check if a TLS/SSL certificate has been installed
then
  configSSL
fi
configCron
configDocker
./saasmvp.config/register.sh
echo "** done **"
exit
