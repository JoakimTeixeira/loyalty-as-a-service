resource "aws_instance" "discountCouponQuarkus" {
  # ami = "ami-0cd7323ab3e63805f" # Amazon Linux ARM AMI built by Amazon Web Services - FOR DOCKER image COMPATIBILITY
  # alternative ami for Amazon Linux x86 built by Amazon Web Services  
  ami = "ami-0d7a109bf30624c99"
  # instance_type           = "c6g.medium"
  # alternative instance_type for Amazon Linux x86 built by Amazon Web Services  
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = "vockey"

  user_data = base64encode(templatefile("./quarkus.sh", {
    dockerhub_username = "${var.dockerhub_username}",
    dockerhub_password = "${var.dockerhub_password}",
  }))

  user_data_replace_on_change = true

  tags = {
    Name = "Quarkus-discountcoupon"
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
