variable "instance_type" {
  type = string
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "subnet_id" {
  type = string
}

variable "security_group_id" {
  description = "Security group ID from the aws_vpc module"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM instance profile name to attach (from aws_iam_roles module)"
  type        = string
  default     = null
}