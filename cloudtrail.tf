resource "aws_cloudtrail" "application_bucket_logging_cloudtrail" {
  name           = "application_bucket_logging_cloudtrail"
  s3_bucket_name = "${aws_s3_bucket.cloudtrail_s3_bucket.id}"
  s3_key_prefix  = ""

  cloud_watch_logs_role_arn  = "${aws_iam_role.application_bucket_logging_cloudtrail_iam_role.arn}"
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudtrail_cloudwatch_log_group.arn}"

  enable_logging                = true
  include_global_service_events = false
  is_multi_region_trail         = false
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "WriteOnly"
    include_management_events = false

    # https://docs.aws.amazon.com/awscloudtrail/latest/APIReference/API_DataResource.html
    data_resource {
      type = "AWS::S3::Object"

      values = [
        "arn:aws:s3:::${aws_s3_bucket.application_s3_bucket.id}/",
      ]
    }
  }

  tags {
    Name        = "application bucket logging cloudtrail"
    Environment = "${var.environment}"
  }

  # https://github.com/hashicorp/terraform/issues/6388
  depends_on = []

  //    "aws_s3_bucket_policy.cloudtrail_s3_bucket_policy",
}

# https://docs.aws.amazon.com/awscloudtrail/latest/userguide/send-cloudtrail-events-to-cloudwatch-logs.html

data "aws_iam_policy_document" "application_bucket_logging_cloudtrail_assume_role_iam_policy_document" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]

    principals {
      type = "Service"

      identifiers = [
        "cloudtrail.amazonaws.com",
      ]
    }
  }
}

resource "aws_iam_role" "application_bucket_logging_cloudtrail_iam_role" {
  name = "application_bucket_logging_cloudtrail_iam_role"

  assume_role_policy = "${data.aws_iam_policy_document.application_bucket_logging_cloudtrail_assume_role_iam_policy_document.json}"
}

data "aws_iam_policy_document" "application_bucket_logging_cloudtrail_policy_document" {
  statement {
    sid    = "AWSCloudTrailCreateLogStream2014110"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
    ]

    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_cloudwatch_log_group.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${local.region}*",
    ]
  }

  statement {
    sid    = "AWSCloudTrailPutLogEvents20141101"
    effect = "Allow"

    actions = [
      "logs:PutLogEvents",
    ]

    resources = [
      "arn:aws:logs:${local.region}:${data.aws_caller_identity.current.account_id}:log-group:${aws_cloudwatch_log_group.cloudtrail_cloudwatch_log_group.name}:log-stream:${data.aws_caller_identity.current.account_id}_CloudTrail_${local.region}*",
    ]
  }
}

resource "aws_iam_policy" "application_bucket_logging_cloudtrail_policy" {
  name   = "application_bucket_logging_cloudtrail_policy"
  policy = "${data.aws_iam_policy_document.application_bucket_logging_cloudtrail_policy_document.json}"
}

resource "aws_iam_role_policy_attachment" "application_bucket_logging_cloudtrail_iam_role_policy_attachment" {
  role       = "${aws_iam_role.application_bucket_logging_cloudtrail_iam_role.name}"
  policy_arn = "${aws_iam_policy.application_bucket_logging_cloudtrail_policy.arn}"
}
