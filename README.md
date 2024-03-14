# 07-of-52--automated-deployment-with-terraform-and-digitalocean

We've got some code, and we want to share it. Throw it up on a VM! Who has time for containerization, anyway?

In all seriousness, there are plenty of usecases in which you want to deploy a small application but don't need full-up orchestration. You *do*, however, need to automate as much of it as possible, because with smaller projects you simply don't have the bandwidth to manually calibrate specific configurations. And you don't want to host it yourself, or in a expensive cloud provider where you're going to get a surprise bill at the end of the month.

So. You need something modest, automation-friendly, and at just the right level of virtualization. You need Terraform and DigitalOcean.

## Provider and Project

Let's start with the basic provider configuration. The DigitalOcean provider docs for Terraform are first-class.

https://registry.terraform.io/providers/digitalocean/digitalocean/latest

We'll use a modular approach in which the top-level Terraform project has several subfolders for different units of code, which means the "entry point" is just a `main.tf` that defines how those different modules are integrated together. We'll focus on two modules in particular, an `application` module (that will define the static files we are deploying) and an `infrastructure`  module (that will define the resources used to serve our app). Create empty folders for both.

That means your top-level `main.tf` will start off looking something like this:

```tf
module "application" {
  source = "./application"
}

module "infrastructure" {
  source              = "./infrastructure"
  depends_on          = [module.application]
  DO_TOKEN            = var.DO_TOKEN
  DO_REGION           = var.DO_REGION
  DROPLET_SIZE        = var.DROPLET_SIZE
  DROPLET_IMAGE       = var.DROPLET_IMAGE
}
```

Next, let's create an `outputs.tf` (empty for now), and a `providers.tf`. We'll start with just the DigitalOcean provider, providing a hook to pass in our API token via the variable `DO_TOKEN` (more on that in a moment).

```tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }
  }
}

provider "digitalocean" {
  token = var.DO_TOKEN
}
```

We'll also be adding a few other very useful providers in a bit, but this is enough for now.

Lastly, we'll add a `variables.tf` at the top level to keep track of our inputs. We'll define all of these now so we can get them out of the way.

```tf
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
```

The descriptions should document each value for now. You can define them in a `.tfvars` file or via environmental variables (with the prefix `$TF_VAR_`) so they don't touch your disk (a good thing to avoid with sensitive values like your API token).

## Preliminary Infrastructure

Dive into your `infrastructure` folder and we'll start to piece a few things together.

First will be a `variables.tf` that accepts the inputs we defined for this module:

```tf
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
```

This will be enough for us to deploy a VM, or "droplet" as DigitalOcean calls them. Create a `deploydroplet.tf` file and 

```tf
resource "digitalocean_droplet" "deploydroplet" {
  image    = var.DROPLET_IMAGE
  name     = "deploydroplet"
  region   = var.DO_REGION
  size     = var.DROPLET_SIZE
}
```

Let's also definea  project, though, to "collect" our resources. Create a `doproject.tf` file and populate accordingly:

```tf
resource "digitalocean_project" "doproject" {
  name        = "doproject"
  description = "A project to represent development resources."
  purpose     = "Web Application"
  environment = "Development"

  resources = [
    digitalocean_droplet.deploydroplet.urn
  ]
}
```

This is enough to get us going! After you've defined your variables (with a quick glance at https://slugs.do-api.dev/ to see what the latest droplet sizes and deployment regions are), run a quick `terraform init` and `terraform apply`.

## Droplet with Auth

## Static File Deployment

## Securing with Certs
