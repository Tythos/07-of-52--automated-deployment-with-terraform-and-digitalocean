variable "DO_TOKEN" {
  type        = string
  description = "API token for DigitalOcean"
}

variable "DO_REGION" {
  type        = string
  description = "Region into which DigitalOcean resources will be deployed"
}

variable "DROPLET_IMAGE" {
  type        = string
  description = "DigitalOcean slug for VM system"
}

variable "DROPLET_SIZE" {
  type        = string
  description = "DigitalOcean slug for VM sizing"
}

variable "HOST_NAME" {
  type        = string
  description = "Domain name to register and automate with DigitalOcean"
}

variable "ACME_EMAIL" {
  type        = string
  description = "Contact email for cert challenges and renewal notice"
}

variable "ARCHIVE_PATH" {
  type        = string
  description = "Path to the archived bundle of static files to copy into the VM"
}
