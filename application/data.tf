data "archive_file" "staticarchive" {
  type        = "zip"
  source_dir  = "${path.module}/static"
  output_path = "${path.module}/static.zip"
}
