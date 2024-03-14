resource "digitalocean_volume" "dovolume" {
  # will be mounted under /mnt/dovolume
  region                   = var.DO_REGION
  name                     = "dovolume"
  size                     = 100
  initial_filesystem_type  = "ext4"
  initial_filesystem_label = "dovolume"
  description              = "Static file volume for VM-mounted nginx host"
}
