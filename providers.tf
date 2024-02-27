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
  }
}

provider "digitalocean" {
  token = var.DO_TOKEN
}

provider "tls" {
}

provider "archive" {
}
