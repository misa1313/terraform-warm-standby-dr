variable "primary_vpc_block" {}
variable "first_subnet_block" {}
variable "second_subnet_block" {}
variable "region1" {}
variable "availability_zones1" {
  type = list(string)
}

##########################################################################
# MAIN VPC - Subnets - SG - IGW - RT
##########################################################################

provider "aws" {
  region = var.region1
  alias = "vpc_1"
}

module "main_vpc" {
  source = "terraform-aws-modules/vpc/aws"
  providers = {
    aws = aws.vpc_1
  }
  name = "main_vpc"
  cidr = var.primary_vpc_block
  azs             = var.availability_zones1
  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

resource "aws_subnet" "main_vpc-subnet_1" {
  vpc_id            = module.main_vpc.vpc_id
  cidr_block        = var.first_subnet_block
  availability_zone = var.availability_zones1[0]
  map_public_ip_on_launch = true
  
  tags = {
    Name = "main_vpc-subnet_1"
  }
}

resource "aws_subnet" "main_vpc-subnet_2" {
  vpc_id            = module.main_vpc.vpc_id
  cidr_block        = var.second_subnet_block
  availability_zone = var.availability_zones1[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "main_vpc-subnet_2"
  }
}

resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = module.main_vpc.vpc_id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = module.main_vpc.vpc_id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
  }
  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "rta_subnet_1" {
  subnet_id      = aws_subnet.main_vpc-subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "rta_subnet_2" {
  subnet_id      = aws_subnet.main_vpc-subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}


