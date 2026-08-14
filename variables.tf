variable "vpc_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/24"
  
}

variable "priv_block" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "172.16.0.0/28"
}

variable "pub_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "172.16.0.16/28"
}

variable "az" {
  description = "The availability zone for the subnets"
  type        = string
  default     = "us-east-2a"
}

variable "def_route" {
  description = "The default route for IGW and NATGW. Outbound traffic for sg"
  type        = string
  default     = "0.0.0.0/0"
}

variable "sg_ip" {
  description = "The security group IP for inbound access"
  type        = string
  default     = "X.X.X.X/32" #Specify your own IP address here
}

variable "ec2_ami" {
  description = "The AMI ID for the EC2 instance"
  type        = string
  default     = "ami-0e5497a77ef21b5ac" #Specify your own AMI ID here
}

variable "ec2_type" {
  description = "The instance type for the EC2 instance"
  type        = string
  default     = "t3.micro" #Specify your own instance type here
}

variable "sns_endpoint" {
  description = "The SNS endpoint for notifications"
  type        = string
  default     = "example@gmail.com" #Specify your own SNS endpoint here
}

