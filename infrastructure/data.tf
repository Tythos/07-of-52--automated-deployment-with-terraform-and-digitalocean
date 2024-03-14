data "template_file" "cloudinit_yaml" {
  template = file("${path.module}/cloudinit.yaml.tpl")
  vars = {}
}
