#
# Workstation External IP
#
# This configuration easily fetches
# the external IP of your local workstation to
# configure inbound EC2 Security Group access
#

data "http" "workstation-external-ip" {
  url = "http://ipv4.icanhazip.com"
}

# Override with variable or hardcoded value if necessary
locals {
  workstation-external-cidr = "${chomp(data.http.workstation-external-ip.body)}/32"
}
