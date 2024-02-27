resource "digitalocean_ssh_key" "default" {
  name       = "Terraform Example"
  public_key = tls_private_key.privatekey.public_key_openssh
}
