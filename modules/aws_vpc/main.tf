resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name        = "${var.vpc_name}-VPC"
    Environment = terraform.workspace
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name        = "${var.vpc_name}-ig"
    Environment = terraform.workspace
  }
}

# --- Subnets ---

resource "aws_subnet" "public_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.public_subnet_cidrs, count.index)

  map_public_ip_on_launch = true

  tags = {
    Name        = "${terraform.workspace}-public-subnet-${count.index + 1}"
    Environment = terraform.workspace
  }
}

resource "aws_subnet" "private_subnets" {
  count             = length(var.azs)
  vpc_id            = aws_vpc.main.id
  availability_zone = element(var.azs, count.index)
  cidr_block        = element(var.private_subnet_cidrs, count.index)

  tags = {
    Name        = "${terraform.workspace}-private-subnet-${count.index + 1}"
    Environment = terraform.workspace
  }
}

# --- NAT Gateway ---

resource "aws_eip" "nat_gateways" {
  count  = var.single_nat_gateway ? 1 : length(var.azs)
  domain = "vpc"

  tags = {
    Name        = "${terraform.workspace}-nat-eip-${count.index + 1}"
    Environment = terraform.workspace
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = var.single_nat_gateway ? 1 : length(var.azs)
  allocation_id = aws_eip.nat_gateways[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name        = "${terraform.workspace}-nat-gw-${count.index + 1}"
    Environment = terraform.workspace
  }

  depends_on = [aws_internet_gateway.gw]
}

# --- Route Tables ---

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name        = "${terraform.workspace}-public-rt"
    Environment = terraform.workspace
  }
}

resource "aws_route_table_association" "public_subnet_asso" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_subnets.id
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.azs)
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.single_nat_gateway ? aws_nat_gateway.nat_gw[0].id : aws_nat_gateway.nat_gw[count.index].id
  }

  tags = {
    Name        = "${terraform.workspace}-private-rt-${count.index + 1}"
    Environment = terraform.workspace
  }
}

resource "aws_route_table_association" "private_subnet_asso" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_subnets[count.index].id
}

# --- Security Groups ---

resource "aws_security_group" "web" {
  name_prefix = "${terraform.workspace}-web-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.ssh_allowed_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-web-sg"
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "rds" {
  name_prefix = "${terraform.workspace}-rds-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "DB access from within VPC"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-rds-sg"
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "ecs_service" {
  name_prefix = "${terraform.workspace}-ecs-sg-"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "Container port"
    from_port   = var.container_port
    to_port     = var.container_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${terraform.workspace}-ecs-sg"
    Environment = terraform.workspace
  }

  lifecycle {
    create_before_destroy = true
  }
}