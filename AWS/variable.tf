variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

variable "azure_client_id" {}
variable "client_certificate_path" {}
variable "client_certificate_password" {}
variable "azure_subscription_id" {}
variable "azure_tenant_id" {}

variable "cidr" { default = "10.0.0.0/16" }
variable "az" { default = "us-east-1c" }

variable "ip-1" {}
variable "subnets" {
  type = map(any)
  default = {
    "s0" = "10.0.0.0/24"
    "s1" = "10.0.1.0/24"
  }
}

variable "private-ips" {
  type = map(any)
  default = {
    "ubuntu"   = "10.0.0.4"
    "ltm-mgmt" = "10.0.0.5"
    "ltm-ext"  = "10.0.1.4"
  }
}

variable "key_name" {}

variable "prefix" { default = "cz" }
variable "ubuntu_server_ami" { default = "ami-0e472ba40eb589f49" }
variable "ltm_ami" { default = "ami-04c07e9cc4af6b989" }
variable "ubuntu_server_instance_type" { default = "i3.metal" }
variable "ltm_instance_type" { default = "t2.medium" }
variable "mgmt-gw" { default = "10.0.0.1" }

variable "default_ec2_tags" {
  description = "Default set of tags to apply to EC2 instances"
  type        = map(any)
  default = {
    Owner = "christopher.zhang@f5.com"
  }
}
