# RDS MYSQL database
resource "aws_db_instance" "2-tier-db-1" {
  allocated_storage           = 5
  storage_type                = "gp2"
  engine                      = "mysql"
  engine_version              = "5.7"
  instance_class              = "db.t2.micro"
  db_subnet_group_name        = aws_db_subnet_group.2tier-rds-sg
  vpc_security_group_ids      = [aws_security_group.2tier-db-sg.id]
  parameter_group_name        = "default.mysql5.7"
  db_name                     = "2tier_db1"
  username                    = "admin"
  password                    = "admin"
  skip_final_snapshot         = true
}