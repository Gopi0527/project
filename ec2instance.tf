# Public subnet EC2 instance 1
resource "aws_instance" "2-web-server-1" {
  ami             = "ami-"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.2tier-ec2-sg.id]
  subnet_id       = aws_subnet.pub-subnet2.id
  key_name   = "2tier-key"

  tags = {
    Name = "2tier-web-server-1"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

# Public subnet  EC2 instance 2
resource "aws_instance" "2tier-web-server-2" {
  ami             = "ami-"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.2tier-ec2-sg]
  subnet_id       = aws_subnet.pub-subnet2.id
  key_name   = "2tier-key"

  tags = {
    Name = "2tier-web-server-2"
  }

  user_data = <<-EOF
#!/bin/bash
sudo yum update -y
sudo amazon-linux-extras install nginx1 -y 
sudo systemctl enable nginx
sudo systemctl start nginx
EOF
}

#EIP

# resource "aws_eip" "2tier-web-server-1-eip" {
#   vpc = true
 
#   instance                  = aws_instance.2-web-server-1.id
#   depends_on                = [aws_internet_gateway.internetgateway]
# }

# resource "aws_eip" "two-tier-web-server-2-eip" {
#   vpc = true

#   instance                  = aws_instance.2tier-web-server-2
#   depends_on                = [aws_internet_gateway.internetgateway]
# }