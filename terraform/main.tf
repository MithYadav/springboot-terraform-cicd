provider "aws" {
  region = "ap-south-1"
}

resource "tls_private_key" "deployer" {
  algorithm = "RSA"
}

resource "aws_key_pair" "deployer" {
  key_name   = "deployer"
  public_key = tls_private_key.deployer.public_key_openssh
}

resource "aws_instance" "springboot" {
  ami                         = "ami-0c55b159cbfafe1f0" # Amazon Linux 2
  instance_type               = "t2.micro"
  key_name                    = aws_key_pair.deployer.key_name
  associate_public_ip_address = true

  provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo amazon-linux-extras install java-openjdk11 -y"
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = tls_private_key.deployer.private_key_pem
      host        = self.public_ip
    }
  }
}
