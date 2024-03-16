module "application" {
  source = "./application"
}

module "infrastructure" {
  source        = "./infrastructure"
  depends_on    = [module.application]
  ACME_EMAIL    = var.ACME_EMAIL
  ARCHIVE_PATH  = module.application.ARCHIVE_PATH
  DO_REGION     = var.DO_REGION
  DROPLET_IMAGE = var.DROPLET_IMAGE
  DROPLET_SIZE  = var.DROPLET_SIZE
  HOST_NAME     = var.HOST_NAME
}
