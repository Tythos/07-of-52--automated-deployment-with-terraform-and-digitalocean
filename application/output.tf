output "DO_VOLUME_ID" {
  value = digitalocean_volume.staticvolume.id
}

output "VOLUME_URN" {
  value = digitalocean_volume.staticvolume.urn
}
