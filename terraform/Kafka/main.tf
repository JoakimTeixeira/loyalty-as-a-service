resource "aws_instance" "kafkaCluster" {
  ami           = "ami-0cf10cdf9fcd62d37"
  instance_type = "t2.small"

  count = var.nBroker

  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name               = "vockey"

  user_data = base64encode(templatefile("creation.sh", {
    idBroker     = "${count.index + 1}"
    totalBrokers = var.nBroker
  }))

  user_data_replace_on_change = true

  tags = {
    Name = "kafka-broker.${count.index + 1}"
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("vockey.pem")
    host        = self.public_dns
  }

  provisioner "file" {
    source      = "LaaSSimulator.jar"
    destination = "/home/ec2-user/LaaSSimulator.jar"
  }
}

# Configures Kafka and Zookeeper
resource "null_resource" "configure_kafka_and_zookeeper" {
  depends_on = [aws_instance.kafkaCluster]
  count      = length(aws_instance.kafkaCluster)

  connection {
    type        = "ssh"
    host        = element(aws_instance.kafkaCluster[*].public_dns, count.index)
    user        = "ec2-user"
    private_key = file("vockey.pem")
  }

  provisioner "remote-exec" {
    inline = [
      "export ALL_PUBLIC_DNS=${join(",", aws_instance.kafkaCluster[*].public_dns)}",
      "export TOTAL_BROKERS=${var.nBroker}",
      "${file("configure.sh")}"
    ]
  }
}


resource "aws_security_group" "instance" {
  name = var.security_group_name

  # SSH port
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Kafka port
  ingress {
    from_port   = 2181
    to_port     = 2181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ZooKeeper's peer-to-peer (server nodes) communication protocol
  # Nodes communicate to elect a new leader
  ingress {
    from_port   = 2888
    to_port     = 2888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ZooKeeper's leader election protocol
  # Communication between leader and node followers during election
  ingress {
    from_port   = 3888
    to_port     = 3888
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Zookeeper port
  ingress {
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Anywhere port
  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

