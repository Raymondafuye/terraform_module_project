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
  type        = list(string)
  description = "Public Subnet CIDR"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "Private Subnet CIDR"
}

variable "single_nat_gateway" {
  description = "If true, creates one shared NAT Gateway instead of one per AZ"
  type        = bool
  default     = false
}

variable "ssh_allowed_cidrs" {
  description = "CIDR blocks allowed to SSH into web instances"
  type        = list(string)
  default     = []
}

variable "db_port" {
  description = "Port the RDS security group should allow"
  type        = number
  default     = 5432
}

variable "container_port" {
  description = "Port the ECS security group should allow"
  type        = number
  default     = 80
}