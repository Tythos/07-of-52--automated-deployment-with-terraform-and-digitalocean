resource "digitalocean_droplet" "deploydroplet" {
  image    = var.DROPLET_IMAGE
  name     = "deploydroplet"
  region   = var.DO_REGION
  size     = var.DROPLET_SIZE
  ssh_keys = [digitalocean_ssh_key.sshkey.id]

  provisioner "file" {
    source      = "${path.module}/nginx.conf"
    destination = "/tmp/nginx.conf"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }

  provisioner "file" {
    source      = var.STATIC_ARCHIVE_PATH
    destination = "/tmp/static.zip"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx unzip certbot python3-certbot-nginx",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo unzip -o /tmp/static.zip -d /var/www/html",
      "sudo certbot certonly --dns-digitalocean --dns-digitalocean-credentials ~/.secrets/certbot/digitalocean.ini -d ${var.HOST_NAME}",
      "sudo systemctl restart nginx",
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }
}
