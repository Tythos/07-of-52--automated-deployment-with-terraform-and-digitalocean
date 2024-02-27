data "template_file" "nginx_conf" {
  template = file("${path.module}/nginx.conf.tpl")

  vars = {
    HOST_NAME = var.HOST_NAME
  }
}
