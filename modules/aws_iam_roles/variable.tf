variable "glue_raw_bucket_arn" {
  description = "ARN of the S3 bucket Glue needs read/write access to (required if enable_glue_role = true)"
  type        = string
  default     = null
}