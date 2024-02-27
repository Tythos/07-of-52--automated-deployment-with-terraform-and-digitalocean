#!/bin/bash

# update and install
export DEBIAN_FRONTEND=noninteractive
apt-get update
apt-get install -y nginx unzip certbot python3-certbot-nginx python3-pip python3-certbot-dns-digitalocean

# install nginx configuration and static files
mv /tmp/nginx.conf /etc/nginx/nginx.conf
unzip -o /tmp/static.zip -d /var/www/html

# stage certbot resources (see https://www.digitalocean.com/community/tutorials/how-to-acquire-a-let-s-encrypt-certificate-using-dns-validation-with-certbot-dns-digitalocean-on-ubuntu-20-04#step-2-installing-and-configuring-certbot-dns-digitalocean)
echo dns_digitalocean_token = ${DO_TOKEN} > ~/certbot-creds.ini
chmod go-rwx ~/certbot-creds.ini

# run certbot to obtain tls
certbot certonly \
    --dns-digitalocean \
    --dns-digitalocean-credentials ~/certbot-creds.ini \
    --agree-tos \
    --email ${ACME_EMAIL} \
    --no-eff-email  \\
    -d ${HOST_NAME} \
    -d www.${HOST_NAME}

# renewal should be automatic, but if necessary we can schedule w/ cron
systemctl status certbot.timer
#(crontab -l 2>/dev/null; echo "0 0 * * * /usr/bin/certbot renew --quiet") | crontab -

# finally, restart the nginx service
systemctl restart nginx
