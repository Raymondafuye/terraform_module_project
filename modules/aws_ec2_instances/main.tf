data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # This helps to streamline to Canonical owners account

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_instance" "web" {
  count                  = var.instance_count
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile   = var.iam_instance_profile_name

  tags = {
    Name        = "${terraform.workspace}-web-server-${count.index}"
    Environment = terraform.workspace
    ManagedBy   = "terraform"
  }
}