aws_region = "us-east-1"

# VPC
vpc_name             = "myapp"
vpc_cidr_block       = "10.1.0.0/16"
azs                  = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.1.1.0/24", "10.1.2.0/24"]
private_subnet_cidrs = ["10.1.11.0/24", "10.1.12.0/24"]
single_nat_gateway   = true


# S3 (general app bucket)
bucket_name              = "my-app-bucket"
enable_bucket_versioning = true

# Data pipeline
enable_data_pipeline       = false
raw_bucket_name            = "raw-data"
athena_results_bucket_name = "athena-results"
raw_data_prefix            = "data/"
glue_crawler_schedule      = ""