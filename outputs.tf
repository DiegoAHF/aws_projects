output "vpc_id" {
  description = "ID of the VPC created"
  value = aws_vpc.lab.id
}

output "priv_subnet_id" {
  description = "ID of the private subnet created"
  value = aws_subnet.priv.id
}

output "pub_subnet_id" {
  description = "ID of the public subnet created"
  value = aws_subnet.pub.id
}

output "priv_subnet_arn" {
  description = "ARN of the private subnet created"
  value = aws_subnet.priv.arn
}

output "pub_subnet_arn" {
  description = "ARN of the public subnet created"
  value = aws_subnet.pub.arn
}

