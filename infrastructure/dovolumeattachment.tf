resource "digitalocean_volume_attachment" "dovolumeattachment" {
  droplet_id = digitalocean_droplet.deploydroplet.id
  volume_id  = digitalocean_volume.dovolume.id
}
