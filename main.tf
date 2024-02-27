module "application" {
  source = "./application"
}

module "infrastruture" {
  source        = "./infrastructure"
  depends_on    = [module.application]
  DO_REGION     = var.DO_REGION
  DROPLET_SIZE  = var.DROPLET_SIZE
  DROPLET_IMAGE = var.DROPLET_IMAGE
}
