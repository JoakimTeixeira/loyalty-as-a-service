resource "aws_instance" "installCamundaEngine" {
  ami                    = "ami-0b5eea76982371e91"
  instance_type          = "t2.small"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = "vockey"

  user_data = file("deploy.sh")

  user_data_replace_on_change = true

  tags = {
    Name = "terraform-example-Camunda"
  }
}

resource "aws_security_group" "instance" {
  name = var.security_group_name

  ingress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

