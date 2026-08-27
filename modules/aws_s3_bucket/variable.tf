variable "bucket_name" {
  description = "Base bucket name, will be prefixed with the workspace name"
  type        = string
}

variable "enable_versioning" {
  type    = bool
  default = true
}


variable "upload_dest_prefix" {
  description = "S3 key prefix to upload files under, e.g. 'raw/'"
  type        = string
  default     = ""
}

variable "upload_source_dir" {
  description = "Local folder to upload into this bucket, preserving relative paths (e.g. './sample-data'). Defaults to an empty folder, which uploads nothing."
  type        = string
  default     = "./modules/aws_s3_bucket/empty"
}