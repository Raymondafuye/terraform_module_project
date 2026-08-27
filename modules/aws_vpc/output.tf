output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr_block" {
  value = aws_vpc.main.cidr_block
}

output "internet_gateway_id" {
  value = aws_internet_gateway.gw.id
}

output "public_subnet_ids" {
  value = aws_subnet.public_subnets[*].id
}

output "private_subnet_ids" {
  value = aws_subnet.private_subnets[*].id
}

output "nat_gateway_ids" {
  value = aws_nat_gateway.nat_gw[*].id
}

output "nat_gateway_public_ips" {
  value = aws_eip.nat_gateways[*].public_ip
}

output "public_route_table_id" {
  value = aws_route_table.public_subnets.id
}

output "private_route_table_ids" {
  value = aws_route_table.private_subnets[*].id
}

output "web_security_group_id" {
  value = aws_security_group.web.id
}

output "rds_security_group_id" {
  value = aws_security_group.rds.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_service.id
}