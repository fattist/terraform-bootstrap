provider "aws" {
  version = "~> 2.57.0"
}

terraform {
  backend "s3" {}
}
