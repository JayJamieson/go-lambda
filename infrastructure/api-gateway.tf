resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "lambda-api"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
  disable_execute_api_endpoint = true
}

resource "aws_api_gateway_resource" "lambda_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  parent_id   = aws_api_gateway_rest_api.lambda_api.root_resource_id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "method" {
  rest_api_id      = aws_api_gateway_rest_api.lambda_api.id
  resource_id      = aws_api_gateway_resource.lambda_api_resource.id
  http_method      = "ANY"
  authorization    = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_deployment" "lambda_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.lambda_api_resource.id,
      aws_api_gateway_method.method.id,
      aws_api_gateway_integration.lambda_integration.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "lambda_api_stage" {
  deployment_id = aws_api_gateway_deployment.lambda_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.lambda_api.id
  stage_name    = "production"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.lambda_api.id
  resource_id             = aws_api_gateway_resource.lambda_api_resource.id
  http_method             = aws_api_gateway_method.method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.go_lambda.invoke_arn
}

resource "aws_lambda_permission" "api_gateway_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.go_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.lambda_api.id}/*"
}

resource "aws_api_gateway_usage_plan" "lambda_api_usage" {
  name         = "lambda-api-usage"
  description  = "lambda api usage"
  product_code = "LAMBDA_API"

  api_stages {
    api_id = aws_api_gateway_rest_api.lambda_api.id
    stage  = aws_api_gateway_stage.lambda_api_stage.stage_name
  }

  quota_settings {
    limit  = 10000
    offset = 0
    period = "DAY"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 10
  }
}

resource "aws_api_gateway_api_key" "lambda_api_key" {
  name = "developer"
}

resource "aws_api_gateway_usage_plan_key" "lambda_api_key_usage_plan" {
  key_id        = aws_api_gateway_api_key.lambda_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.lambda_api_usage.id
}
