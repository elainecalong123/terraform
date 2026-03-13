# This module only READS existing infrastructure from SSM
data "aws_ssm_parameter" "vpc_id" {
  name = "${var.network_ssm_prefix}/vpc_id"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "${var.network_ssm_prefix}/private_subnets"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "${var.network_ssm_prefix}/public_subnets"
}