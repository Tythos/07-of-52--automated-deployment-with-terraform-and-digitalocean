resource "digitalocean_volume" "staticvolume" {
  region                  = var.DO_REGION
  name                    = "staticvolume"
  size                    = 100
  initial_filesystem_type = "ext4"
  description             = "Static volume for hosting public server content"
}
