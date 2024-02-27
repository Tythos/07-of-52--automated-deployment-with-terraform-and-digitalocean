module "infrastruture" {
  source        = "./infrastructure"
  DO_REGION     = var.DO_REGION
  DROPLET_SIZE  = var.DROPLET_SIZE
  DROPLET_IMAGE = var.DROPLET_IMAGE
}
