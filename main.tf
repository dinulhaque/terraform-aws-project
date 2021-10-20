terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "3.62.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "eu-west-2"
}
# Create a VPC

resource "aws_vpc" "dev-vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Environments = "dev-vpc"
  }
}
resource "aws_internet_gateway" "dev-igw" {
  vpc_id = aws_vpc.dev-vpc.id

    tags = {
      Name = "dev igw"
    }
  }


resource "aws_subnet" "dev-private-subnet1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2a"

  tags = {
    Name = "dev-private-subnet1"
  }
}

resource "aws_subnet" "dev-private-subnet2" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "project1-dev-private-subnet2"
  }
}

resource "aws_subnet" "dev-public-subnet1" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-2a"

  tags = {
      Name = "project1-dev-public-subnet1"
    }
}

resource "aws_subnet" "dev-public-subnet2" {
  vpc_id                  = aws_vpc.dev-vpc.id
  cidr_block              = "10.0.4.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = "eu-west-2b"

  tags = {
    Name = "project1-dev-public-subnet2"
  }

}


resource "aws_route_table" "route_table" {
 
  vpc_id = aws_vpc.dev-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.dev-igw.id
    }

    tags = {
      Name = "vpc route table"
    }
}

resource "aws_route_table_association" "route_table_association-public-1" {
    subnet_id      = aws_subnet.dev-public-subnet1.id
    route_table_id = aws_route_table.route_table.id

  }

resource "aws_route_table_association" "route_table_association-public-2" {
    subnet_id      = aws_subnet.dev-public-subnet1.id
    route_table_id = aws_route_table.route_table.id

  }

resource "aws_route_table_association" "route_table_association-private-1" {
    subnet_id      = aws_subnet.dev-private-subnet1.id
    route_table_id = aws_route_table.private_route_table_1.id

  }

resource "aws_route_table_association" "route_table_association-private-2" {
    subnet_id      = aws_subnet.dev-private-subnet2.id
    route_table_id = aws_route_table.private_route_table_2.id

  }

resource "aws_route_table" "private_route_table_1" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw_2.id
    }

    tags = {
      Name = "cidr 10.0.3.0/24 public route table 1"
    }
}
resource "aws_route_table" "private_route_table_2" {
    vpc_id = aws_vpc.dev-vpc.id

    route {
      cidr_block = "0.0.0.0/0"
      nat_gateway_id = aws_nat_gateway.nat_gw_2.id
    }

    tags = {
      Name = "cidr 10.0.4.0/24 public route table 2"
    }
  }


resource "aws_eip" "nat" {
  count = 2

  vpc = true
}

resource "aws_nat_gateway" "nat_gw_1" {
  allocation_id = aws_eip.nat[0].id
  subnet_id         = aws_subnet.dev-public-subnet1.id
}

resource "aws_nat_gateway" "nat_gw_2" {
  allocation_id = aws_eip.nat[1].id
  subnet_id         = aws_subnet.dev-public-subnet2.id

}
