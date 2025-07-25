output "instance_ip" {
  value = aws_instance.springboot.public_ip
}

output "private_key" {
  value     = tls_private_key.deployer.private_key_pem
  sensitive = true
}

