# go-lambda

## Requirements

- go 1.18
- zip
- docker
- terraform

## Setup (optional)

Although not require specifically to run go in lambdas, can be useful to avoid compatibility issues
when using cgo bindings or third party libraries using cgo such as sqlite3.

- build docker container for building lambda function binary fully compatible with aws lambda runtime
- `docker build -t lambda-build .`

## Build

- `go build -o ./bin/main.local ./cmd/handler/main.go` for locally running lambda handler
- `go build -o ./bin/main ./main.go` for lambda binary. Can be run locally if `_LAMBDA_SERVER_PORT` and `AWS_LAMBDA_RUNTIME_API` are defined
but this is not tested and behaviour is undefined

## Deploy

- `aws lambda update-function-code --function-name go-lambda --zip-file fileb://function.zip`
