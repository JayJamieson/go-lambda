data "aws_route53_zone" "lambda_api_root_zone" {
  name = var.root_zone_domain
}

resource "aws_acm_certificate" "certificate" {
  domain_name       = var.lambda_rest_api_sub_domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "certificate_validation" {
  name    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_type
  zone_id = data.aws_route53_zone.lambda_api_root_zone.zone_id
  records = [tolist(aws_acm_certificate.certificate.domain_validation_options)[0].resource_record_value]
  ttl     = 60
}

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = aws_acm_certificate.certificate.arn
  validation_record_fqdns = [aws_route53_record.certificate_validation.fqdn]
}

resource "aws_api_gateway_domain_name" "domain_name" {
  domain_name              = var.lambda_rest_api_sub_domain_name
  regional_certificate_arn = aws_acm_certificate_validation.certificate_validation.certificate_arn

  endpoint_configuration {
    types = [
      "REGIONAL",
    ]
  }
}

resource "aws_api_gateway_base_path_mapping" "path_mapping" {
  api_id      = aws_api_gateway_rest_api.lambda_api.id
  stage_name  = aws_api_gateway_stage.lambda_api_stage.stage_name
  domain_name = aws_api_gateway_domain_name.domain_name.domain_name
}

resource "aws_route53_record" "sub_domain" {
  name    = var.lambda_rest_api_sub_domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.lambda_api_root_zone.zone_id

  alias {
    name                   = aws_api_gateway_domain_name.domain_name.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.domain_name.regional_zone_id
    evaluate_target_health = false
  }
}
