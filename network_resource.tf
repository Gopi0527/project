resource "aws_vpc" "two_tier" {
    cidr_block = "10.0.0.0/16"
    tags = {
        Name = "two-tier-vpc"
    }
}

# Public Subnets
resource "aws_subnet" "pub-subnet1" {
    vpc_id = aws_vpc.two_tier
    cidr_block = "10.0.0.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip_on_launch = "true"
    tags = {
      Name = "pub-sub-1"
    }
}
resource "aws_subnet" "pub-subnet2" {
    vpc_id = aws_vpc.two_tier
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-southeast-1b"
    map_public_ip_on_launch = "true"
    tags = {
      Name = "pub-sub-2"
    }
}

# Private Subnets
resource "aws_subnet" "pvt-subnet1" {
    vpc_id = aws_vpc.two_tier
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-southeast-1a"
    map_public_ip_on_launch = "false"
    tags = {
      Name = "pvt-sub-1"
    }
}
resource "aws_subnet" "pvt-subnet2" {
    vpc_id = aws_vpc.two_tier
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-southeast-1b"
    map_public_ip_on_launch = "false"
    tags = {
      Name = "pvt-sub-2"
    }
}
# Internet gateway 
resource "aws_internet_gateway" "internetgateway" {
    vpc_id = aws_vpc.two_tier
    tags = {
        Name = "igw_2tier"
    }
}

#EIP

resource "aws_eip" "2tier-web-server-1-eip" {
  vpc = true

  instance                  = aws_instance.2-web-server-1.id
  depends_on                = [aws_internet_gateway.internetgateway]
}

resource "aws_eip" "2tier-web-server-2-eip" {
  vpc = true

  instance                  = aws_instance.2tier-web-server-2.id
  depends_on                = [aws_internet_gateway.internetgateway]
}

resource "aws_nat_gateway" "2tierNAT" {
  allocation_id = aws_eip.2tier-web-server-1-eip
  subnet_id     = aws_subnet.pub-subnet1

  tags = {
    Name = "gw NAT"
  }
    depends_on = [aws_internet_gateway.internetgateway]

}

resource "aws_nat_gateway" "rds.pvt" {
  connectivity_type = "private"
  subnet_id         = [aws_subnet.pvt-subnet1.id,aws_subnet.pvt-subnet2.id]
}
# Route Table
resource "aws_route_table" "2tier-route" {
    vpc_id = aws_vpc.two_tier
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.internetgateway
    }
}

# Route Table Assosiation

resource "aws_route_table_association" "rt-as-1" {
  subnet_id      = aws_subnet.pub-subnet1.id
  route_table_id = aws_route_table.2tier-route.id 
}
resource "aws_route_table_association" "rt-as-1" {
  subnet_id      = aws_subnet.pub-subnet2
  route_table_id = aws_route_table.2tier-route.id 
}

# create a Load Balencer
resource "aws_lb" "2tierlb" {
  name               = "2tier-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.2tier-alb-sg]
  subnets            =  [aws_subnet.pub-subnet1.id,aws_subnet.pub-subnet2]

  enable_deletion_protection = true
  tags = {
    Environment = "2tier-lb"
  }
}
# create a target group
resource "aws_lb_target_group" "2tier-lb-tg" {
  name     = "2tier-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.two_tier
}

# create a load balencer listener
resource "aws_lb_listener" "2tier-lb-listener" {
  load_balancer_arn = aws_lb.2tierlb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.2tier-lb-tg
  }
}

# create target Group 
 
resource "aws_lb_target_group" "2tier-lb-target" {
  name     = "target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.two_tier
  depends_on = [ aws_vpc.two_tier ]
}
# target group attachement
resource "aws_lb_target_group_attachment" "2tier-attch-1" {
  target_group_arn = aws_lb_target_group.2tier-lb-target.arn
  target_id        = aws_instance.2tier-webserver-1.id
  port             = 80
}
resource "aws_lb_target_group_attachment" "2tier-attch-2" {
  target_group_arn = aws_lb_target_group.2tier-lb-target.arn
  target_id        = aws_instance.2tier-webserver-2.id
  port             = 80
}
 
# create a subnetnet group for rds
resource "aws_db_subnet_group" "2tier-rds-sg" {
  name       = "2tier-rds-sg"
  subnet_ids = [aws_subnet.pvt-subnet1, aws_subnet.pvt-subnet2]

#   tags = {
#     Name = "My DB subnet group"
#   }
}