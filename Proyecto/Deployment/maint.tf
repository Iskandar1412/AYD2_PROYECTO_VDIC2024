locals {
  vpc_id           = "vpc-0fe1841f4f0febc52"
  subnet_id        = "subnet-0ad32bc62280c5bb2"
  ssh_user         = "ubuntu"
  key_name         = "ec2key"
  private_key_path = "C:/work/ec2key.pem"
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_security_group" "frontend" {
  name   = "frontend_access"
  vpc_id = local.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 5173
    to_port     = 5173
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "frontend" {
  ami                         = "ami-036841078a4b68e14"
  subnet_id                   = local.subnet_id
  instance_type               = "t2.micro"
  key_name                    = local.key_name
  user_data     = <<-EOF
    #!/bin/bash
    echo "export GIT_TOKEN=${var.git_token}" >> /etc/environment
    EOF
  associate_public_ip_address = true
  security_groups             = [aws_security_group.frontend.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.frontend.public_ip
    }

    inline = [
        "sudo apt-get update",
        "sudo apt-get install -y software-properties-common",
        "sudo add-apt-repository --yes --update ppa:ansible/ansible",
        "sudo apt-get install -y ansible",
        "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
        "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
        "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" -y",
        "sudo apt-get update",
        "sudo apt-get install -y docker-ce docker-ce-cli containerd.io",
    ] 
  }

  
}

resource "null_resource" "config_ansible" {
  depends_on = [aws_instance.frontend]

  provisioner "file" {
    source      = "./ansible"
    destination = "/home/ubuntu/ansible"

    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.frontend.public_ip
    }
  }

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      user        = local.ssh_user
      private_key = file(local.private_key_path)
      host        = aws_instance.frontend.public_ip
    }
    
    inline = [
        "ansible-playbook /home/ubuntu/ansible/frontend.yaml"
    ]
  }
}

output "frontend_ip" {
  value = aws_instance.frontend.public_ip
}