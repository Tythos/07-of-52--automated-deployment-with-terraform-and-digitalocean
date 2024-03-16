terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
    }

    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }

    template = {
      source  = "hashicorp/template"
      version = "2.2.0"
    }
  }
}

provider "digitalocean" {
  token             = var.DO_TOKEN
  spaces_access_id  = var.DO_SPACES_ID
  spaces_secret_key = var.DO_SPACES_KEY
}

provider "tls" {
}

provider "archive" {
}

provider "template" {
}
