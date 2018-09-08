resource "aws_cloudwatch_log_group" "cloudtrail_cloudwatch_log_group" {
  name = "CloudTrail/logs"

  tags {
    Name        = "CloudTrail/logs"
    Environment = "${var.environment}"
  }
}
