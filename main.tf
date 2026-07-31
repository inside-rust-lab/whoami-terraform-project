provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "private-a" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.1.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-a"
  }
}

resource "aws_subnet" "private-b" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.2.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = false

  tags = {
    Name = "private-subnet-b"
  }
}

resource "aws_subnet" "public-a" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.3.0/24"

  availability_zone = "us-east-1a"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"
  }
}

resource "aws_subnet" "public-b" {
  vpc_id = aws_vpc.main.id

  cidr_block = "10.0.4.0/24"

  availability_zone = "us-east-1b"

  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public-a" {
  subnet_id = aws_subnet.public-a.id

  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public-b" {
  subnet_id = aws_subnet.public-b.id

  route_table_id = aws_route_table.public.id
}