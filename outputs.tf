output "SSH_KEY" {
  value     = module.infrastructure.SSH_KEY
  sensitive = true
}

output "PUBLIC_IP" {
  value = module.infrastructure.PUBLIC_IP
}
