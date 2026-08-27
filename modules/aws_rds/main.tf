resource "aws_db_subnet_group" "this" {
  name       = "${terraform.workspace}-db-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Environment = terraform.workspace
  }
}


resource "aws_db_instance" "this" {
  identifier              = "${terraform.workspace}-db"
  engine                  = var.engine
  engine_version          = var.engine_version
  instance_class          = var.db_instance_class
  allocated_storage       = var.allocated_storage
  db_name                 = var.db_name
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.this.name
  vpc_security_group_ids  = [var.security_group_id]
  port                    = var.db_port
  multi_az                = var.multi_az
  skip_final_snapshot     = var.skip_final_snapshot
  publicly_accessible     = false
  storage_encrypted       = true
  backup_retention_period = var.backup_retention_period

  tags = {
    Name        = "${terraform.workspace}-db"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}