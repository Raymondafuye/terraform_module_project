variable "database_name" {
  description = "Name of the Glue Catalog database (will be prefixed with workspace)"
  type        = string
  default     = "raw_data_catalog"
}

variable "crawler_name" {
  description = "Name of the Glue Crawler"
  type        = string
  default     = "raw-data-crawler"
}

variable "crawler_schedule" {
  description = "Cron expression, e.g. 'cron(0 6 * * ? *)'. Empty string means on-demand only."
  type        = string
  default     = ""
}

variable "raw_bucket_name" {
  description = "Name of the S3 bucket the crawler should scan (from an aws_s3_bucket module call)"
  type        = string
}

variable "raw_data_prefix" {
  description = "Folder prefix inside the bucket to scan, e.g. 'data/'"
  type        = string
  default     = "data/"
}

variable "glue_role_arn" {
  description = "IAM role ARN the crawler assumes (from the aws_iam_roles module)"
  type        = string
}