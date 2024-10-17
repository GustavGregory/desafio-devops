Aqui está o conteúdo de um arquivo `README.md` detalhado, seguindo o desafio solicitado. Ele descreve o código `main.tf`, as melhorias de segurança, a automação do Nginx e as instruções para rodar o projeto.

---

# Desafio de Estágio DevOps - Terraform na AWS

## Descrição do Projeto

Este projeto define a criação de uma infraestrutura básica na AWS utilizando **Terraform**, incluindo:
- VPC (Virtual Private Cloud)
- Subnet
- Security Group (Grupo de Segurança)
- Key Pair (Par de Chaves)
- Instância EC2 com automação de configuração do servidor **Nginx**.

---

## Arquivo `main.tf`

### Infraestrutura Criada

1. **VPC (Virtual Private Cloud)**
   - Uma VPC foi criada com o bloco CIDR `10.0.0.0/16`, fornecendo um ambiente de rede isolado na AWS.

2. **Subnet**
   - Criada dentro da VPC com o bloco CIDR `10.0.1.0/24`. Esta Subnet está associada à zona de disponibilidade `us-east-1a`.

3. **Security Group (Grupo de Segurança)**
   - Um Security Group foi configurado com as seguintes regras:
     - Porta **22** (SSH) aberta para todos (`0.0.0.0/0`). *Recomendação*: Melhorar a segurança restringindo o SSH a um IP específico.
     - Porta **80** (HTTP) aberta para todos (`0.0.0.0/0`), permitindo acesso à instância para servidores web.
     - Egress (Saída) liberada para todo o tráfego, permitindo que a instância envie qualquer tipo de dado para fora.

4. **Key Pair**
   - Gerada uma Key Pair (par de chaves) chamada `deployer-key`, usada para acessar a instância EC2 via SSH.

5. **Instância EC2**
   - Uma instância EC2 do tipo `t2.micro` foi criada usando a AMI `ami-0c55b159cbfafe1f0`. Esta instância está configurada para rodar o servidor **Nginx** automaticamente ao ser criada.

---

## Automação e Melhorias

### 1. **Automação do Nginx**
   A instância EC2 está configurada com um script de **user_data** que faz a instalação e iniciação do servidor web **Nginx** automaticamente:
   ```bash
   #!/bin/bash
   sudo apt update
   sudo apt install -y nginx
   sudo systemctl start nginx
   ```
   Isso garante que, assim que a instância for provisionada, o Nginx estará rodando e acessível através da porta 80.

### 2. **Melhorias de Segurança**
   - A configuração de segurança atual abre a porta 22 (SSH) para todos. Uma melhoria recomendada seria restringir o acesso ao SSH apenas para um endereço IP específico:
     ```hcl
     cidr_blocks = ["seu_ip/32"]  # Substitua 'seu_ip' pelo seu endereço IP
     ```

### 3. **Outras Melhorias**
   - **Modularização**: O código pode ser facilmente modularizado para separar a criação da VPC, Subnet, Security Group e Instância EC2 em arquivos separados, tornando-o mais reutilizável.
   - **Variáveis**: O uso de variáveis pode ser adicionado para permitir flexibilidade na escolha de valores como região, tipo de instância, etc.

---

## Pré-requisitos

- **AWS Account**: Você precisa de uma conta AWS com permissões adequadas para criar recursos como VPC, Subnets, Security Groups, Key Pairs e instâncias EC2.
- **Terraform**: Instale o Terraform em sua máquina seguindo a documentação oficial [aqui](https://www.terraform.io/downloads).

---

## Instruções para Execução

### 1. **Clonar o Repositório**
   Clone o repositório do projeto em sua máquina local:
   ```bash
   git clone <URL-do-seu-repositório>
   cd <diretório-do-projeto>
   ```

### 2. **Configurar Credenciais da AWS**
   Certifique-se de que suas credenciais da AWS estejam configuradas corretamente no seu ambiente:
   ```bash
   aws configure
   ```

### 3. **Inicializar o Terraform**
   No diretório onde está o arquivo `main.tf`, execute o seguinte comando para inicializar o Terraform e baixar os provedores necessários:
   ```bash
   terraform init
   ```

### 4. **Aplicar o Código**
   Para criar a infraestrutura na AWS, execute:
   ```bash
   terraform apply
   ```
   Revise as mudanças que o Terraform propõe e digite `yes` para confirmar a criação dos recursos.

### 5. **Acessar a Instância**
   Após a criação, você pode acessar a instância EC2 via SSH usando o Key Pair gerado:
   ```bash
   ssh -i <caminho-para-sua-chave.pem> ubuntu@<endereço-ip-da-instância>
   ```
   Para descobrir o endereço IP da instância, você pode usar o comando:
   ```bash
   terraform output
   ```

---

## Considerações Finais

- **Destruir Recursos**: Após o teste, destrua a infraestrutura criada para evitar custos desnecessários na AWS:
   ```bash
   terraform destroy
   ```

- **Documentação**: Consulte a documentação oficial do Terraform para aprender mais sobre suas funcionalidades [aqui](https://www.terraform.io/docs).

---

Espero que este arquivo atenda aos requisitos do desafio! Caso tenha alguma dúvida, é só me avisar. Boa sorte com o envio!