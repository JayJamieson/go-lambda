FROM golang:1.22 AS build

WORKDIR /project

COPY go.mod go.sum ./
RUN go mod download -x

COPY handlers/ handlers/
COPY main.go .

RUN CGO_ENABLED=0 go build -tags lambda.norpc -o main main.go

FROM public.ecr.aws/lambda/provided:al2

COPY --from=build /project/main ./main

ENTRYPOINT [ "./main" ]
