resource "digitalocean_project" "infrastructureproject" {
  name        = "infrastructureproject"
  description = "A project to represent development resources."
  purpose     = "Web Application"
  environment = "Development"

  resources = [
    digitalocean_droplet.deploydroplet.urn
  ]
}
