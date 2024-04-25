## modules for tagss for the respurces created in vpc.tf file. 

module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

module "private_subnet" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "private-subnet"
  attributes       = ["private_sub"]
  delimiter        = "-"
}

module "public_subnet" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "public-subnet"
  attributes       = ["public_sub"]
  delimiter        = "-"
}

module "internet_gateway" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "internet-gateway"
  attributes       = ["gw"]
  delimiter        = "-"
}

module "route_table" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "route-table"
  attributes       = ["Public-Subnet-RT"]
  delimiter        = "-"
}

module "nat_gateway" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "nat-gateway"
  attributes       = ["nat-gw"]
  delimiter        = "-"
}

module "nat_eip" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "nat-eip"
  attributes       = ["nat-gw-eip"]
  delimiter        = "-"
}

module "security_group" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  environment      = "test"
  stage            = "main"
  name             = "security-group"
  attributes       = ["SG"]
  delimiter        = "-"
}
