resource "aws_security_group" "gitian" {
  name        = "${var.service_name}_sg"
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags,map(
    "Name", "${var.env}_${var.service_name}_sg"
  ))
  provider = aws.env
}

resource "aws_security_group_rule" "rule_for_ssh" {
  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  cidr_blocks               = [var.cidr_block_ssh_access_rule]
  security_group_id         = aws_security_group.gitian.id
    
  provider = aws.env
}

resource "aws_security_group_rule" "outbound" {
  type                      = "egress"
  from_port                 = 0
  to_port                   = 0
  protocol                  = -1
  cidr_blocks               = ["0.0.0.0/0"]
  security_group_id         = aws_security_group.gitian.id
    
  provider = aws.env
}

resource "aws_security_group_rule" "rule_ssh_sg_access" {
  count = var.sg_for_access_id == "" ? 0 : 1

  type                      = "ingress"
  from_port                 = 22
  to_port                   = 22
  protocol                  = "tcp"
  security_group_id         = aws_security_group.gitian.id
  source_security_group_id  = var.sg_for_access_id

  provider = aws.env
}