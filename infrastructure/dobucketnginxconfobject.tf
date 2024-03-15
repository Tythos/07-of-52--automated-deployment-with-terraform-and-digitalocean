resource "digitalocean_spaces_bucket_object" "dobucketnginxconfobject" {
  region  = var.DO_REGION
  bucket  = digitalocean_spaces_bucket.dobucket.name
  key     = "nginx.conf"
  acl     = "public-read"
  content = data.template_file.nginx_conf.rendered
}
