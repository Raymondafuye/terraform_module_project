# Glue Data Catalog database — the metadata store the crawler writes schema/partitions into
resource "aws_glue_catalog_database" "this" {
  name        = "${terraform.workspace}_${var.database_name}"
  description = "Catalog database for ${terraform.workspace}"
}

# Glue Crawler — scans the given S3 path, infers schema, and populates the catalog database above
resource "aws_glue_crawler" "this" {
  name          = "${terraform.workspace}-${var.crawler_name}"
  role          = var.glue_role_arn
  database_name = aws_glue_catalog_database.this.name
  schedule      = var.crawler_schedule != "" ? var.crawler_schedule : null

  s3_target {
    path = "s3://${var.raw_bucket_name}/${var.raw_data_prefix}"
  }

  configuration = jsonencode({
    Version = 1.0
    Grouping = {
      TableGroupingPolicy = "CombineCompatibleSchemas"
    }
  })

  tags = {
    Environment = terraform.workspace
  }
}

