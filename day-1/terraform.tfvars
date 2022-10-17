azure_site_name = "capic_demo" # the site name for the Azure site as seen on ND
onprem_site_name = "On-Prem" # the site name for the On-Prem site as seen on ND

schema_name   = "Demo" # give it a name for the schema as you wish
template_name = "shared-template"            # use a template name as you wish
vrf_name      = "vrf1"                       # use a vrf name as you wish
bd_name       = "bd1"                        # use a bd name as you wish
anp_name      = "nc"                         # use a ANP name as you wish
epg_name       = "web"                        # use a EPg name as you wish
region_name   = "germanywestcentral"         # Make sure that you choose a region that was enabled in cAPIC initial setup
vmm_name      = "POD92-VMM"                  # use a pre-defined VMM Domain
bd_subnet     = "10.92.1.254/24"            # On-Prem BD subnet

cidr_ip = "172.18.0.0/16" # CIDR IP as you wish for the VPC to be created in Azure tenant account

subnet1 = "172.18.1.0/24" # subnet should belong to CIDR
zone1   = "germanywestcentral"    # az should be the 1st az in the chosen region.


epg_selector_value = "172.18.1.0/24" # EPG Selector to ensure proper Security Rules as defined by ACI Contracts

vm_name = "VM1" 
