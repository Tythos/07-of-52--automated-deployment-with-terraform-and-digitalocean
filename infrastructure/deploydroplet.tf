resource "digitalocean_droplet" "deploydroplet" {
  image    = var.DROPLET_IMAGE
  name     = "deploydroplet"
  region   = var.DO_REGION
  size     = var.DROPLET_SIZE
  ssh_keys = [digitalocean_ssh_key.sshkey.id]

  provisioner "file" {
    source      = local_file.nginxconf.filename
    destination = "/tmp/nginx.conf"

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }

  provisioner "file" {
    source      = local_file.setupsh.filename
    destination = "/tmp/setup.sh"

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
      # "ls -al /tmp",
      "chmod +x /tmp/setup.sh",
      "echo Running setup script...",
      "bash /tmp/setup.sh"
    ]

    connection {
      type        = "ssh"
      user        = "root"
      private_key = tls_private_key.privatekey.private_key_pem
      host        = self.ipv4_address
    }
  }
}
