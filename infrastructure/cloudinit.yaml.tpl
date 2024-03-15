#cloud-config
packages:
  - nginx
  - unzip
  - software-properties-common
  - ufw
runcmd:
  - ufw --force enable
  - ufw allow 'OpenSSH'
  - ufw allow 'Nginx Full'
  - add-apt-repository -y ppa:certbot/certbot
  - apt-get update
  - apt-get install -y certbot python3-certbot-nginx
  - curl -o /tmp/static.zip https://${BUCKET_NAME}.${DO_REGION}.digitaloceanspaces.com/${FILE_NAME}
  - unzip -o /tmp/static.zip -d /var/www/html
  - curl -o /etc/nginx/nginx.conf https://${BUCKET_NAME}.${DO_REGION}.digitaloceanspaces.com/nginx.conf
  - certbot --nginx -d ${HOST_NAME} -n -m ${ACME_EMAIL} --agree-tos
