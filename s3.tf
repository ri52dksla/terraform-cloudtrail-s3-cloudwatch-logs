resource "aws_s3_bucket" "cloudtrail_s3_bucket" {
  bucket = "${var.cloudtrail_s3_bucket_name}"
  acl    = "private"

  tags {
    Name        = "cloudtrail s3 bucket"
    Environment = "${var.environment}"
  }

  force_destroy = true
}

# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/create-s3-bucket-policy-for-cloudtrail.html

data "aws_iam_policy_document" "cloudtrail_s3_bucket_policy" {
  statement {
    sid    = "AWSCloudTrailAclCheck20150319"
    effect = "Allow"

    actions = [
      "s3:GetBucketAcl",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail_s3_bucket.id}",
    ]
  }

  statement {
    sid    = "AWSCloudTrailWrite20150319"
    effect = "Allow"

    actions = [
      "s3:PutObject",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.cloudtrail_s3_bucket.id}/AWSLogs/${local.account_id}/*",
    ]

    condition {
      test     = "StringEquals"
      variable = "s3:x-amz-acl"

      values = [
        "bucket-owner-full-control",
      ]
    }
  }
}

resource "aws_s3_bucket_policy" "cloudtrail_s3_bucket_policy" {
  bucket = "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
  policy = "${data.aws_iam_policy_document.cloudtrail_s3_bucket_policy.json}"
}

resource "aws_s3_bucket" "application_s3_bucket" {
  bucket = "${var.application_s3_bucket_name}"
  acl    = "private"

  tags {
    Name        = "application s3 bucket"
    Environment = "${var.environment}"
  }

  force_destroy = true

  versioning {
    enabled = true
  }
}
