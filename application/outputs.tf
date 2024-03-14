output "ARCHIVE_PATH" {
  value = abspath(data.archive_file.staticarchive.output_path)
}
