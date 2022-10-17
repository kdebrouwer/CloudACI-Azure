#  use this override.tf to put in confidential data

#  Populate values based on your ND cofigiration
variable "creds" {
  type = map(any)
  default = {
    username = "admin"
    password = "ins3965!ins3965!"
    url      = "https://10.92.1.61/"
    #domain   = "put_in_auth_domain_defined_in_ND" # if you are using local user, comment this out.  
                                                  # Make sure to also comment out in variables.tf file.
  }
}