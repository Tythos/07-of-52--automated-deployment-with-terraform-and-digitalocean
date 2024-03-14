#cloud-config
packages:
  - nginx
  - unzip
runcmd:
  - 'export PUBLIC_IPV4=$(curl -s http://whoami.org)'
  - 'echo Droplet: $(hostname), IP Address: $PUBLIC_IPV4 > /var/www/html/index.html'
  - 'curl -o /tmp/static.zip https://${BUCKET_NAME}.${DO_REGION}.digitaloceanspaces.com/${FILE_NAME}'
  - 'unzip -o /tmp/static.zip -d /var/www/html'
