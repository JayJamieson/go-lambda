#!/bin/bash

# NOTE:
# sample script, not fully test

docker build -t lambda-build .
docker run -it -v $(pwd):/project lambda-build go build -o ./bin/main.local ./cmd/handler/main.go
docker run -it -v $(pwd):/project lambda-build go build -tags lambda.norpc -o ./infrastructure/bootstrap ./main.go


if [ -f "bootstrap.zip" ]; then
  echo "deleting old zip"
  rm bootstrap.zip
fi

zip -j bootstrap.zip ./bin/main

cp bootstrap.zip ./infrastructure