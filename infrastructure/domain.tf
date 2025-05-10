data "aws_route53_zone" "lambda_api_root_zone" {
  count = var.with_api_gateway ? 1 : 0
  name  = var.root_zone_domain
}

resource "aws_acm_certificate" "certificate" {
  count             = var.with_api_gateway ? 1 : 0
  domain_name       = var.lambda_rest_api_sub_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  count   = var.with_api_gateway ? 1 : 0
  name    = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.lambda_api_root_zone[0].zone_id
  records = [tolist(aws_acm_certificate.certificate[0].domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  count                   = var.with_api_gateway ? 1 : 0
  certificate_arn         = aws_acm_certificate.certificate[0].arn
  validation_record_fqdns = [aws_route53_record.certificate_validation[0].fqdn]
}

resource "aws_api_gateway_domain_name" "domain_name" {
  count                    = var.with_api_gateway ? 1 : 0
  domain_name              = var.lambda_rest_api_sub_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation[0].certificate_arn

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  count       = var.with_api_gateway ? 1 : 0
  api_id      = aws_api_gateway_rest_api.lambda_api[0].id
  stage_name  = aws_api_gateway_stage.lambda_api_stage[0].stage_name
  domain_name = aws_api_gateway_domain_name.domain_name[0].domain_name
}

resource "aws_route53_record" "sub_domain" {
  count   = var.with_api_gateway ? 1 : 0
  name    = var.lambda_rest_api_sub_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.lambda_api_root_zone[0].zone_id

  alias {
    name                   = aws_api_gateway_domain_name.domain_name[0].regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name[0].regional_zone_id
    evaluate_target_health = false
  }
}
