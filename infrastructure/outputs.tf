output "SSH_KEY" {
  value     = tls_private_key.privatekey.private_key_pem
  sensitive = true
}

output "PUBLIC_IP" {
  value = digitalocean_droplet.dodroplet.ipv4_address
}
