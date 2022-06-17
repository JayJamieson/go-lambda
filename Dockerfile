FROM amazonlinux:latest

RUN yum install -y tar xz gzip gcc

RUN curl -L -o golang.tar.gz https://go.dev/dl/go1.20.7.linux-amd64.tar.gz

RUN  rm -rf /usr/local/go && tar -C /usr/local -xzf golang.tar.gz

WORKDIR /project

COPY go.mod go.sum ./

RUN /usr/local/go/bin/go mod download -x

ENV PATH="${PATH}:/usr/local/go/bin"
