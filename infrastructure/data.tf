data "template_file" "cloudinit_yaml" {
  template = file("${path.module}/cloudinit.yaml.tpl")

  vars = {
    BUCKET_NAME = digitalocean_spaces_bucket.dobucket.name
    DO_REGION   = var.DO_REGION
    FILE_NAME   = digitalocean_spaces_bucket_object.dobucketobject.key
  }
}
