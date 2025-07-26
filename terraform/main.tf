provider "aws" {
  region = "ap-south-1"
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "aws_security_group" "ssh_access" {
  name        = "allow_ssh_mithilesh"
  description = "Allow SSH access"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # ⚠️ Open to all — secure this in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "springboot" {
  ami                         = "ami-0d0ad8bb301edb745" # Amazon Linux 2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.ssh_access.id]

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum install -y wget",
      "sudo rpm --import https://yum.corretto.aws/corretto.key",
      "sudo curl -L -o /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo",
      "sudo yum install -y java-17-amazon-corretto-devel",
      "java -version"
    ]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = tls_private_key.deployer.private_key_pem
    host        = self.public_ip
  }
}
resource "local_file" "private_key_file" {
  content  = tls_private_key.deployer.private_key_pem
  filename = "${path.module}/deployer.pem"
  file_permission = "0400"
}