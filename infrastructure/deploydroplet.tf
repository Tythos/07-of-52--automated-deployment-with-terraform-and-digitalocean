resource "digitalocean_droplet" "deploydroplet" {
  image     = var.DROPLET_IMAGE
  name      = "deploydroplet"
  region    = var.DO_REGION
  size      = var.DROPLET_SIZE
  ssh_keys  = [digitalocean_ssh_key.sshkey.id]
  user_data = data.template_file.cloudinit_yaml.rendered
}
