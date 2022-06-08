resource "aws_vpc" "main" {
  cidr_block = var.cidr

  tags = {
    for k, v in merge({
      Name = format("%s-vpc", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}

resource "aws_subnet" "subnets" {
  vpc_id            = aws_vpc.main.id
  availability_zone = var.az
  count             = length(var.subnets)
  cidr_block        = values(var.subnets)[count.index]

  tags = {
    for k, v in merge({
      Name = format("%s-%s", var.prefix, keys(var.subnets)[count.index])
      },
    var.default_ec2_tags) : k => v
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    for k, v in merge({
      Name = format("%s-igw", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}

resource "aws_default_route_table" "default" {
  default_route_table_id = aws_vpc.main.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    for k, v in merge({
      Name = format("%s-default", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}


