# Athena Workgroup — where query settings live, and where query results get written
resource "aws_athena_workgroup" "this" {
  name = "${terraform.workspace}-${var.workgroup_name}"

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${var.results_bucket_name}/output/"

      encryption_configuration {
        encryption_option = "SSE_S3"
      }
    }
  }

  tags = {
    Environment = terraform.workspace
  }
}