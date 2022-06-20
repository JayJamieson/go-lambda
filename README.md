# go-lambda

This repository contains example lambda handler for integration with API gateway. We use terraform to setup infrastructure including DNS, SSL Certificates.

## Requirements

- go 1.18
- zip
- docker
- terraform
- aws cli

## Setup (optional)

Although not require specifically to run go in lambdas, can be useful to avoid compatibility issues
when using cgo bindings or third party libraries using cgo such as sqlite3.

- build docker container for building lambda function binary fully compatible with aws lambda runtime
- `docker build -t lambda-build .`

## Build

- `go build -o ./bin/main.local ./cmd/handler/main.go` for locally running lambda handler as a cli application.
  - requires manually providing event data from file or hard coded into the main.go file
  - it can be very easy to write a cli interface to read event from path or stdin or wrap in a http server
- `go build -o ./bin/main ./main.go` for lambda binary. Can be run locally if `_LAMBDA_SERVER_PORT` and `AWS_LAMBDA_RUNTIME_API` are defined
but this is not tested and behaviour is undefined

## Deploy

Create a `terraform.tfvars` file inside infrastructure folder and fill out required variables.

- Manually deploy function code changes with cli `aws lambda update-function-code --function-name go-lambda --zip-file fileb://function.zip`
- Use terraform to deploy infrastucture changes and function changes `terraform apply --auto-approve`
  - `main.aws_lambda_function.go_lambda.source_code_hash = filebase64sha256("function.zip")` will change detect function changes and cause terraform to detect change and deploy change to lambda.

## Optional

Currently the lambda handler takes in any request method and path. For full utilization of api gateway proxy functionality you can make use of <https://github.com/awslabs/aws-lambda-go-api-proxy> to run a standard Go http server and adapt api gateway requests to Go requests and vice versa Go responses to api gateway responses

It should be noted that doing this it is worth while writing a api that has fast startup times and utilizes as much of aws services. Or operate in a stateless architecture that has all required state in requests.

## Future work

- [] add github actions to build and deploy changes on main branch merge
