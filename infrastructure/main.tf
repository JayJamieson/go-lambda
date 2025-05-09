terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.13.1"
    }
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "go_lambda" {
  function_name = "go-demo"

  role          = aws_iam_role.lambda_iam_role.arn
  architectures = ["x86_64"]
  image_uri     = "${aws_ecr_repository.go_lambda.repository_url}:${var.image_tag}"
  package_type  = "Image"
  timeout       = 900

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    aws_ecr_repository.go_lambda
  ]
}

resource "aws_ecr_repository" "go_lambda" {
  name                 = "go-lambda"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_lambda_function_url" "go_lambda" {
  function_name      = aws_lambda_function.go_lambda.function_name
  authorization_type = "NONE"
}

resource "aws_iam_role" "lambda_iam_role" {
  name               = "demo-lambda-execution-role"
  assume_role_policy = data.aws_iam_policy_document.lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "lambda_execution_policy" {
  name        = "demo-lambda-basic-execution-policy"
  description = "policy to allow basic execution of lambda"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["logs:CreateLogGroup"]
        Effect = "Allow"
        Resource = [
          "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Resource = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_execution_policy.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.go_lambda.invoke_arn
}

output "lambda_function_name" {
  value = aws_lambda_function.go_lambda.function_name
}

output "lambda_function_url" {
  value = aws_lambda_function_url.go_lambda.function_url
}

output "ecr_repository" {
  value = aws_ecr_repository.go_lambda.repository_url
}
