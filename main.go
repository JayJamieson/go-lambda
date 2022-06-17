package main

import (
	"github.com/JayJamieson/go-lambda/handlers"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	// https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html
	// New returns handler function this is useful for passing
	// in environment configurations and dependencies

	handler := handlers.New()
	lambda.Start(handler)
}
