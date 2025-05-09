FROM golang:1.22 AS build

WORKDIR /project

COPY go.mod go.sum ./
RUN go mod download -x

COPY handlers/ handlers/
COPY main.go .

RUN go build -tags lambda.norpc -o main main.go

FROM public.ecr.aws/lambda/provided:al2@sha256:a596777f9bbd1ed30cd3509743bc91fa2d289f31b085ded62e0c3c268a87b4c2

COPY --from=build /project/main ./main

ENTRYPOINT [ "./main" ]
