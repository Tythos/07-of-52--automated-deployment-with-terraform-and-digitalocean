resource "digitalocean_spaces_bucket" "dobucket" {
  name   = "myaweseomespacesbucketondigitalocean"
  region = var.DO_REGION
}
