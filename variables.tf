#  variables.tf defines the variables.  You will probably not need to modify this.
#  Unless a new cAPIC release has more added variables
#
# secret values are just defined here.  Please enter the actual values in overide.tf (or use env variables)
#variable "subscription_id" {}
#variable "client_id" {}
#variable "client_secret" {}
#variable "tenant_id" {}


# Variable definitions for Azure Cloud APIC Fabric based on template.json of ARM Template

variable "rgName" {
  default     = "CAPIC_april_vrf1_eastus"
  description = "resource group created by Terraform"
}

variable "vnetName" {
  default     = "vrf1"
  description = "vnet created by Terraform"
}


variable "location" {
  default     = "eastus"
  description = "East US"
}

variable "nsgName" {
  default = "nsg1"
}

variable "admin_username" {
  type    = string
  default = "cisco"
}

variable "admin_password" {
  type    = string
  default = "123Cisco123!"
}

variable "vmName" {
  type    = string
  default = "CloudAPIC"
}

variable "vmSize" {
  type    = string
  default = "size"
}

variable "imageSku" {
  type    = string
  default = "sku"
}

variable "imageVersion" {
  type    = string
  default = "some_value"
}

variable "adminUsername" {
  type    = string
  default = "some_value"
}

variable "fabricName" {
  type    = string
  default = "some_value"
}

variable "infraVNETPool" {
  type    = string
  default = "some_value"
}

variable "externalSubnets" {
  type    = string
  default = "some_value"
}

variable "publicIpDns" {
  type    = string
  default = "some_value"
}

variable "publicIPName" {
  type    = string
  default = "some_value"
}


variable "publicIPSku" {
  type    = string
  default = "some_value"
}

variable "publicIPAllocationMethod" {
  type    = string
  default = "some_value"
}

variable "publicIPNewOrExisting" {
  type    = string
  default = "some_value"
}

variable "publicIPResourceGroup" {
  type    = string
  default = "some_value"
}

variable "virtualNetworkName" {
  type    = string
  default = "some_value"
}

variable "mgmtNsgName" {
  type    = string
  default = "some_value"
}


variable "mgmtAsgName" {
  type    = string
  default = "some_value"
}

variable "subnetPrefix" {
  type    = string
  default = "some_value"
}

variable "_artifactsLocation" {
  type    = string
  default = "some_value"
}


variable "adminPasswordOrKey" {
  type    = string
  default = "some_value"
}

variable "adminPublicKey" {
  type    = string
  default = "some_value"
}



