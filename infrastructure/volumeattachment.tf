resource "digitalocean_volume_attachment" "volumeattachment" {
    droplet_id = digitalocean_droplet.deploydroplet.id
    volume_id = var.DO_VOLUME_ID
}