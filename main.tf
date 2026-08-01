provider "aws" {
  region = "us-east-1"
}

# VPC

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

resource "aws_nat_gateway" "main" {
  vpc_id            = aws_vpc.main.id
  availability_mode = "regional"

  tags = {
    Name = "regional-nat-gateway"
  }

  depends_on = [
    aws_internet_gateway.main
  ]
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route_table_association" "private-a" {
  subnet_id = aws_subnet.private-a.id

  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-b" {
  subnet_id = aws_subnet.private-b.id

  route_table_id = aws_route_table.private.id
}

# SECURITY GROUPS

resource "aws_security_group" "alb" {
  name        = "alb-security-group"
  description = "Allow web traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"

    from_port   = 443
    to_port     = 443
    protocol    = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}

resource "aws_security_group" "ec2" {
  name        = "ec2-security-group"
  description = "Allow HTTP traffic from ALB"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"

    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"

    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-security-group"
  }
}

