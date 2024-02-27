resource "digitalocean_droplet" "deploydroplet" {
  image    = var.DROPLET_IMAGE
  name     = "deploydroplet"
  region   = var.DO_REGION
  size     = var.DROPLET_SIZE
  ssh_keys = [digitalocean_ssh_key.default.id]

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

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo mv /tmp/nginx.conf /etc/nginx/nginx.conf",
      "sudo systemctl restart nginx",
      "sudo cp -r /tmp/static/* /var/www/html" #,
      #"sudo chown -R nginx:nginx /var/www/html"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }
}
