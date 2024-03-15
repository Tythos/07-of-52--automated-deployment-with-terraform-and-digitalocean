data "template_file" "cloudinit_yaml" {
  template = file("${path.module}/cloudinit.yaml.tpl")

  vars = {
    BUCKET_NAME = digitalocean_spaces_bucket.dobucket.name
    DO_REGION   = var.DO_REGION
    FILE_NAME   = digitalocean_spaces_bucket_object.dobucketarchiveobject.key
    HOST_NAME   = var.HOST_NAME
    ACME_EMAIL  = var.ACME_EMAIL
  }
}

data "template_file" "nginx_conf" {
  template = file("${path.module}/nginx.conf.tpl")

  vars = {
    HOST_NAME = var.HOST_NAME
  }
}
