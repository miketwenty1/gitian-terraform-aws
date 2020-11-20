resource "aws_instance" "gitian" {
  ami                     = lookup(local.ubuntu20_04, var.region, "ami not defined for this region. Please make a PR")
  availability_zone       = "${var.region}${var.az_letter}"
  instance_type           = var.instance_size
  key_name                = var.ssh_key_name
  vpc_security_group_ids  = [aws_security_group.gitian.id]
  subnet_id               = var.subnet_id
  user_data               = data.template_cloudinit_config.cloud-init.rendered

  root_block_device {
    volume_type = "gp2"
    volume_size = 50
  }

  tags = merge(local.common_tags,map(
    "Name", var.service_name
  ))
  provider = aws.env
}
