# 07-of-52--automated-deployment-with-terraform-and-digitalocean

We've got some code, and we want to share it. Throw it up on a VM! Who has time for containerization, anyway?

In all seriousness, there are plenty of usecases in which you want to deploy a small application but don't need full-up orchestration. You *do*, however, need to automate as much of it as possible, because with smaller projects you simply don't have the bandwidth to manually calibrate specific configurations. And you don't want to host it yourself, or in a expensive cloud provider where you're going to get a surprise bill at the end of the month.

So. You need something modest, automation-friendly, and at just the right level of virtualization. You need Terraform and DigitalOcean.

## Provider and Project

Let's start with the basic provider configuration. The DigitalOcean provider docs for Terraform are first-class.

https://registry.terraform.io/providers/digitalocean/digitalocean/latest

First, let's create a top-level `.gitignore` that makes sure none of our sensitive artifacts are checked into version control. It should have the following contents:

```
.terraform/
.terraform.lock.hcl
.terraform.tfstate.lock.info
terraform.tfvars
terraform.tfstate
terraform.tfstate.backup
id_rsa
```

We'll use a modular approach in which the top-level Terraform project has several subfolders for different units of code, which means the "entry point" is just a `main.tf` that defines how those different modules are integrated together. We'll focus on two modules in particular, an `application` module (that will define the static files we are deploying) and an `infrastructure`  module (that will define the resources used to serve our app). Create empty folders for both.

That means your top-level `main.tf` will start off looking something like this (don't worry too much about the variables, we'll break them out later):

```tf
module "application" {
  source = "./application"
}

module "infrastructure" {
  source        = "./infrastructure"
  depends_on    = [module.application]
  ACME_EMAIL    = var.ACME_EMAIL
  ARCHIVE_PATH  = module.application.ARCHIVE_PATH
  DO_REGION     = var.DO_REGION
  DO_TOKEN      = var.DO_TOKEN
  DROPLET_IMAGE = var.DROPLET_IMAGE
  DROPLET_SIZE  = var.DROPLET_SIZE
  HOST_NAME     = var.HOST_NAME
}
```

Next, let's create a `providers.tf`. We'll start with the DigitalOcean provider, providing a hook to pass in our API tokens (for both DigitalOcean cloud services and object storage) via the variables `DO_TOKEN`, `DO_SPACES_ID`, and `DO_SPACES_KEY`. We'll also be using the built-in providers `tls`, `archive`, and `template`, which do not require any particular configuration.

```tf
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
```

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

## Static Application

Let's start with the `application` module (subfolder). Assume we have a set of static files, which define our application. Our objective is to deploy these files into the server that will be the focus of our infrastructure. Create a new folder, `application/static`, and add the following three files (they can be blank for now, or you can populate them with placeholder content, but at the very least the HTML file should reference the CSS and JS files via `<link/>` and `<script/>` tags).

* `index.html`

* `index.css`

* `index.js`

We now have a specific "starting point" for our infrastructure. Our objective is to automatically and securely host this content on a cloud-deployed web server. We're going to start by aggregating these into a single archive file, but we don't want this to be version-controlled (it is both a binary and an interim artifact, after all), so within the `application` folder, create a `.gitignore` and add the following contents:

```
*.zip
```

We'll use the built-in `archive_file` resource in Terraform to define this archive, which will be generated as part of the `apply` process. This resource should be a `.ZIP` file that captures the contents of our `application/static` folder and store it in `application/static.zip`. Add an `application/data.tf` file with the following resource:

```tf
data "archive_file" "staticarchive" {
  type        = "zip"
  source_dir  = "${path.module}/static"
  output_path = "${path.module}/static.zip"
}
```

From this module, we will "export" the path to this archive so it can be uploaded to our infrastructure. Effectively, this means defining and exporting the path to that `.ZIP` file. Create an `application/outputs.tf` file and add the following, which automatically exposes this path as a module output:

```tf
output "ARCHIVE_PATH" {
  value = abspath(data.archive_file.staticarchive.output_path)
}
```

That's actually it for our `application` module. You can even run `terraform apply` before you add anything else (if you disable the `infrastructure` module first) to see it execute. It doesn't take a lot of imagination to picture how these static contents could come from a packing tool (like Webpack, Vite, Browserify, or others) that generates your static assets from a more complicated codebase--perhaps even hooking that project in as a submodule.

## Preliminary Infrastructure (Pre-Droplet)

There's a lot of resources we'll need to set up within our `infrastructure` folder before we can deploy our VM (or "Droplet" as DigitalOcean calls it). First, let's define the variables this module will need. You may recall these were already referenced in our top-level Terraform, but let's add these to `infrastructure/variables.tf` now:

```tf
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
```

The description of each variable should document for you what, exactly, these variables will be used for. We'll also need to indicate to Terraform that this module too requires a DigitalOcean provider so it can be resolved correctly, so create an `infrastructure/providers.tf` file and add the following:

```tf
terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "2.34.1"
    }
  }
}
```

Next, let's create our templates. There are two static files we need to generate from templates before they can be used when our Droplet is deployed. First, we will need to create `infrastruture/cloudinit.yaml.tpl`, which will be used to generate our `cloud-init` configuration. The template file should look something like this:

```yaml
#cloud-config
packages:
  - nginx
  - unzip
  - software-properties-common
  - ufw
runcmd:
  - ufw --force enable
  - ufw allow 'OpenSSH'
  - ufw allow 'Nginx Full'
  - add-apt-repository -y ppa:certbot/certbot
  - apt-get update
  - apt-get install -y certbot python3-certbot-nginx
  - curl -o /tmp/static.zip https://${BUCKET_NAME}.${DO_REGION}.digitaloceanspaces.com/${FILE_NAME}
  - unzip -o /tmp/static.zip -d /var/www/html
  - curl -o /etc/nginx/nginx.conf https://${BUCKET_NAME}.${DO_REGION}.digitaloceanspaces.com/nginx.conf
  - certbot --nginx -d ${HOST_NAME} -n -m ${ACME_EMAIL} --agree-tos
```

What's going on here?

1. There are specific packages we want to make sure are installed

1. The `ufw` commands configure the VM's firewall

1. We add the secure certbot repository and install the corresponding packages

1. We fetch the static archive from where we will (eventually) upload it via a Spaces bucket; the contents are then extracted to the default path where Nginx looks for static files

1. We fetch the Nginx configuration (also eventually uploaded to a Spaces bucket), using it to override the default configuration

1. Lastly, we run certbot (automated) to register TLS certificates for our server host; using the `--nginx` flag indicates it will look for, and update, our Nginx configuration automatically

The contents of this `cloud-init` configuration will be passed in as userdata during our VM creation. This configuration is used to define a particular specification for our VM using the `cloud-init` standard. The `cloud-init` standard is a very useful practice; you can learn more here:

https://cloudinit.readthedocs.io/en/latest/index.html

The other template we'll need to define is our Nginx configuration. Create a `infrastructure/nginx.conf.tpl` file and populate it with the following:

```conf
worker_processes 1;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name ${HOST_NAME};
        root /var/www/html;
        index index.htm index.html;

        location / {
            try_files $uri $uri/ =404;
        }
    }
}
```

If you're not familiar with Nginx configuration, this basically says:

1. Our server will operate on single process supporting 1024 concurrent connections

1. It will serve HTTP traffic, using default MIME types (and falling back to octet streams)

1. Nginx will host a single server on (initially) port 80 for the desired host

1. It will look for static file content under `/var/www/html` and alias `index` and `index.htm` requests to the `index.html` page by default

1. It will serve a 404 page if static file content is not found

Lastly, we need to define the Terraform template file resources so these templates will be rendered and exposed for reference by other elements of our infrastructure. Create an `infrastructure/data.tf` file and populate like so:

```tf
data "template_file" "cloudinit_yaml" {
  template = file("${path.module}/cloudinit.yaml.tpl")

  vars = {
    BUCKET_NAME = digitalocean_spaces_bucket.dobucket.name
    DO_REGION   = var.DO_REGION
    FILE_NAME   = digitalocean_spaces_bucket_object.dobucketarchiveobject.key
    HOST_NAME   = var.HOST_NAME
    ACME_EMAIL  = var.ACME_EMAIL
  }
}

data "template_file" "nginx_conf" {
  template = file("${path.module}/nginx.conf.tpl")

  vars = {
    HOST_NAME = var.HOST_NAME
  }
}
```

Most of this is self-explanatory, but there's a key missing piece: We haven't defined a bucket to which our static assets will be uploaded yet. Let's do that now.

> IMPORTANT: Make sure, in addition to having a DigitalOcean API token, you have also registered specific Spaces credentials; these are *NOT* the same thing!

Create a `infrastructure/dobucket.tf` resource and give it a unique name:

```tf
resource "digitalocean_spaces_bucket" "dobucket" {
  name   = "myaweseomespacesbucketondigitalocean"
  region = var.DO_REGION
}
```

Then, define the two specific object resources that will be uploaded to this bucket. First, do the archive. Create an `infrastructure/dobucketarchiveobject.tf` file and populate accordingly:

```tf
resource "digitalocean_spaces_bucket_object" "dobucketarchiveobject" {
  region = var.DO_REGION
  bucket = digitalocean_spaces_bucket.dobucket.name
  key    = "static.zip"
  source = var.ARCHIVE_PATH
  acl    = "public-read"
}
```

This is an interesting trick. By deploying this resource, we effectively upload our static content to a cloud-hosted address where our VM will be able to "pull" it during image setup. This effectively circumvents automated configuration tools like Puppet, Ansible, Chef, etc. (though you can still use these if you want to!). Consolidating these steps via `cloud-init` means nicely encapsulate all of our system configuration information within Terraform itself, which means we can add all the procedural bindings between resources we need (or want) to make life easier.

Next, let's do the Nginx configuration. Create an `infrastructure/dobucketnginxconfobject.tf` file (feel free to come up with a better name, ha ha!). It should look like this:

```tf
resource "digitalocean_spaces_bucket_object" "dobucketnginxconfobject" {
  region  = var.DO_REGION
  bucket  = digitalocean_spaces_bucket.dobucket.name
  key     = "nginx.conf"
  acl     = "public-read"
  content = data.template_file.nginx_conf.rendered
}
```

We only have one more step before we deploy our VM. It could use an SSH key to automate credentials we use for logging in remotely and debugging (or just verifying) our VM configuration. This is a two-step process: first, we'll create a private key using the built-in Terraform `tls` provider; then, we'll use this secret to define a public key used when our VM is created.

So first, create an `infrastructure/privatekey.tf` file and populate with a `tls_private_key` resource:

```tf
resource "tls_private_key" "privatekey" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
```

Then, create an `infrastructure/sshkey.tf` file that includes a `digitalocean_ssh_key` resource:

```tf
resource "digitalocean_ssh_key" "sshkey" {
  name       = "Terraform-defined SSH key"
  public_key = tls_private_key.privatekey.public_key_openssh
}
```

Take a break, you've earned it! You can deploy these resources if you want to verify them. But next, we'll do the actual VM!

## Infrastructure (Droplet)

DigitalOcean calls their VMs "Droplets". We're ready to create our Droplet resource, which will combine a lot of the resources we've written so far.

Create an `infrastructure/dodroplet.tf` file; this is pretty dense, so populate it like so then we'll explain what's going on:

```tf
resource "digitalocean_droplet" "dodroplet" {
  image     = var.DROPLET_IMAGE
  name      = "dodroplet"
  region    = var.DO_REGION
  size      = var.DROPLET_SIZE
  ssh_keys  = [digitalocean_ssh_key.sshkey.id]
  user_data = data.template_file.cloudinit_yaml.rendered
  depends_on = [
    digitalocean_spaces_bucket_object.dobucketarchiveobject,
    digitalocean_spaces_bucket_object.dobucketnginxconfobject
  ]
}
```

What's going into this resource?

1. We use the `image` property to define what distribution will be installed on our VM. (I like using `ubuntu-23-10-x64`, which is fully-featured but with a slightly smaller footprint, but feel free to look up https://slugs.do-api.dev/ to see what other options exist.)

1. We use the `region` property to make sure all of our resources are deployed to the same DigitalOcean region.

1. We use the `size` property to define the computational resources (CPUs, RAM) the VM will be created with. (I like using `s-4vcpu-8gb`, which is big enough to not struggle with application resource loads but small enough to be quite affordable on a month-to-month basis, at about $1.71 each day.)

1. We use the `ssh-Keys` property to pass in a reference to the `digitalocean_ssh_key` resource we already defined.

1. We use the `user_data` property to pass the contents of our `cloud-init` configuration, rendered from template.

1. We explicitly flag a dependency on the objects in our Spaces bucket to make sure they have been uploaded before our VM spins up; since these dependencies are otherwise implicit, Terraform needs a little help understanding the relationship.

## Infrastructure (Post-Droplet)

Once the VM is created, we have a resource with a specific address and a specific key. This is enough to depoy our remaining resources, but let's SSH in just to poke around a bit. To do so, we'll need to export the SSH key and public IP address--first from the module, then from the top level. Create an `infrastructure/outputs.tf` file that does so:

```tf
output "SSH_KEY" {
  value     = tls_private_key.privatekey.private_key_pem
  sensitive = true
}

output "PUBLIC_IP" {
  value = digitalocean_droplet.dodroplet.ipv4_address
}
```

The SSH key is the PEM value of our `tls_private_key` (*VERY* convenient trick, by the way!). The IP comes from the droplet address. Now, create a top-level `outputs.tf` file to forward these outputs.

```tf
output "SSH_KEY" {
  value     = module.infrastructure.SSH_KEY
  sensitive = true
}

output "PUBLIC_IP" {
  value = module.infrastructure.PUBLIC_IP
}
```

Now you can do the following:

```sh
$ terraform apply
$ terraform output -raw SSH_KEY > id_rsa
$ set PUBLIC_IP=$(terraform output PUBLIC_IP)
$ ssh -i id_rsa root@$PUBLIC_IP
```

I've conveniently added `id_rsa` to the `.gitignore` we initially defined, specifically for this usecase. Being able to SSH in isn't technically required to deploy our application but I find it's very help when you're learning (not to mention verifying and debugging) to be able to log in and "poke around" the system.

We're almost done. We still need to host our domain at the VM address (if you haven't done so already, failing to do so will cause issues with the `certbot` execution), and it would be convenient to organize our DigitalOcean resources into a "Project" (basically, a DigitalOcean namespace). So, first create an `infrastructure/dodomain.tf` resource that registers A records for our host name using the IP from our VM:

```tf
resource "digitalocean_domain" "dodomain" {
  name       = var.HOST_NAME
  ip_address = digitalocean_droplet.dodroplet.ipv4_address
}
```

Second, create an `infrastructure/doproject.tf` resource that lists our relevant DO resources:

```tf
resource "digitalocean_project" "doproject" {
  name        = "doproject"
  description = "A project to represent development resources."
  purpose     = "Web Application"
  environment = "Development"

  resources = [
    digitalocean_droplet.dodroplet.urn,
    digitalocean_domain.dodomain.urn,
    digitalocean_spaces_bucket.dobucket.urn
  ]
}
```

This is mostly housekeeping, but it's very *easy* and *convenient* housekeeping--the best kind!

## Wrapping It Up

If you haven't already, run `terraform apply` and witness the beauty. You should be able to access a secure static-file application at your address--but if it doesn't happen right away, don't get frustrated. There are a few things to be careful of:

1. `cloud-init` can take a while to run, especially since it's installing a number of system packages; SSH into the VM and run `ps -e | grep cloud` to see if the process is still active.

1. We deliberately configured our firewall to allow only HTTPS traffic. Adjust the corresponding `ufw` commands in your `cloud-init` configuration if you need to debug the Nginx server (along with adjusting your `nginx.conf`). This is doubly-true if you need to test (insecure) HTTP traffic, whether there's an issue with Nginx or with the `certbot` execution.

1. Useful logs include `/var/log/cloud-init.log`, to inspect what is happening during the initial VM configuration, and `/var/log/nginx/*.log` (there are several) if you are debugging Nginx itself.

1. You can always pull the static archive and Nginx configuration directly from the corresponding Spaces bucket objects to verify they are being generated and uploaded correctly.

1. Most of the `cloud-init` configuration is comprised of specific commands that (once you SSH in) can easily be replicated in your own shell for testing purposes.

Once you've got it working, congratulations! You have a neatly self-contained, fully-automated infrastrucutre for remotely deploying any static file web application you ever write--and all without ever touching Docker or Kubernetes.
