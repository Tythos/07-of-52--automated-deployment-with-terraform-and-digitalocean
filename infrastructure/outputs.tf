output "SSH_KEY" {
  value     = tls_private_key.privatekey.private_key_pem
  sensitive = true
}

output "PUBLIC_IP" {
  value = digitalocean_droplet.deploydroplet.ipv4_address
}

output "DROPLET_URN" {
  value = digitalocean_droplet.deploydroplet.urn
}
