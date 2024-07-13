terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.30.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# Create a VPC
resource "aws_vpc" "learn_rust_vpc" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "learn-rust-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.learn_rust_vpc.id

  tags = {
    Name = "vpc_igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id            = aws_vpc.learn_rust_vpc.id
  cidr_block        = var.public_subnet_cidr
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.learn_rust_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_rt"
  }
}

resource "aws_route_table_association" "public_rt_asso" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_instance" "web" {
  ami             = var.ami_id 
  instance_type   = var.instance_type
  key_name        = var.instance_key
  subnet_id       = aws_subnet.public_subnet.id
  iam_instance_profile = var.iam_instance_profile
  security_groups = [aws_security_group.sg.id]

  user_data = var.user_data

  tags = {
    Name = "rust_web_instance"
  }

  volume_tags = {
    Name = "rust_web_instance"
  } 
}