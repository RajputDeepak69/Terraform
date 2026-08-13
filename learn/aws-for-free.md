# ☁️ Practice AWS for Free with Terraform + Docker

Practice **AWS and Terraform locally** without creating real AWS resources or incurring AWS charges.

This setup uses an AWS emulator running inside Docker:

```text
Terraform → LocalStack/MiniStack → Docker
```

You can practice resources such as **VPC, Subnets, Security Groups, EC2, S3, IAM, Lambda**, etc., depending on emulator support.

---

## 🛠️ Prerequisites

Install:

* [Docker Desktop](https://www.docker.com/products/docker-desktop/)
* [Terraform](https://developer.hashicorp.com/terraform/install)
* AWS CLI

Verify:

```bash
docker --version
terraform version
aws --version
```

---

## 📦 1. Start a Local AWS Emulator

### Option A — MiniStack

Lightweight and doesn't require an account/token.

```bash
docker run -d \
  -p 4566:4566 \
  --name localstack \
  nahuelnucera/ministack:latest
```

### Option B — LocalStack

More extensive AWS service support, but current versions require an authentication token.

```bash
docker run -d \
  -p 4566:4566 \
  -e LOCALSTACK_AUTH_TOKEN="YOUR_TOKEN_HERE" \
  --name localstack \
  localstack/localstack:latest
```

Check that it is running:

```bash
docker ps
```

Check logs if needed:

```bash
docker logs localstack
```

> **Recommendation:** Start with MiniStack for basic Terraform/AWS practice. Use LocalStack when you need broader service support.

---

## ⚙️ 2. Configure Terraform

Create a directory:

```bash
mkdir terraform-aws-local
cd terraform-aws-local
```

Create `main.tf`:

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  access_key = "test"
  secret_key = "test"
  region     = "us-east-1"

  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    ec2      = "http://localhost:4566"
    s3       = "http://localhost:4566"
    iam      = "http://localhost:4566"
    lambda   = "http://localhost:4566"
    dynamodb = "http://localhost:4566"
    sns      = "http://localhost:4566"
    sqs      = "http://localhost:4566"
  }
}
```

The important part is:

```text
http://localhost:4566
```

Terraform sends AWS API requests to the local emulator instead of real AWS.

---

## 🏗️ 3. Create AWS Infrastructure

Add the following to `main.tf`:

```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "practice-vpc"
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "practice-subnet"
  }
}

resource "aws_security_group" "ssh" {
  name   = "allow-ssh"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_instance" "demo" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  subnet_id              = aws_subnet.main.id
  vpc_security_group_ids = [aws_security_group.ssh.id]

  tags = {
    Name = "demo-instance"
  }
}
```

### 🔑 Local emulator notes

* Fake AMI IDs such as `ami-12345678` can be used where supported.
* Reference Terraform resources using `.id` instead of hardcoding IDs.
* VPC networking resources such as subnets and security groups use the EC2 endpoint.

---

## ▶️ 4. Run Terraform

```bash
terraform init
terraform fmt
terraform validate
terraform plan
terraform apply
```

Enter:

```text
yes
```

Terraform will create the resources **locally**.

---

## 🔍 5. Verify

Use AWS CLI with the local endpoint:

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-instances
```

Check VPCs:

```bash
aws --endpoint-url=http://localhost:4566 ec2 describe-vpcs
```

Check S3:

```bash
aws --endpoint-url=http://localhost:4566 s3 ls
```

---

## 🧹 6. Clean Up

Destroy everything created by Terraform:

```bash
terraform destroy
```

Then remove the emulator container if you're done:

```bash
docker rm -f localstack
```

---

## ⚠️ Important Limitations

This is an **AWS emulator**, not real AWS.

Some AWS services/features may behave differently or may not be supported.

Use it primarily for learning:

* Terraform
* Infrastructure as Code
* AWS resource relationships
* VPC concepts
* EC2/S3/IAM basics
* `plan → apply → destroy` workflow

For production-specific behavior, test against real AWS.

---

## 🔄 Moving to Real AWS

When you're ready to use real AWS:

1. Remove the local `endpoints` configuration.
2. Stop using dummy credentials.
3. Configure real AWS credentials.
4. Replace fake AMI IDs with valid regional AMIs.
5. **Review `terraform plan` carefully before `apply`.**

The Terraform concepts remain largely the same:

```text
Local Emulator                  Real AWS
      │                            │
 Terraform                      Terraform
      │                            │
 localhost:4566                 AWS APIs
```

---

## 💡 Practice Path

Once the basic example works, expand it step-by-step:

```text
VPC
 ↓
Subnets
 ↓
Route Tables
 ↓
Internet Gateway
 ↓
Security Groups
 ↓
EC2
 ↓
S3
 ↓
IAM
 ↓
Variables & Outputs
 ↓
Terraform Modules
```

> **Goal:** Learn Terraform and AWS infrastructure safely before spending money on real AWS.
