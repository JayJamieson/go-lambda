# go-lambda

**AWS has [deprecated go1.x](https://aws.amazon.com/blogs/compute/migrating-aws-lambda-functions-from-the-go1-x-runtime-to-the-custom-runtime-on-amazon-linux-2/) runtime.**

This repository contains example lambda handler integration with API Gateway. Terraform is used to deploy infrastructure including DNS, SSL Certificates.

## Requirements

- go 1.22
- zip
- docker
- terraform
- aws cli
- jq

## Setup (Optional)

For now an existing AWS ECR is required to exist already or created using `./create_ecr.sh`. Unfortunately it's not possible yet to create an ECR, build and push an image, then reference the image_uri needed for Lambda resource.

If you an existing ECR you can run `./create_ecr.sh` with the `--auth-only` flag to skip creating a new ECR. This will pull credentials and inject into Docker engine.

```shell
Usage: ./create-ecr.sh --repo-name NAME --region REGION --account-id ID [--auth-only]
  --repo-name    ECR repository name         (required)
  --region       AWS region                  (required)
  --account-id   AWS account ID              (required)
  --auth-only    Only login Docker to ECR and exit
```

## Build

The deploy artifact is a container image instead of a zip file with the built binary. AWS has optimized container images for Lambda and results in faster cold starts.

To build an image and tag using `tag --points-at HEAD --sort=-version:refname` run `./build_image.sh`. This script will built a Lambda compatible container image and push to the configured AWS ECR. This script expects `./create_ecr.sh` to have run or at the minimum run with `--auth-only` for an existing ECR to get login credentials for Docker engine.

```shell
Usage: ./build_image.sh --account-id ID --region REGION --repo-name NAME [--tag TAG]
  --account-id   AWS account ID       (required)
  --region       AWS region           (required)
  --repo-name    ECR repository name  (required)
  --tag          Image tag override; if omitted, use latest Git tag on HEAD
```

## Deploy

Create a `terraform.tfvars` file inside infrastructure folder and fill out required variables.

- Use terraform to deploy infrastructure changes and function changes `terraform apply --auto-approve`

To enable auto container image builds set `with_docker_build` to `true`. This will run the `./build_image.sh` script and output the image URI for use in the Lambda resource. Default is disabled.

## Optional

Currently, the lambda handler takes in any request method and path. For full utilization of API Gateway proxy functionality you can make use of <https://github.com/awslabs/aws-lambda-go-api-proxy> to run a standard Go http server and adapt API Gateway requests to Go requests and vice versa Go responses to API Gateway responses

- Be aware to write lambda aware handlers using the adapters.
- Optimize for fast startups

## Future work

- [ ] add GitHub action to build and deploy changes on main branch merge
