resource "digitalocean_project" "doproject" {
  name        = "doproject"
  description = "A project to represent development resources."
  purpose     = "Web Application"
  environment = "Development"

  resources = [
    digitalocean_droplet.deploydroplet.urn,
    digitalocean_domain.dodomain.urn,
    digitalocean_volume.dovolume.urn
  ]
}
