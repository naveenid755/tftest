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
# =========================
resource "aws_subnet" "privatesub" {
 # count                   = local.private_count
  vpc_id                  = var.vpc_id
  availability_zone       = var.availability_zone
  cidr_block              = cidrsubnet(var.cidr_block, ceil(log(var.max_subnets, 2)), count.index)
  map_public_ip_on_launch = var.map_public_ip_on_launch_enabled

  tags = merge(module.private_label.tags, {
    "Name"  = "${module.private_label.id}${module.this.delimiter}${element(var.subnet_names, count.index)}"
    "Named" = var.subnet_names[count.index]
    "Type"  = var.type
  }, var.tags)
}
