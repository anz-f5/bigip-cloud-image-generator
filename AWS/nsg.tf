resource "aws_security_group" "mgmt" {
  name        = format("%s-mgmt", var.prefix)
  description = "mgmt rules"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "admin"
    from_port   = 0
    to_port     = 0
    protocol    = -1
    cidr_blocks = [var.ip-1]
  }

  ingress {
    description = "VPC"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
