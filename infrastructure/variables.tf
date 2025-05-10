variable "root_zone_domain" {
  description = "name of root domain name zone used for creating certificates and domain names"
  default     = "example.com."
}

variable "lambda_rest_api_sub_domain_name" {
  description = "domain name for api gateway and certificates"
  default     = "api.example.com"
}

variable "ecr_repository_uri" {
  description = "URI of AWS ECR"
  nullable = false
}

variable "repo_name" {
  description = "Name of ECR repo"
  nullable = false
}

variable "image_tag" {
  description = "Container image tag"
  default     = "latest"
}

variable "with_api_gateway" {
  description = "Deploy with API Gateway"
  type        = bool
  default     = false
}

variable "region" {
  description = "deployment region"
  default     = "ap-southeast-2"
}

variable "with_docker_build" {
  description = "Include automatic build step as part of terraform apply"
  type = bool
  default = false
}
