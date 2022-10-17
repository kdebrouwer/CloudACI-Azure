
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">3.1.0"
    }
    mso = {
      source = "CiscoDevNet/mso"
    }
  }
}

provider "mso" {
  username = var.creds.username
  password = var.creds.password
  url      = var.creds.url
  #domain   = var.creds.domain
  insecure = "true"
  platform = "nd"
}