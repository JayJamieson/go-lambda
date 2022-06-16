package main

import (
	"github.com/JayJamieson/go-lambda/handler"
	"github.com/aws/aws-lambda-go/lambda"
)

func main() {
	//https://docs.aws.amazon.com/lambda/latest/dg/golang-handler.html
	//NewHandler returns handler function this is useful for passing
	//in environment configurations and dependencies
	handler := handler.NewHandler()
	lambda.Start(handler)
}
