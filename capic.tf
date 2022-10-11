# This is the main Terraform code 

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

# Azure Provider 
provider "azurerm" {
  features {
    template_deployment {
      delete_nested_items_during_deletion = false
    }
  }
}

# If not Subscribed to Clour Routers Catalyst-Edge-8000v, then subscribe to it
resource "azurerm_marketplace_agreement" "c8kv" {
  publisher = "cisco"
  offer     = "cisco-c8000v"
  plan      = try("17_07_01a-byol")
}

resource "azurerm_marketplace_agreement" "capic" {
  publisher = "cisco"
  offer     = "cisco-aci-cloud-apic-virtual"
  plan      = try("25_0_5-byol")
}


# Deploy a resource group
resource "azurerm_resource_group" "rgroup" {
  name     = var.rgName
  location = var.location
}


# Deploy cAPIC from ARM template
resource "azurerm_resource_group_template_deployment" "capic" {
  depends_on          = [azurerm_resource_group.rgroup]
  name                = var.vmName
  resource_group_name = var.rgName
  deployment_mode     = "Incremental"
  template_content    = file("template/template.json")
  parameters_content = jsonencode({
    adminPasswordOrKey       = { value = var.adminPasswordOrKey }
    adminPublicKey           = { value = var.adminPublicKey }
    location                 = { value = var.location }
    vmName                   = { value = var.vmName }
    vmSize                   = { value = var.vmSize }
    imageSku                 = { value = var.imageSku }
    imageVersion             = { value = var.imageVersion }
    adminUsername            = { value = var.adminUsername }
    fabricName               = { value = var.fabricName }
    infraVNETPool            = { value = var.infraVNETPool }
    externalSubnets          = { value = var.externalSubnets }
    publicIpDns              = { value = var.publicIpDns }
    publicIPName             = { value = var.publicIPName }
    publicIPSku              = { value = var.publicIPSku }
    publicIPAllocationMethod = { value = var.publicIPAllocationMethod }
    publicIPNewOrExisting    = { value = var.publicIPNewOrExisting }
    publicIPResourceGroup    = { value = var.publicIPResourceGroup }
    virtualNetworkName       = { value = var.virtualNetworkName }
    mgmtNsgName              = { value = var.mgmtNsgName }
    mgmtAsgName              = { value = var.mgmtAsgName }
    subnetPrefix             = { value = var.subnetPrefix }
    _artifactsLocation       = { value = var._artifactsLocation }

  })

}

# Azure subscription
data "azurerm_subscription" "primary" {
}

data "azurerm_virtual_machine" "capic" {
  depends_on          = [azurerm_resource_group_template_deployment.capic]
  name                = var.vmName
  resource_group_name = azurerm_resource_group.rgroup.name
}

# Assign Contributor role
resource "azurerm_role_assignment" "capic" {
  depends_on           = [azurerm_resource_group_template_deployment.capic]
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
  principal_id         = data.azurerm_virtual_machine.capic.identity.0.principal_id
}

output "capicPublicIP" {
  value = data.azurerm_virtual_machine.capic.public_ip_address
}