package handler

import (
	"context"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
)

func NewHandler() func(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// similar to http middlewares, initialize dependencies here and use in
	// returned handler function.
	return func(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		hello, ok := request.QueryStringParameters["hello"]
		resp := "Hello World"
		if ok {
			resp = fmt.Sprintf("Hello %v 👀", hello)
		}
		log.Print("Running lambda")
		defer log.Print("Lambda complete")
		return events.APIGatewayProxyResponse{Body: resp, StatusCode: 200}, nil
	}
}
