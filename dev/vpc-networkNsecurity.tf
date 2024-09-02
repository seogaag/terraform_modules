
provider "aws" {
  alias = "network"

  region = "ap-southeast-4"
}


module "vpc-network" {
  source = "../modules/vpc-network"

  vpc_cidr_block = "10.0.0.0/16"
  cidr_blocks = [ module.vpc-security.vpc_cidr_block,
                  "10.2.0.0/16",
                  "10.3.0.0/16",
                  "10.4.0.0/16" ]
  account_name = "network"
  # access_key = "a"
  # secret_key = "a"
}

module "vpc-security" {
  source = "../modules/vpc-security"

  vpc_cidr_block = "192.118.0.0/16"
  account_name = "security"
  region = "ap-south-1"
  access_key = "a"
  secret_key = "a"
}

output "name" {
  value = module.vpc-security.firewall_endpoint_ids
}