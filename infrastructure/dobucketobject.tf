resource "digitalocean_spaces_bucket_object" "dobucketobject" {
  region = var.DO_REGION
  bucket = digitalocean_spaces_bucket.dobucket.name
  key    = "static.zip"
  source = var.ARCHIVE_PATH
  acl    = "public-read"
}
