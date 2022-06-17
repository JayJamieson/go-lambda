package handlers

import (
	"context"
	"encoding/json"
	"fmt"
	"log"

	"github.com/aws/aws-lambda-go/events"
)

func New() func(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	// similar to http middlewares, initialize dependencies here and use in
	// returned handler function.
	return func(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
		hello, ok := request.QueryStringParameters["hello"]
		req, _ := json.Marshal(request)

		log.Print(string(req))

		resp := "Hello World"
		if ok {
			resp = fmt.Sprintf("Hello %v 👀", hello)
		}
		log.Print("Running lambda")
		defer log.Print("Lambda complete")
		return events.APIGatewayProxyResponse{Body: resp, StatusCode: 200}, nil
	}
}
