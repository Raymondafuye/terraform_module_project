# --- Core Pipeline network ---

module "aws_vpc" {
  source = "./modules/aws_vpc"
  vpc_name             = var.vpc_name
  vpc_cidr_block       = var.vpc_cidr_block
  azs                  = var.azs
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  single_nat_gateway   = var.single_nat_gateway
  ssh_allowed_cidrs    = var.ssh_allowed_cidrs
}

# --- IAM (shared across EC2 / ECS / Glue) ---

module "aws_iam_roles" {
  source = "./modules/aws_iam_roles"
  glue_raw_bucket_arn = module.raw_data_bucket.bucket_arn 
}

# --- General-purpose app bucket ---

module "aws_s3_bucket" {
  source = "./modules/aws_s3_bucket"
  bucket_name       = var.bucket_name
  enable_versioning = var.enable_bucket_versioning
}

# --- Data pipeline: S3 (raw) -> Glue Crawler -> Glue Data Catalog -> Athena ---
# so this project works fine with the pipeline on or off.
module "raw_data_bucket" {
  source = "./modules/aws_s3_bucket"
  bucket_name       = var.raw_bucket_name
  enable_versioning = true
  upload_source_dir  = var.upload_sample_data ? var.sample_data_dir : null
}

module "athena_results_bucket" {
  source = "./modules/aws_s3_bucket"

  bucket_name       = var.athena_results_bucket_name
  enable_versioning = false
}

module "aws_glue" {
  source = "./modules/aws_glue"

  database_name    = var.glue_database_name
  crawler_name     = var.glue_crawler_name
  crawler_schedule = var.glue_crawler_schedule
  raw_bucket_name  = module.raw_data_bucket.bucket_id
  raw_data_prefix  = var.raw_data_prefix
  glue_role_arn    = module.aws_iam_roles.glue_crawler_role_arn
}

module "aws_athena" {
  source = "./modules/aws_athena"

  workgroup_name      = var.athena_workgroup_name
  results_bucket_name = module.athena_results_bucket.bucket_id
}