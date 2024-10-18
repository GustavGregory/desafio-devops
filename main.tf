# Definindo o provedor da AWS e a região
provider "aws" {
  region = "us-east-1"  # Região us-east-1 (Norte da Virgínia)
}

# Variável para o nome do projeto
variable "projeto" {
  description = "Nome do projeto"
  type        = string
  default     = "VExpenses"
}

# Variável para o nome do candidato
variable "candidato" {
  description = "Nome do candidato"
  type        = string
  default     = "SeuNome"
}

# Gerando uma chave privada TLS para acessar a instância EC2
resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"     # Algoritmo RSA
  rsa_bits  = 2048      # Tamanho da chave de 2048 bits
}

# Criando um par de chaves (Key Pair) com a chave pública gerada acima
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "${var.projeto}-${var.candidato}-key"  # Nome do par de chaves
  public_key = tls_private_key.ec2_key.public_key_openssh  # Chave pública para acesso SSH
}

# Criando uma VPC (Virtual Private Cloud)
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"  # Bloco CIDR da VPC
  enable_dns_support   = true           # Habilitar suporte DNS
  enable_dns_hostnames = true           # Habilitar nomes de host DNS

  tags = {
    Name = "${var.projeto}-${var.candidato}-vpc"  # Tag para identificação da VPC
  }
}

# Criando uma Subnet dentro da VPC
resource "aws_subnet" "main_subnet" {
  vpc_id            = aws_vpc.main_vpc.id    # ID da VPC onde a Subnet será criada
  cidr_block        = "10.0.1.0/24"          # Bloco CIDR da Subnet
  availability_zone = "us-east-1a"           # Zona de disponibilidade us-east-1a

  tags = {
    Name = "${var.projeto}-${var.candidato}-subnet"  # Tag para identificação da Subnet
  }
}

# Criando um Internet Gateway para conectar a VPC à Internet
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main_vpc.id  # ID da VPC à qual o Internet Gateway será associado

  tags = {
    Name = "${var.projeto}-${var.candidato}-igw"  # Tag para identificação do Internet Gateway
  }
}

# Criando uma Tabela de Rotas para a VPC
resource "aws_route_table" "main_route_table" {
  vpc_id = aws_vpc.main_vpc.id  # ID da VPC à qual a Tabela de Rotas será associada

  # Definindo uma rota padrão para o tráfego de saída para a Internet
  route {
    cidr_block = "0.0.0.0/0"               # Todo o tráfego de saída
    gateway_id = aws_internet_gateway.main_igw.id  # Rota pelo Internet Gateway
  }

  tags = {
    Name = "${var.projeto}-${var.candidato}-route_table"  # Tag para identificação da Tabela de Rotas
  }
}

# Associando a Tabela de Rotas à Subnet
resource "aws_route_table_association" "main_association" {
  subnet_id      = aws_subnet.main_subnet.id         # ID da Subnet que será associada à Tabela de Rotas
  route_table_id = aws_route_table.main_route_table.id  # ID da Tabela de Rotas associada

  tags = {
    Name = "${var.projeto}-${var.candidato}-route_table_association"  # Tag para identificação da associação
  }
}

# Criando um Security Group (Grupo de Segurança) para a instância EC2
resource "aws_security_group" "main_sg" {
  name        = "${var.projeto}-${var.candidato}-sg"  # Nome do Security Group
  description = "Permitir SSH de qualquer lugar e todo o tráfego de saída"
  vpc_id      = aws_vpc.main_vpc.id  # ID da VPC à qual o Security Group será associado

  # Regras de entrada (Ingress)
  ingress {
    description      = "Allow SSH from anywhere"  # Permitir SSH de qualquer lugar (pode ser melhorado)
    from_port        = 22                         # Porta SSH
    to_port          = 22                         # Porta SSH
    protocol         = "tcp"                      # Protocolo TCP
    cidr_blocks      = ["0.0.0.0/0"]              # Acesso aberto a todos (pode ser melhorado para restrição por IP)
    ipv6_cidr_blocks = ["::/0"]                   # Acesso IPv6 aberto a todos
  }

  # Regras de saída (Egress)
  egress {
    description      = "Allow all outbound traffic"  # Permitir todo o tráfego de saída
    from_port        = 0                             # Todas as portas
    to_port          = 0                             # Todas as portas
    protocol         = "-1"                          # Todos os protocolos
    cidr_blocks      = ["0.0.0.0/0"]                 # Todo o tráfego
    ipv6_cidr_blocks = ["::/0"]                      # Todo o tráfego IPv6
  }

  tags = {
    Name = "${var.projeto}-${var.candidato}-sg"  # Tag para identificação do Security Group
  }
}

# Buscando a AMI mais recente do Debian 12
data "aws_ami" "debian12" {
  most_recent = true  # Sempre obter a AMI mais recente

  # Filtrando AMIs baseadas no nome e tipo de virtualização
  filter {
    name   = "name"
    values = ["debian-12-amd64-*"]  # Nome do AMI
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]  # Tipo de virtualização
  }

  owners = ["679593333241"]  # ID do proprietário da AMI (Debian)
}

# Criando uma instância EC2 Debian
resource "aws_instance" "debian_ec2" {
  ami             = data.aws_ami.debian12.id         # ID da AMI Debian 12
  instance_type   = "t2.micro"                       # Tipo de instância (t2.micro, gratuito)
  subnet_id       = aws_subnet.main_subnet.id        # Subnet na qual a instância será criada
  key_name        = aws_key_pair.ec2_key_pair.key_name  # Par de chaves SSH
  security_groups = [aws_security_group.main_sg.name]  # Security Group associado

  associate_public_ip_address = true  # Associar IP público para acesso externo

  # Configuração do disco root da instância
  root_block_device {
    volume_size           = 20        # Tamanho do disco de 20 GB
    volume_type           = "gp2"     # Tipo de volume (gp2)
    delete_on_termination = true      # Apagar disco ao terminar a instância
  }

  # Script para ser executado na inicialização da instância (user_data)
  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              
              # Sugestão: Adicione os comandos abaixo para instalar e iniciar o servidor Nginx
              apt-get install -y nginx  # Instala o servidor Nginx
              systemctl start nginx     # Inicia o Nginx automaticamente
              EOF

  tags = {
    Name = "${var.projeto}-${var.candidato}-ec2"  # Tag para identificação da instância EC2
  }
}

# Exibindo a chave privada usada para acessar a instância EC2
output "private_key" {
  description = "Chave privada para acessar a instância EC2"
  value       = tls_private_key.ec2_key.private_key_pem  # Chave privada gerada
  sensitive   = true  # Marcar como sensível para não ser exibida diretamente nos logs
}

# Exibindo o IP público da instância EC2
output "ec2_public_ip" {
  description = "Endereço IP público da instância EC2"
  value       = aws_instance.debian_ec2.public_ip  # IP público da instância EC2
}