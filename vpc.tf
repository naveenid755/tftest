resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = module.label_vpc.tags
}

# =========================
# Create your subnets here
# ==========================

data "aws_availability_zones" "available" {
  state = "available"
}

/*module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"
  # insert the 12 required variables here
}*/


resource "aws_subnet" "private_sub" {
  vpc_id = aws_vpc.main.id
  # cidr_block              = var.vpc_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[0]
 # availability_zone= "${data.aws_availability_zones.available.names[count.index]}"
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, 4)
  tags                 = module.private_subnet.tags

}


resource "aws_subnet" "public_sub" {
  vpc_id = aws_vpc.main.id
  # cidr_block              = var.vpc_cidr
  cidr_block = cidrsubnet(var.vpc_cidr, 4, 8)

  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0]
# availability_zone= "${data.aws_availability_zones.available.names[count.index]}"
  tags                 = module.public_subnet.tags
}

resource "aws_internet_gateway" "gw" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.private_sub,
    aws_subnet.public_sub
  ]

  vpc_id = aws_vpc.main.id
  tags                 = module.internet_gateway.tags
}


# Route Table for the public subnet
resource "aws_route_table" "Public-Subnet-RT" {
  depends_on = [
    aws_vpc.main,
    aws_internet_gateway.gw
  ]

  vpc_id = aws_vpc.main.id

  # NAT Rule
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
      tags                 = module.route_table.tags
  /*  tags = {
    Name = "Route Table for Internet Gateway"
  }*/
}

# for the Route Table Association..
resource "aws_route_table_association" "RT-IG-Association" {
  depends_on = [
    aws_vpc.main,
    aws_subnet.private_sub,
    aws_subnet.public_sub,
    aws_route_table.Public-Subnet-RT
  ]
  subnet_id      = aws_subnet.public_sub.id
  route_table_id = aws_route_table.Public-Subnet-RT.id
}

# Elastic IP for the NAT
resource "aws_eip" "nat-gw-eip" {
  depends_on = [
    aws_route_table_association.RT-IG-Association
  ]
  #vpc = true
  domain = "vpc"
 tags       = module.nat_eip.tags
}

resource "aws_nat_gateway" "nat-gw" {
  depends_on = [
    aws_eip.nat-gw-eip
  ]

  allocation_id = aws_eip.nat-gw-eip.id

  # Associating it inPublic subnet
  subnet_id = aws_subnet.public_sub.id

  tags = module.nat_gateway.tags

}

# Creating a Route Table for the Nat Gateway!
resource "aws_route_table" "nat-gw-RT" {
  depends_on = [
    aws_nat_gateway.nat-gw
  ]

  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

#  tags = {
 #   Name = "Route Table for NAT Gateway"
  #}

}

# Rout Table Association of the NAT Gateway routetable with the Private Sub
resource "aws_route_table_association" "nat-gw-RT-Association" {
  depends_on = [
    aws_route_table.nat-gw-RT
  ]

  subnet_id = aws_subnet.private_sub.id

  route_table_id = aws_route_table.nat-gw-RT.id
}


# Creating a Security Group
resource "aws_security_group" "main-SG" {

  depends_on = [
    aws_vpc.main,
    aws_subnet.private_sub,
    aws_subnet.public_sub
  ]

  description = "HTTP, PING, SSH"

  name = "webserver-sg"

  vpc_id = aws_vpc.main.id

  ingress {
    description = "HTTP for webserver"
    from_port   = 80
    to_port     = 80

    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for ping
  ingress {
    description = "Ping"
    from_port   = 0
    to_port     = 0
    protocol    = "ICMP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Created an inbound rule for SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22

    # Here adding tcp instead of ssh, because ssh in part of tcp...
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outward Network Traffic for the websever
  egress {
    description = "output from webserver"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

        tags = module.security_group.tags


}
