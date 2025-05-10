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

data "external" "ecr_image" {
  count = var.with_docker_build ? 1 : 0

  program = [
    "bash", "-c",
    <<-EOC
      # change into the parent directory of this module
      cd "${path.module}/.." && \
      # invoke your build script with all required flags (and optional tag)
      ./build_image.sh \
        --account-id "${data.aws_caller_identity.current.account_id}" \
        --region "${var.region}" \
        --repo-name "${var.repo_name}" \
        ${var.image_tag != "" ? "--tag ${var.image_tag}" : ""} \
    EOC
  ]

}

resource "aws_lambda_function" "go_lambda" {
  function_name = "go-demo"

  role          = aws_iam_role.lambda_iam_role.arn
  architectures = ["x86_64"]

  image_uri = "${var.with_docker_build == true ? data.external.ecr_image[0].result.image_uri : "${var.ecr_repository_uri}/${var.repo_name}:${var.image_tag}"}"

  package_type  = "Image"
  timeout       = 900

  depends_on = [
    aws_iam_role_policy_attachment.lambda_policy_attachment,
    data.external.ecr_image
  ]
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
