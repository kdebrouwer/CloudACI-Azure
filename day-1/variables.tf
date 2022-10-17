#  Define variables (can also put this block in a file named terraform.tfvars)
#  Default values can be defined here, which can be overwritten by values defined in terraform.tfvars
#  You can also create a overwrite.tf file where you can keep confidential values

variable "creds" {
  type = map(any)
  default = {
    username = "someuser"
    password = "something"
    url      = "someurl"
    #domain   = "remoteuserRadius" # comment out if using local ND user instead of remote user
  }
}

variable "azure" {
  type = object({
    azure_subscription_id = string
  })
  default = {
    azure_subscription_id = "fa05d217-7f34-419e-b9ea-5932f2754cc9"
  }
}
variable "tenant" {
  type = object({
    tenant_name  = string
    display_name = string
    description  = string
  })
  default = {
    tenant_name  = "Demo"
    display_name = "Demo"
    description  = "Demo Tenant"
  }
}


variable "schema_name" {
  type    = string
  default = "some_value"
}

variable "template_name" {
  type    = string
  default = "some_value"
}

variable "azure_site_name" {
  type    = string
  default = "capic_demo"
}

variable "onprem_site_name" {
  type    = string
  default = "onprem"
}

variable "vrf_name" {
  type    = string
  default = "some_value"
}

variable "bd_name" {
  type    = string
  default = "some_value"
}

variable "bd_subnet" {
  type    = string
  default = "some_value"
}

variable "anp_name" {
  type    = string
  default = "some_value"
}

variable "epg_name" {
  type    = string
  default = "some_value"
}

variable "vmm_name" {
  type    = string
  default = "some_value"
}

variable "epg_selector_value" {
  type    = string
  default = "some_value"
}

variable "region_name" {
  type    = string
  default = "some_value"
}

variable "cidr_ip" {
  type    = string
  default = "some_value"
}

variable "subnet1" {
  type    = string
  default = "some_value"
}

variable "zone1" {
  type    = string
  default = "some_value"
}

variable "vm_name" {
  type    = string
  default = "some_value"
}


