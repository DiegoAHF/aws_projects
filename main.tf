
#VPC configuration

resource "aws_vpc" "lab" {
  cidr_block = var.vpc_block

  tags = {
    Name = "Testing Lab"
  }
}

resource "aws_subnet" "priv" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = var.priv_block
  availability_zone = var.az

  tags = {
    Name = "Private Subnet"
  }
}

resource "aws_subnet" "pub" {
  vpc_id            = aws_vpc.lab.id
  cidr_block        = var.pub_block
  availability_zone = var.az

  tags = {
    Name = "Public Subnet"
  }
}

#IGW configuration

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "Internet Gateway"
  }
}

#NAT Gateway configuration

resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "NAT EIP"
  }
}

resource "aws_nat_gateway" "natgw" {
  allocation_id = aws_eip.eip.id
  subnet_id     = aws_subnet.pub.id

  tags = {
    Name = "NAT Gateway"
  }
}

#Route tables

resource "aws_route_table" "pub" {
  vpc_id = aws_vpc.lab.id

  route {
    cidr_block = var.def_route
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table" "priv" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name = "Private Route Table"
  }

  route {
    cidr_block     = var.def_route
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "pub" {
  subnet_id      = aws_subnet.pub.id
  route_table_id = aws_route_table.pub.id
}

resource "aws_route_table_association" "priv" {
  subnet_id      = aws_subnet.priv.id
  route_table_id = aws_route_table.priv.id
}

#Security Group configuration

resource "aws_security_group" "sg" {
  name        = "lab-sg"
  description = "Security group to allow SSH and HTTPS access"
  vpc_id      = aws_vpc.lab.id
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  from_port         = 22
  to_port           = 22
  ip_protocol       = "tcp"
  cidr_ipv4         = var.sg_ip
  security_group_id = aws_security_group.sg.id

  tags = {
    Name = "Allow SSH from VPC"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  from_port         = 443
  to_port           = 443
  ip_protocol       = "tcp"
  cidr_ipv4         = var.sg_ip
  security_group_id = aws_security_group.sg.id

  tags = {
    Name = "Allow HTTPS from VPC"
  }
}

resource "aws_vpc_security_group_egress_rule" "all" {
  ip_protocol       = "-1"
  cidr_ipv4         = var.def_route
  security_group_id = aws_security_group.sg.id

  tags = {
    Name = "Allow All Egress from VPC"
  }
}

#EC2 Instance configuration

resource "aws_instance" "server" {
  ami                    = var.ec2_ami
  instance_type          = var.ec2_type
  subnet_id              = aws_subnet.priv.id
  vpc_security_group_ids = [aws_security_group.sg.id]

  tags = {
    Name = "Testing Server"
  }
}

resource "aws_ec2_instance_connect_endpoint" "connect" {
  subnet_id = aws_subnet.priv.id

  tags = {
    Name = "EC2 Instance Connect Endpoint"
  }
}

#Alarm and Dashboard configuration

resource "aws_cloudwatch_metric_alarm" "cpu_alarm" {
  alarm_name          = "High CPU Utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    InstanceId = aws_instance.server.id
  }

  alarm_description = "This metric monitors EC2 CPU utilization"
  alarm_actions     = [aws_sns_topic.alarm.arn]
}

resource "aws_sns_topic" "alarm" {
  name = "cpu-alarm-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.alarm.arn
  protocol  = "email"
  endpoint  = var.sns_endpoint
}

resource "aws_cloudwatch_dashboard" "dashboard" {
  dashboard_name = "EC2_Monitoring"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", aws_instance.server.id]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-2"
          title  = "EC2 CPU Utilization"
        }

      },
      {
        type = "alarm"
        properties = {
          alarms = [aws_cloudwatch_metric_alarm.cpu_alarm.arn]
          title  = "CPU Utilization Alarm"
        }
      }
    ]
  })
}
