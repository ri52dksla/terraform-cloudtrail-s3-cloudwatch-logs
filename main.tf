terraform {
  required_version = "~> 0.11.8"
}

provider "aws" {
  version = "~> 1.35.0"
  region  = "${local.region}"
}
