variable "cloudtrail_s3_bucket_name" {
  type = "string"
}

variable "application_s3_bucket_name" {
  type = "string"
}

variable "environment" {
  type    = "string"
  default = "Dev"
}

locals {
  region     = "ap-northeast-1"
  account_id = "${data.aws_caller_identity.current.account_id}"
}
