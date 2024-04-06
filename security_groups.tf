# Security Group
resource "aws_security_group" "2tier-ec2-sg" {
  name        = "2tier-ec2-sg"
  description = "Allow traffic from VPC"
  vpc_id      = aws_vpc.two_tier
  depends_on = [
    aws_vpc.two_tier
  ]

  ingress {
    from_port = "0"
    to_port   = "0"
    protocol  = "-1"
  }
  ingress {
    from_port   = "80"
    to_port     = "80"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = "22"
    to_port     = "22"
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "2tier-ec2-sg"
  }
}

# Load balancer security group
resource "aws_security_group" "2tier-alb-sg" {
  name        = "2tier-alb-sg"
  description = "load balancer security group"
  vpc_id      = aws_vpc.two_tier
  depends_on = [
    aws_vpc.two_tier
  ]


  ingress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = "0"
    to_port     = "0"
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = {
    Name = "2tier-alb-sg"
  }
}

# Database tier Security gruop
resource "aws_security_group" "2tier-db-sg" {
  name        = "2tier-db-sg"
  description = "allow traffic from internet"
  vpc_id      = aws_vpc.two_tier

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.2tier-ec2-sg.id]
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.2tier-ec2-sg.id]
    cidr_blocks     = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}