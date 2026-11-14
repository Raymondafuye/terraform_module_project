output "vpc_id" {
  value = module.aws_vpc.vpc_id
}

output "s3_bucket_id" {
  value = module.aws_s3_bucket.bucket_id
}

# --- Data pipeline outputs (null if enable_data_pipeline = false) ---

output "raw_bucket_id" {
  value = module.raw_data_bucket.bucket_id
}

output "glue_database_name" {
  value = module.aws_glue.database_name
}

output "glue_crawler_name" {
  value = module.aws_glue.crawler_name
}

output "athena_workgroup_name" {
  value = module.aws_athena.workgroup_name
}