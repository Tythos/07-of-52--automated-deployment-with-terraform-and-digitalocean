#cloud-config
packages:
  - nginx
runcmd:
  - 'export PUBLIC_IPV4=$(curl -s http://whoami.org)'
  - 'echo Droplet: $(hostname), IP Address: $PUBLIC_IPV4 > /var/www/html/index.html'
