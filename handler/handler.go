package handler

import (
	"context"
	"log"
)

func NewHandler() func(ctx context.Context) error {
	// similar to http middlewares, initialize dependencies here and use in
	// returned handler function.
	return func(ctx context.Context) error {
		log.Print("Running lambda")
		defer log.Print("Lambda complete")
		return nil
	}
}
