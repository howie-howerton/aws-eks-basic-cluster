provider "aws" {
  region     = "${var.aws_region}"
  access_key = "${var.aws_access_key_id}"
  secret_key = "${var.aws_secret_access_key}"
}

#----- Data Sources -----
data "aws_availability_zones" "available" {}


#-------------VPC-----------
# Note the tag annotation for kubernetes/EKS
resource "aws_vpc" "demo_vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = "true"
  enable_dns_support   = "true"

  tags = "${
    map(
      "Name", "${var.tag_prefix}_vpc",
      "kubernetes.io/cluster/${var.cluster_name}", "shared"
    )
  }"
}


#internet gateway

resource "aws_internet_gateway" "demo_internet_gateway" {
  vpc_id = "${aws_vpc.demo_vpc.id}"

  tags = {
    Name = "${var.tag_prefix}_igw"
  }
}

# EIP and NAT Gateway
resource "aws_eip" "ngw_eip" {
  vpc = true
}
resource "aws_nat_gateway" "demo_nat_gateway" {
  allocation_id = "${aws_eip.ngw_eip.id}"
  subnet_id     = "${aws_subnet.demo_public1_subnet.id}"
  depends_on    = ["aws_internet_gateway.demo_internet_gateway"]

  tags = {
    Name = "${var.tag_prefix}-NatGateway"
  }
}

# Route tables

resource "aws_route_table" "demo_public_rt" {
  vpc_id = "${aws_vpc.demo_vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.demo_internet_gateway.id}"
  }

  tags = {
    Name = "${var.tag_prefix}_public_rt"
  }
}

resource "aws_default_route_table" "demo_private_rt" {
  default_route_table_id = "${aws_vpc.demo_vpc.default_route_table_id}"
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${aws_nat_gateway.demo_nat_gateway.id}"
  }

  tags = {
    Name = "${var.tag_prefix}_private_rt"
  }
}


# Subnets

resource "aws_subnet" "demo_public1_subnet" {
  vpc_id                  = "${aws_vpc.demo_vpc.id}"
  cidr_block              = "${var.cidrs["PublicSubnet01"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags = {
    Name = "${var.tag_prefix}_PublicSubnet01"
  }
}

resource "aws_subnet" "demo_public2_subnet" {
  vpc_id                  = "${aws_vpc.demo_vpc.id}"
  cidr_block              = "${var.cidrs["PublicSubnet02"]}"
  map_public_ip_on_launch = true
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags = {
    Name = "${var.tag_prefix}_PublicSubnet02"
  }
}

resource "aws_subnet" "demo_private1_subnet" {
  vpc_id                  = "${aws_vpc.demo_vpc.id}"
  cidr_block              = "${var.cidrs["PrivateSubnet01"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[0]}"

  tags = "${
    map(
      "Name", "${var.tag_prefix}_PrivateSubnet01",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}

resource "aws_subnet" "demo_private2_subnet" {
  vpc_id                  = "${aws_vpc.demo_vpc.id}"
  cidr_block              = "${var.cidrs["PrivateSubnet02"]}"
  map_public_ip_on_launch = false
  availability_zone       = "${data.aws_availability_zones.available.names[1]}"

  tags = "${
    map(
      "Name", "${var.tag_prefix}_PrivateSubnet02",
      "kubernetes.io/cluster/${var.cluster_name}", "shared",
    )
  }"
}


# Subnet-to-Route Table Associations

resource "aws_route_table_association" "demo_public_assoc" {
  subnet_id      = "${aws_subnet.demo_public1_subnet.id}"
  route_table_id = "${aws_route_table.demo_public_rt.id}"
}

resource "aws_route_table_association" "demo_2_assocpublic" {
  subnet_id      = "${aws_subnet.demo_public2_subnet.id}"
  route_table_id = "${aws_route_table.demo_public_rt.id}"
}

resource "aws_route_table_association" "demo_private1_assoc" {
  subnet_id      = "${aws_subnet.demo_private1_subnet.id}"
  route_table_id = "${aws_default_route_table.demo_private_rt.id}"
}

resource "aws_route_table_association" "demo_private2_assoc" {
  subnet_id      = "${aws_subnet.demo_private2_subnet.id}"
  route_table_id = "${aws_default_route_table.demo_private_rt.id}"
}

