resource "random_string" "random" {
  length  = 8
  lower   = true
  upper   = false
  numeric = true
  special = true
}
