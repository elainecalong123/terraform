# 1. DISCOVERY: Read the Shared Infrastructure from SSM
data "aws_ssm_parameter" "vpc_id" {
  name = "${var.network_ssm_prefix}/vpc_id"
}

data "aws_ssm_parameter" "private_subnets" {
  name = "${var.network_ssm_prefix}/private_subnets"
}

data "aws_ssm_parameter" "public_subnets" {
  name = "${var.network_ssm_prefix}/public_subnets"
}

data "aws_ssm_parameter" "zone_id" {
  name = "${var.network_ssm_prefix}/zone_id"
}

# 2. ACTION: Create the DNS Record for the App
# This connects your custom subdomain to the CloudFront distribution
resource "aws_route53_record" "app_alias" {
  zone_id = data.aws_ssm_parameter.zone_id.value
  name    = var.app_subdomain # e.g., crm-stage.yourcompany.com
  type    = "A"

  alias {
    name                   = var.cloudfront_domain_name
    zone_id                = var.cloudfront_hosted_zone_id
    evaluate_target_health = false
  }
}