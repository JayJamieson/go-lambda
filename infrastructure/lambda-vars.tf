variable "root_zone_domain" {
  description = "name of root domain name zone used for creating certificates and domain names"
  default = "example.com."
}

variable "lambda_rest_api_sub_domain_name" {
  description = "domain name for api gateway and certificates"
  defdefault = "api.example.com"
}
