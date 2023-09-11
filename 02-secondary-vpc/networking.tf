variable "secondary_vpc_block" {}
variable "third_subnet_block" {}
variable "fourth_subnet_block" {}
variable "region2" {}
variable "region1" {}
variable "availability_zones2" {
  type = list(string)
}

##########################################################################
# SECONDARY VPC - Subnets - SG - IGW - RT
##########################################################################

provider "aws" {
  region = var.region2
}

module "secondary_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "secondary_vpc"
  cidr = var.secondary_vpc_block
  azs             = var.availability_zones2
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "secondary_vpc-subnet_1" {
  vpc_id            = module.secondary_vpc.vpc_id
  cidr_block        = var.third_subnet_block
  availability_zone = var.availability_zones2[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "secondary_vpc-subnet_1"
  }
}

resource "aws_subnet" "secondary_vpc-subnet_2" {
  vpc_id            = module.secondary_vpc.vpc_id
  cidr_block        = var.fourth_subnet_block
  availability_zone = var.availability_zones2[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "secondary_vpc-subnet_2"
  }
}

resource "aws_internet_gateway" "internet_gateway_2" {
  vpc_id = module.secondary_vpc.vpc_id
}

resource "aws_route_table" "public_route_table_2" {
  vpc_id = module.secondary_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway_2.id
  }
  tags = {
    Name = "public_route_table_2"
  }
}

resource "aws_route_table_association" "rta_subnet_3" {
  subnet_id      = aws_subnet.secondary_vpc-subnet_1.id
  route_table_id = aws_route_table.public_route_table_2.id
}

resource "aws_route_table_association" "rta_subnet_4" {
  subnet_id      = aws_subnet.secondary_vpc-subnet_2.id
  route_table_id = aws_route_table.public_route_table_2.id
}