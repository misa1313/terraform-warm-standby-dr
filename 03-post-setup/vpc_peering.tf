provider "aws" {
  alias      = "this"
  region     = var.region1
}

provider "aws" {
  alias      = "peer"
  region     = var.region2
}

data "aws_vpcs" "main_vpc" {
  tags = {
    Name = "main_vpc"
  }
}

data "aws_vpcs" "secondary_vpc" {
  tags = {
    Name = "secondary_vpc"
  }
  provider = aws.peer
}

variable "region1" {}
variable "region2" {}

##########################################################################
# VPC Peering
##########################################################################

module "vpc-peering" {
  source  = "grem11n/vpc-peering/aws"
  version = "6.0.0"

  providers = {
    aws.this = aws.this
    aws.peer = aws.peer
  }

  this_vpc_id = data.aws_vpcs.main_vpc.ids[0]
  peer_vpc_id = data.aws_vpcs.secondary_vpc.ids[0]

  auto_accept_peering = true

  tags = {
    Name        = "tf-single-account-multi-region"
    Environment = "dev"
  }
}