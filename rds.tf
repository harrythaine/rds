#test
provider "aws" {
  region = "eu-west-2"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/22"
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "your_preferred_az"
  map_public_ip_on_launch = true
}

resource "aws_security_group" "rds_sg" {
  vpc_id = aws_vpc.main.id
  // Add inbound and outbound rules as needed for your application
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "ecommerce-db-subnet-group"
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_iam_role" "rds_role" {
  name = "ecommerce-rds-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "rds.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_db_parameter_group" "rds_parameter_group" {
  name        = "ecommerce-db-param-group"
  family      = "mysql5.7"
  description = "Custom parameter group for enhanced security"

  parameter {
    name  = "require_secure_transport"
    value = "1"
  }

  // Add more parameters as needed
}

resource "aws_db_instance" "rds_instance" {
  identifier           = "ecommerce-rds"
  allocated_storage    = 100
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  name                 = "ecommerce-db"
  username             = "admin"
  password             = "your_password"
  multi_az             = true
  publicly_accessible = false
  db_subnet_group_name = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  iam_database_authentication_enabled = true
  iam_roles = [aws_iam_role.rds_role.name]
  parameter_group_name = aws_db_parameter_group.rds_parameter_group.name
  kms_key_id = aws_kms_key.rds_key.arn
}

resource "aws_kms_key" "rds_key" {
  description             = "Key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true
}