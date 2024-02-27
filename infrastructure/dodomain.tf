resource "digitalocean_domain" "dodomain" {
  name       = var.HOST_NAME
  ip_address = digitalocean_droplet.deploydroplet.ipv4_address
}
