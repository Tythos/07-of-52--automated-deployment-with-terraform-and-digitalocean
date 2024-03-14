resource "digitalocean_droplet" "dodroplet" {
  image      = var.DROPLET_IMAGE
  name       = "dodroplet"
  region     = var.DO_REGION
  size       = var.DROPLET_SIZE
  ssh_keys   = [digitalocean_ssh_key.sshkey.id]
  user_data  = data.template_file.cloudinit_yaml.rendered
  depends_on = [digitalocean_spaces_bucket_object.dobucketobject]
}
