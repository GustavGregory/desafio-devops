# Desafio de Estágio DevOps - Terraform na AWS

## Descrição do Projeto

Este projeto utiliza **Terraform** para provisionar uma infraestrutura básica na **AWS**. A infraestrutura inclui a criação de uma **VPC**, **Subnet**, **Internet Gateway**, **Security Group**, **Key Pair** e uma **instância EC2** que, após criada, é configurada para instalar e iniciar o servidor **Nginx** automaticamente.

## Infraestrutura Criada

### 1. **VPC (Virtual Private Cloud)**
- **Bloco CIDR**: `10.0.0.0/16`
- O DNS está habilitado para suporte e resolução de nomes dentro da VPC.

### 2. **Subnet**
- **Bloco CIDR**: `10.0.1.0/24`
- A Subnet está localizada na zona de disponibilidade `us-east-1a`.

### 3. **Internet Gateway**
- Um Internet Gateway foi configurado para fornecer conectividade à Internet para os recursos dentro da VPC.

### 4. **Tabela de Rotas**
- Todo o tráfego (`0.0.0.0/0`) é roteado para o Internet Gateway, permitindo acesso à Internet.

### 5. **Security Group**
- O Security Group permite:
  - **SSH (porta 22)** de qualquer lugar (`0.0.0.0/0`) – **Recomendação**: restringir o SSH para um IP específico para melhorar a segurança.
  - Todo o tráfego de saída.

### 6. **Key Pair**
- Uma chave SSH é gerada dinamicamente e associada à instância EC2 para acesso remoto.

### 7. **Instância EC2 (Debian 12)**
- **Tipo de instância**: `t2.micro`
- **Sistema Operacional**: Debian 12, selecionado através de uma AMI pública.
- **Armazenamento**: Volume root de 20GB no tipo `gp2`.
- A instância é configurada para receber um **IP público** e está associada à Subnet e ao Security Group definidos.
- **Automação**: Um script `user_data` atualiza os pacotes e instala o servidor Nginx automaticamente na criação da instância.

## Melhorias Implementadas

### 1. **Automação do Nginx**
A instância EC2 está configurada para instalar e iniciar o **Nginx** automaticamente utilizando o script abaixo:
```bash
#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install -y nginx
systemctl start nginx
```

### 2. **Melhoria de Segurança**
- **SSH Restrito**: Uma melhoria recomendada é restringir o acesso SSH para um IP específico em vez de deixar a porta 22 aberta para o mundo. Isso pode ser feito ajustando o bloco de regras de entrada no Security Group.

## Instruções para Execução

### Pré-requisitos:
- **AWS CLI** configurado com as credenciais apropriadas.
- **Terraform** instalado localmente. Você pode baixar a ferramenta [aqui](https://www.terraform.io/downloads).

### Passos:
1. **Clone o repositório**:
   ```bash
   git clone <URL-do-repositorio>
   cd <diretorio-do-repositorio>
   ```

2. **Inicialize o Terraform**:
   No diretório onde está o arquivo `main.tf`, execute:
   ```bash
   terraform init
   ```

3. **Aplique o Terraform**:
   Para criar a infraestrutura na AWS, execute:
   ```bash
   terraform apply
   ```
   Confirme a criação dos recursos digitando `yes` quando solicitado.

4. **Acessar a instância EC2**:
   Após a criação, acesse a instância EC2 via SSH usando a chave privada gerada:
   ```bash
   ssh -i <path_to_private_key.pem> ubuntu@<ec2_public_ip>
   ```
   O endereço IP público da instância será exibido como output ao final do processo.

5. **Testar o Nginx**:
   Após a criação da instância, acesse o endereço IP público da instância no navegador:
   ```
   http://<ec2_public_ip>
   ```
   O servidor Nginx estará rodando.

6. **Destruir a infraestrutura**:
   Após os testes, destrua a infraestrutura para evitar custos:
   ```bash
   terraform destroy
   ```

## Outputs

- **Chave privada**: A chave privada SSH será exibida no output.
- **IP público**: O IP público da instância EC2 também será exibido.