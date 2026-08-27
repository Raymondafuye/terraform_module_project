resource "aws_s3_bucket" "this" {
  bucket = "${terraform.workspace}-${var.bucket_name}"

  tags = {
    Name        = "${terraform.workspace}-${var.bucket_name}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Suspended"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Get all files from the local directory
locals {
  upload_files = fileset(var.upload_source_dir, "**")

  content_types = {
    csv     = "text/csv"
    json    = "application/json"
    parquet = "application/octet-stream"
    txt     = "text/plain"
  }
}

# Upload each file to S3 bucket
resource "aws_s3_object" "uploaded" {
  for_each = toset(local.upload_files)

  bucket       = aws_s3_bucket.this.id
  key          = "${var.upload_dest_prefix}${each.value}"
  source       = "${var.upload_source_dir}/${each.value}"
  etag         = filemd5("${var.upload_source_dir}/${each.value}")
  content_type = lookup(local.content_types, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
}