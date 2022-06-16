package main

import (
	"context"
	"log"
	"os"
	"time"

	"github.com/JayJamieson/go-lambda/handler"
)

func main() {
	//this lambda setup is used for testing/running locally without deployment
	//if specific events are required we can read in json event samples or
	//command line flags to help build the events

	lambdaMaxRuntime := time.Now().Add(15 * time.Minute)

	ctx, cancel := context.WithDeadline(context.Background(), lambdaMaxRuntime)
	defer cancel()

	handler := handler.NewHandler()

	err := handler(ctx)

	if err != nil {
		log.Fatal(err.Error())
		os.Exit(0)
	}

	os.Exit(0)
}
