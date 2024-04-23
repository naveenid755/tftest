module "label_vpc" {
  source     = "cloudposse/label/null"
  version    = "0.25.0"
  context    = module.base_label.context
  name       = "vpc"
  attributes = ["main"]
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# Create your subnets here
# ==========================
/*
module "subnets" {
  source  = "hashicorp/subnets/cidr"
  version = "1.0.0"
   base_cidr_block =  aws_vpc.main.id
    networks = "default"
#   map_public_ip_on_launch = "true"
#   availability_zone = "eu-west-2a"
# insert the 2 required variables here
}*/

resource "aws_subnet" "private_sub" {
  vpc_id                  = aws_vpc.main.id
 # cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = "us-west-1b"
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 4)
}


resource "aws_subnet" "public_sub" {
  vpc_id                  = aws_vpc.main.id
 # cidr_block              = var.vpc_cidr
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 8)

  map_public_ip_on_launch = "true"
  availability_zone       = "us-west-1b"
}


resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
}
