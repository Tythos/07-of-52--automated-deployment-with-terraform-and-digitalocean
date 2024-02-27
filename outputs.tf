output "SSH_KEY" {
  value     = module.infrastruture.SSH_KEY
  sensitive = true
}

output "PUBLIC_IP" {
  value = module.infrastruture.PUBLIC_IP
}
