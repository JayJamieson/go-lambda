#!/bin/bash

docker run -it -v $(pwd):/project lambda-build go build -o ./bin/main.local ./cmd/handler/main.go
docker run -it -v $(pwd):/project lambda-build go build -o ./bin/main ./main.go

rm function.zip

zip -j function.zip ./bin/main