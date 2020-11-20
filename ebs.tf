resource "aws_ebs_volume" "gitian" {
  availability_zone = "us-east-1a"
  size              = 20

  tags = merge(local.common_tags,map(
    "Name", "${var.env}_${var.service_name}_volume"
  ))
  provider = aws.env
}

resource "aws_volume_attachment" "ebs_att" {
  device_name = "/dev/sdf" # will end up being /dev/nvme1n1 in cloudinit
  volume_id   = aws_ebs_volume.gitian.id
  instance_id = aws_instance.gitian.id

  provider = aws.env
}

