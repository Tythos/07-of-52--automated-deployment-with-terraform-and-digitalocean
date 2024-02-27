resource "null_resource" "staticcopy" {
  provisioner "file" {
    source      = "${path.module}/static"
    destination = "/tmp/static"
  }
}
