resource "local_file" "nginxconf" {
  content  = data.template_file.nginx_conf.rendered
  filename = "${path.module}/nginx.conf"
}
