resource "local_file" "setupsh" {
  content  = data.template_file.setup_sh.rendered
  filename = "${path.module}/setup.sh"
}
