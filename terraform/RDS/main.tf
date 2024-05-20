resource "aws_db_instance" "rds_db" {
  identifier_prefix      = "terraform-up-and-running"
  engine                 = "mysql"
  allocated_storage      = 20
  instance_class         = "db.t3.micro"
  skip_final_snapshot    = true
  publicly_accessible    = true
  vpc_security_group_ids = [aws_security_group.rds.id]
  db_name                = var.db_name

  username = var.db_username
  password = var.db_password
}

resource "aws_security_group" "rds" {
  name = var.security_group_name

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}
