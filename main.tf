module "application" {
  source = "./application"
}

module "infrastruture" {
  source              = "./infrastructure"
  depends_on          = [module.application]
  DO_REGION           = var.DO_REGION
  DROPLET_SIZE        = var.DROPLET_SIZE
  DROPLET_IMAGE       = var.DROPLET_IMAGE
  STATIC_ARCHIVE_PATH = module.application.STATIC_ARCHIVE_PATH
  HOST_NAME           = var.HOST_NAME
}
