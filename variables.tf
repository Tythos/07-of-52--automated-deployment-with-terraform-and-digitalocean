variable "DO_TOKEN" {
  type        = string
  description = "API token for DigitalOcean"
}

variable "DO_SPACES_ID" {
  type        = string
  description = "Identifies DigitalOcean Spaces identifier for bucket object storage API"
}

variable "DO_SPACES_KEY" {
  type        = string
  description = "Defines private key for DigitalOcean Spaces bucket object storage API"
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
