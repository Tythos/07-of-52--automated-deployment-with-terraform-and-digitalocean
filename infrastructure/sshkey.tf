resource "digitalocean_ssh_key" "sshkey" {
  name       = "Terraform Example"
  public_key = tls_private_key.privatekey.public_key_openssh
}
