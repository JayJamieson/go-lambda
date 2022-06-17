package main

import (
	"context"
	"github.com/JayJamieson/go-lambda/handlers"
	"log"
	"os"
	"time"

	"github.com/aws/aws-lambda-go/events"
)

func main() {
	//this lambda setup is used for testing/running locally without deployment
	//if specific events are required we can read in json event samples or
	//command line flags to help build the events

	lambdaMaxRuntime := time.Now().Add(15 * time.Minute)

	ctx, cancel := context.WithDeadline(context.Background(), lambdaMaxRuntime)
	defer cancel()

	handler := handlers.New()

	// setup event from cli args or reading from file
	event := events.APIGatewayProxyRequest{}

	_, err := handler(ctx, event)

	if err != nil {
		log.Fatal(err.Error())
	}

	os.Exit(0)
}
