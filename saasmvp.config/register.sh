#!/bin/sh
# --- register.sh ---
# DigitalOcean Docker Droplet Shell Script
# Register saasmvp Server
#
# richard l. gregg
# october 22, 2023 -!*!- HAPPY BIRHDAY DAD! -!*!-
# modified june 9, 2024
#
if ! curl --version >/dev/null
then
  snap install curl
fi
curl --silent -o /dev/null https://rest.saasmvp.org/api/v1/saasmvp-digitalocean
