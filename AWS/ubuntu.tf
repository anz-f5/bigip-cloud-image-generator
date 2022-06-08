resource "aws_network_interface" "ubuntu-s0" {
  subnet_id       = aws_subnet.subnets[0].id
  private_ips     = [var.private-ips["ubuntu"]]
  security_groups = [aws_security_group.mgmt.id]
}

resource "aws_eip" "ubuntu-s0" {
  vpc                       = true
  network_interface         = aws_network_interface.ubuntu-s0.id
  associate_with_private_ip = var.private-ips["ubuntu"]
}

resource "aws_instance" "ubuntu-server" {
  ami           = var.ubuntu_server_ami
  instance_type = var.ubuntu_server_instance_type
  key_name      = var.key_name

  root_block_device {
    volume_size = 200
  }

  network_interface {
    network_interface_id = aws_network_interface.ubuntu-s0.id
    device_index         = 0
  }

  tags = {
    for k, v in merge({
      Name = format("%s-ubuntu-server", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}



