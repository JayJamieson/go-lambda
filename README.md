# go-lambda

**AWS has [deprecated go1.x](https://aws.amazon.com/blogs/compute/migrating-aws-lambda-functions-from-the-go1-x-runtime-to-the-custom-runtime-on-amazon-linux-2/) runtime.**

This repository contains example lambda handler integration with API gateway. Terraform is used to deploy infrastructure including DNS, SSL Certificates.

## Requirements

- go 1.20
- zip
- docker
- terraform
- aws cli

## Setup (optional)

### Docker

Although not require specifically to run go in lambdas, can be useful to avoid compatibility issues
when using cgo bindings or third party libraries using cgo such as sqlite3.

- build docker container for building lambda function binary fully compatible with aws lambda runtime
- `docker build -t lambda-build .`

## Build

AWS `provided.al2` requires executables to be named bootstrap.

- `GOARCH=amd64 GOOS=linux go build -tags lambda.norpc -o ./infrastructure/bootstrap main.go`
  - `provided.al2` provide a single process architecture and allow running without RPC dependency using `-tags lambda.norpc`
  - Build without RPC using `GOARCH=amd64 GOOS=linux go build -tags lambda.norpc -o ./infrastructure/bootstrap main.go`

- `go build -o ./bin/main.local ./cmd/handler/main.go` for locally running lambda handler as a cli application.
  - requires manually providing event data from file or hard coded into the main.go file
  - it can be very easy to write a cli interface to read event from path or stdin or wrap in a http server

## Deploy

Create a `terraform.tfvars` file inside infrastructure folder and fill out required variables.

- Manually deploy function code changes with cli `aws lambda update-function-code --function-name go-lambda --zip-file fileb://bootstrap.zip`
- Use terraform to deploy infrastructure changes and function changes `terraform apply --auto-approve`
  - `main.aws_lambda_function.go_lambda.source_code_hash = filebase64sha256("bootstrap.zip")` will ensure new builds to redeploy with infrastructure changes.

## Optional

Currently, the lambda handler takes in any request method and path. For full utilization of api gateway proxy functionality you can make use of <https://github.com/awslabs/aws-lambda-go-api-proxy> to run a standard Go http server and adapt api gateway requests to Go requests and vice versa Go responses to api gateway responses

- Be aware to write lambda aware handlers using the adapters.
- Optimize for fast startups

## Future work

- [ ] add GitHub action to build and deploy changes on main branch merge
