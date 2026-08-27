variable "workgroup_name" {
  description = "Name of the Athena workgroup"
  type        = string
  default     = "rmd-analytics-workgroup"
}

variable "results_bucket_name" {
  description = "Name of the S3 bucket where query results are written (from an aws_s3_bucket module call)"
  type        = string
}