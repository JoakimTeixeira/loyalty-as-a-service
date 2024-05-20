output "publicdnslist" {
  value = formatlist("%v", aws_instance.kafkaCluster.*.public_dns)
}
