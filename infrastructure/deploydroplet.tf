resource "digitalocean_droplet" "deploydroplet" {
  image    = var.DROPLET_IMAGE
  name     = "deploydroplet"
  region   = var.DO_REGION
  size     = var.DROPLET_SIZE
  ssh_keys = [digitalocean_ssh_key.sshkey.id]

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y ansible",
      "scp -o StrictHostKeyChecking=no -i /path/to/ssh/key ${path.module}/ansible/playbook.yml root@${self.ipv4_address}:/tmp/playbook.yml",  # Copy playbook to remote VM
      "ansible-playbook ansibleplaybook.yaml -vvv"
    ]

    connection {
      type        = "ssh"
      host        = self.ipv4_address
      user        = "root"
      private_key = file(tls_private_key.privatekey.private_key_openssh)
    }
  }
}
