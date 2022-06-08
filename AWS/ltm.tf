resource "aws_network_interface" "ltm-mgmt" {
  subnet_id       = aws_subnet.subnets[0].id
  private_ips     = [var.private-ips["ltm-mgmt"]]
  security_groups = [aws_security_group.mgmt.id]

  tags = {
    for k, v in merge({
      Name = format("%s-ltm-mgmt", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}

resource "aws_network_interface" "ltm-ext" {
  subnet_id       = aws_subnet.subnets[1].id
  private_ips     = [var.private-ips["ltm-ext"]]
  security_groups = [aws_security_group.mgmt.id]

  tags = {
    for k, v in merge({
      Name = format("%s-ltm-ext", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}

resource "aws_eip" "ltm-mgmt" {
  vpc                       = true
  network_interface         = aws_network_interface.ltm-mgmt.id
  associate_with_private_ip = var.private-ips["ltm-mgmt"]
}

data "template_file" "vm-onboard" {
  template = file("${path.module}/onboard.tpl")

  vars = {
    mgmt_gw = var.mgmt-gw
  }
}

resource "aws_instance" "ltm" {
  ami               = var.ltm_ami
  instance_type     = var.ltm_instance_type
  availability_zone = var.az
  key_name          = var.key_name
  user_data         = base64encode(data.template_file.vm-onboard.rendered)

  network_interface {
    network_interface_id = aws_network_interface.ltm-mgmt.id
    device_index         = 0
  }

  network_interface {
    network_interface_id = aws_network_interface.ltm-ext.id
    device_index         = 1
  }

  tags = {
    for k, v in merge({
      Name     = format("%s-ltm", var.prefix),
      schedule = "time-to-stop-AU"
      },
    var.default_ec2_tags) : k => v
  }

}

