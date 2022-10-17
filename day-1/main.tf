#  Define data sources

data "mso_site" "azure_site" {
  name = var.azure_site_name
}

data "mso_site" "onprem_site" {
  name = var.onprem_site_name
}


#  Define your terraform script here   put in file main.tf

## create the tenant

resource "mso_tenant" "tenant" {
  name         = var.tenant.tenant_name
  display_name = var.tenant.display_name
  description  = var.tenant.description
  site_associations {
    site_id           = data.mso_site.azure_site.id
    vendor            = "azure"
    azure_subscription_id  = var.azure.azure_subscription_id
    azure_access_type      = "shared"
    azure_shared_account_id = var.azure.azure_subscription_id
  }
  site_associations {
    site_id           = data.mso_site.onprem_site.id
  }
}

## create schema

resource "mso_schema" "schema1" {
  name          = var.schema_name
  template {
    name = var.template_name
    display_name = var.template_name
    tenant_id     = mso_tenant.tenant.id
  }
}

## Associate Schema / template with Site

resource "mso_schema_site" "azure_site" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema.schema1.template.*.name[0]
}

resource "mso_schema_site" "onprem_site" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.onprem_site.id
  template_name = mso_schema.schema1.template.*.name[0]
}


## Create VRF

resource "mso_schema_template_vrf" "vrf1" {
  schema_id        = mso_schema.schema1.id
  template         = mso_schema.schema1.template.*.name[0]
  name             = var.vrf_name
  display_name     = var.vrf_name
  layer3_multicast = false
  vzany            = false
}

resource "mso_schema_site_vrf" "azure_site" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
  vrf_name      = mso_schema_template_vrf.vrf1.name
}

## associate with Region and zones in Site Local Templates

resource "mso_schema_site_vrf_region" "azure_region" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema_site.azure_site.template_name
  site_id            = data.mso_site.azure_site.id
  vrf_name           = mso_schema_site_vrf.azure_site.vrf_name
  region_name        = var.region_name
  vpn_gateway        = false
  hub_network_enable = true #This enables VNet Peering to Infra/Hub VNet
  hub_network = {
    name        = "default"
    tenant_name = "infra"
  }
  cidr {
    cidr_ip = var.cidr_ip
    primary = true

    subnet {
      ip    = var.subnet1
    }
  }
}
resource "mso_schema_site_vrf" "onprem_site" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.onprem_site.template_name
  site_id       = data.mso_site.onprem_site.id
  vrf_name      = mso_schema_template_vrf.vrf1.name
}

# creat BD 

resource "mso_schema_template_bd" "bd1" {
    schema_id              = mso_schema.schema1.id
    template_name          = mso_schema.schema1.template.*.name[0]
    name                   = var.bd_name
    display_name           = var.bd_name
    vrf_name               = var.vrf_name
    layer2_unknown_unicast = "proxy" 
}

resource "mso_schema_template_bd_subnet" "bd1_subnet" {
  schema_id = mso_schema.schema1.id
  template_name = mso_schema.schema1.template.*.name[0]
  bd_name = mso_schema_template_bd.bd1.name
  ip = var.bd_subnet
  scope = "public"
  shared = false
}



## create ANP

resource "mso_schema_template_anp" "anp1" {
  schema_id    = mso_schema.schema1.id
  template     = mso_schema.schema1.template.*.name[0]
  name         = var.anp_name
  display_name = var.anp_name
}


resource "mso_schema_site_anp" "azure_anp" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.anp1.name
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
}

resource "mso_schema_site_anp" "onprem_anp" {
  schema_id     = mso_schema.schema1.id
  anp_name      = mso_schema_template_anp.anp1.name
  template_name = mso_schema_site.onprem_site.template_name
  site_id       = data.mso_site.onprem_site.id
}

## create EPG

resource "mso_schema_template_anp_epg" "anp_epg" {
  schema_id                  = mso_schema.schema1.id
  template_name              = mso_schema.schema1.template.*.name[0]
  anp_name                   = mso_schema_template_anp.anp1.name
  name                       = var.epg_name
  bd_name                    = var.bd_name
  vrf_name                   = mso_schema_template_vrf.vrf1.name
  display_name               = var.epg_name
  useg_epg                   = false
  intra_epg                  = "unenforced"
  intersite_multicast_source = false
  preferred_group            = false
}

resource "mso_schema_site_anp_epg" "azure_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.azure_site.template_name
  site_id       = data.mso_site.azure_site.id
  anp_name      = mso_schema_site_anp.azure_anp.anp_name
  epg_name      = mso_schema_template_anp_epg.anp_epg.name
}

resource "mso_schema_site_anp_epg" "onprem_epg" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema_site.onprem_site.template_name
  site_id       = data.mso_site.onprem_site.id
  anp_name      = mso_schema_site_anp.onprem_anp.anp_name
  epg_name      = mso_schema_template_anp_epg.anp_epg.name
}

### define VMM Domain for onprem
resource "mso_schema_site_anp_epg_domain" "onprem_epg_vmm_domain" {
  schema_id            = mso_schema.schema1.id
  template_name        = mso_schema_site.onprem_site.template_name
  site_id              = data.mso_site.onprem_site.id
  anp_name             = mso_schema_site_anp.onprem_anp.anp_name
  epg_name             = mso_schema_template_anp_epg.anp_epg.name
  domain_type          = "vmmDomain"
  vmm_domain_type      = "VMware"
  domain_name          = var.vmm_name
  deploy_immediacy     = "immediate"
  resolution_immediacy = "immediate"
}

### define epg selector

resource "mso_schema_site_anp_epg_selector" "epgSel1" {
  schema_id     = mso_schema.schema1.id
  site_id       = data.mso_site.azure_site.id
  template_name = mso_schema_site.azure_site.template_name
  anp_name      = mso_schema_site_anp_epg.azure_epg.anp_name
  epg_name      = mso_schema_site_anp_epg.azure_epg.epg_name
  name          = "epgSel1"
  expressions {
    key      = "ipAddress"
    operator = "equals"
    value    = var.epg_selector_value
  }
}


# Create Filters and Contracts

## create Filter
resource "mso_schema_template_filter_entry" "filter_entry" {
  schema_id          = mso_schema.schema1.id
  template_name      = mso_schema.schema1.template.*.name[0]
  name               = "any"
  display_name       = "any"
  entry_name         = "any"
  entry_display_name = "any"
  destination_from   = "unspecified"
  destination_to     = "unspecified"
  source_from        = "unspecified"
  source_to          = "unspecified"
  arp_flag           = "unspecified"
}


## Create Contract
resource "mso_schema_template_contract" "template_contract" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema.schema1.template.*.name[0]
  contract_name = "permit_any"
  display_name  = "permit_any"
  scope         = "context"
  directives    = ["none"]
}

### Associate filter with Contract
resource "mso_schema_template_contract_filter" "Any" {
  schema_id     = mso_schema_template_contract.template_contract.schema_id
  template_name = mso_schema_template_contract.template_contract.template_name
  contract_name = mso_schema_template_contract.template_contract.contract_name # "C1"
  filter_type   = "bothWay"
  filter_name   = "Any"
  directives    = ["none", "log"]
}

#### add Contract Provider and Consumer to EPg
resource "mso_schema_template_anp_epg_contract" "c1_epg_provider" {
  schema_id         = mso_schema_template_contract_filter.Any.schema_id
  template_name     = mso_schema_template_contract_filter.Any.template_name
  anp_name          = mso_schema_site_anp.onprem_anp.anp_name
  epg_name          = mso_schema_site_anp_epg.onprem_epg.epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "provider"

}


resource "mso_schema_template_anp_epg_contract" "c1_epg_consumer" {
  schema_id         = mso_schema_template_anp_epg_contract.c1_epg_provider.schema_id
  template_name     = mso_schema_template_anp_epg_contract.c1_epg_provider.template_name
  anp_name          = mso_schema_site_anp.azure_anp.anp_name
  epg_name          = mso_schema_site_anp_epg.azure_epg.epg_name
  contract_name     = mso_schema_template_contract.template_contract.contract_name
  relationship_type = "consumer"

}


### Deploy Template:
resource "mso_schema_template_deploy" "template_deployer" {
  schema_id     = mso_schema.schema1.id
  template_name = mso_schema.schema1.template.*.name[0]
  depends_on = [
    mso_tenant.tenant,
    mso_schema.schema1,
    mso_schema_site.azure_site,
    mso_schema_site.onprem_site,
    mso_schema_template_vrf.vrf1,
    mso_schema_site_vrf.azure_site,
    mso_schema_site_vrf_region.azure_region,
    mso_schema_template_bd.bd1,
    mso_schema_template_bd_subnet.bd1_subnet,
    mso_schema_template_anp.anp1,
    mso_schema_template_anp_epg.anp_epg,
    mso_schema_site_anp_epg.azure_epg,
    mso_schema_site_anp_epg.onprem_epg,
    mso_schema_site_anp_epg_domain.onprem_epg_vmm_domain,
    mso_schema_site_anp_epg_selector.epgSel1,
    mso_schema_template_filter_entry.filter_entry,
    mso_schema_template_contract.template_contract,
    mso_schema_template_contract_filter.Any,
    mso_schema_template_anp_epg_contract.c1_epg_provider,
    mso_schema_template_anp_epg_contract.c1_epg_consumer,
  ]
  #undeploy = true
}


