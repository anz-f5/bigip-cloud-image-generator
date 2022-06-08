resource "aws_s3_bucket" "b" {
  bucket        = format("%s-abgmbh", var.prefix)
  acl           = "private"
  force_destroy = true

  tags = {
    for k, v in merge({
      Name = format("%s-abgmbh", var.prefix)
      },
    var.default_ec2_tags) : k => v
  }
}
