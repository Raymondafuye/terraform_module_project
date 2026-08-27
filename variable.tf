variable "aws_region" {
  type    = string
  default = "us-east-1"
}

# --- VPC ---
variable "vpc_name" {
  type = string
}

variable "vpc_cidr_block" {
  type = string
}

variable "azs" {
  type        = list(string)
  description = "Availability Zones"
}

variable "public_subnet_cidrs" {
  type = list(string)
}

variable "private_subnet_cidrs" {
  type = list(string)
}

variable "single_nat_gateway" {
  type    = bool
  default = false
}

variable "ssh_allowed_cidrs"{
  description = "CIDR blocks allowed to SSH into web instances"
  type        = list(string)
  default     = []
}

# --- S3 (general app bucket) ---
variable "bucket_name" {
  type = string
}

variable "enable_bucket_versioning" {
  type    = bool
  default = true
}


# --- Data pipeline (S3 -> Glue -> Athena) ---

variable "raw_bucket_name" {
  description = "Base name for the raw data bucket (required if enable_data_pipeline = true)"
  type        = string
  default     = "raw-data"
}

variable "athena_results_bucket_name" {
  description = "Base name for the Athena results bucket (required if enable_data_pipeline = true)"
  type        = string
  default     = "athena-results"
}

variable "raw_data_prefix" {
  type    = string
  default = "data/"
}


variable "upload_sample_data" {
  description = "Set true to upload ./sample-data into the raw bucket (useful for testing the pipeline)"
  type        = bool
  default     = true
}

variable "sample_data_dir" {
  description = "Exact local folder path to upload into the raw data bucket. Only used when upload_sample_data = true."
  type        = string
}

variable "glue_database_name" {
  type    = string
  default = "raw_data_catalog"
}

variable "glue_crawler_name" {
  type    = string
  default = "raw-data-crawler"
}

variable "glue_crawler_schedule" {
  description = "Cron expression, e.g. 'cron(0 6 * * ? *)'. Empty string means on-demand only."
  type        = string
  default     = ""
}

variable "athena_workgroup_name" {
  type    = string
  default = "analytics-workgroup"
}