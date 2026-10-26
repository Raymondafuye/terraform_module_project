aws_region = "us-east-1"

# VPC
vpc_name             = "myapp"
vpc_cidr_block       = "10.0.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.11.0/24", "10.0.12.0/24"]
ssh_allowed_cidrs = ["0.0.0.0/0"]
single_nat_gateway   = true

# S3 (general app bucket)
bucket_name              = "my-app-bucket-rmd"
enable_bucket_versioning = false


# Data pipeline
raw_bucket_name            = "rmd-cob-raw-data"
athena_results_bucket_name = "rmd-cob-athena-results"
raw_data_prefix            = "data/"
glue_crawler_schedule      = ""
upload_sample_data         = true
upload_dest_prefix = var.raw_data_prefix
sample_data_dir            = "./myfiles"