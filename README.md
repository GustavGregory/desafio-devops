Aqui está a versão revisada do seu README.md, em primeira pessoa e com as melhorias aplicadas:

---

# Desafio de Estágio DevOps - Terraform na AWS

## Descrição do Projeto

Neste projeto, utilizei o **Terraform** para provisionar uma infraestrutura básica na **AWS**. A infraestrutura criada inclui uma **VPC**, **Subnet**, **Internet Gateway**, **Security Group**, **Key Pair** e uma **instância EC2** que, após ser provisionada, instala e inicia o servidor **Nginx** automaticamente.

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
  - **SSH (porta 22)** de um IP específico, garantindo maior segurança e evitando acessos não autorizados.
  - Todo o tráfego de saída está liberado.

### 6. **Key Pair**
- Gerei dinamicamente um par de chaves SSH e associei à instância EC2 para permitir o acesso remoto de forma segura.

### 7. **Instância EC2 (Debian 12)**
- **Tipo de instância**: `t2.micro`
- **Sistema Operacional**: Debian 12, selecionado através de uma AMI pública.
- **Armazenamento**: Volume root de 20GB no tipo `gp2`.
- A instância foi configurada para receber um **IP público**, estando associada à Subnet e ao Security Group definidos.
- **Automação**: Um script `user_data` atualiza os pacotes e instala automaticamente o servidor Nginx assim que a instância é provisionada.

## Melhorias Implementadas

### 1. **Automação do Nginx**
Configurei a instância EC2 para que o servidor **Nginx** seja instalado e iniciado automaticamente após a criação da instância. Isso foi feito utilizando o seguinte script `user_data`:

```bash
#!/bin/bash
apt-get update -y
apt-get upgrade -y
apt-get install -y nginx
systemctl start nginx
```

### 2. **Melhoria de Segurança**
Implementei uma melhoria significativa de segurança ao **restringir o acesso SSH** a um IP específico, em vez de deixar a porta 22 aberta para o mundo. Isso ajuda a prevenir ataques de força bruta e protege o servidor de acessos indesejados.

## Instruções para Execução

### Pré-requisitos:
- **AWS CLI** configurado com as credenciais apropriadas.
- **Terraform** instalado localmente. Você pode baixar a ferramenta [aqui](https://www.terraform.io/downloads).

### Passos:
1. **Clone o repositório**:
   Primeiro, clone o repositório com os arquivos necessários:
   ```bash
   git clone <URL-do-repositorio>
   cd <diretorio-do-repositorio>
   ```

2. **Inicialize o Terraform**:
   No diretório onde está o arquivo `main.tf`, inicialize o Terraform:
   ```bash
   terraform init
   ```

3. **Aplique o Terraform**:
   Em seguida, crie a infraestrutura na AWS executando o comando abaixo. Quando solicitado, confirme com `yes`:
   ```bash
   terraform apply
   ```

4. **Acesse a instância EC2**:
   Após a criação, você pode acessar a instância EC2 via SSH utilizando a chave privada gerada. Use o comando abaixo:
   ```bash
   ssh -i <path_to_private_key.pem> ubuntu@<ec2_public_ip>
   ```
   O endereço IP público da instância será exibido como output ao final do processo.

5. **Teste o Nginx**:
   Para verificar se o Nginx está funcionando corretamente, acesse o endereço IP público da instância através do navegador:
   ```bash
   http://<ec2_public_ip>
   ```

6. **Destrua a infraestrutura**:
   Para evitar custos adicionais após os testes, destrua a infraestrutura criada:
   ```bash
   terraform destroy
   ```

## Outputs

- **Chave privada**: A chave privada SSH necessária para acessar a instância EC2 será exibida no output do Terraform.
- **IP público**: O endereço IP público da instância EC2 também será exibido para que você possa acessá-la remotamente.