# Provider da AWS
provider "aws" {
  region = "us-east-1"  # Altere para a sua região
}

# Criação da VPC
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main-VPC"
  }
}

# Criação da Subnet
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main-Subnet"
  }
}

# Criação do Security Group
resource "aws_security_group" "main_sg" {
  vpc_id = aws_vpc.main_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Abra o SSH para todos (melhor prática: restrinja a IP específico)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Main-SG"
  }
}

# Criação da Key Pair
resource "tls_private_key" "main_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "deployer_key" {
  key_name   = "deployer-key"
  public_key = tls_private_key.main_key.public_key_openssh
}

# Criação da instância EC2
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"  # Altere para um AMI válido na sua região
  instance_type = "t2.micro"
  key_name      = aws_key_pair.deployer_key.key_name
  subnet_id     = aws_subnet.main_subnet.id
  security_groups = [aws_security_group.main_sg.name]

  # Automação para instalar o Nginx
  user_data = <<-EOF
              #!/bin/bash
              sudo apt update
              sudo apt install -y nginx
              sudo systemctl start nginx
              EOF

  tags = {
    Name = "Web-Server"
  }
}