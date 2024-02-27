data "template_file" "nginx_conf" {
  template = file("${path.module}/nginx.conf.tpl")

  vars = {
    HOST_NAME = var.HOST_NAME
  }
}

data "template_file" "setup_sh" {
  template = file("${path.module}/setup.sh.tpl")

  vars = {
    ACME_EMAIL = var.ACME_EMAIL
    HOST_NAME  = var.HOST_NAME
    DO_TOKEN   = var.DO_TOKEN
  }
}
