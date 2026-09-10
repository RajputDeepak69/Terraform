# 🧪 Terraform + LocalStack: VPC Networking Lab

A small hands-on lab to get familiar with **Terraform, AWS networking, and AWS CLI** by provisioning a basic VPC environment locally using **LocalStack**.

No real AWS resources are created, so there are **no AWS infrastructure costs** involved.

---

## 🎯 Objective

Build and verify a basic AWS-style network environment:

```text
VPC
├── Public Subnet 1
├── Public Subnet 2
├── Internet Gateway
├── Public Route Table
└── Security Group
    ├── HTTP :80
    └── SSH  :22
```

Terraform handles the infrastructure, while the AWS CLI is used to verify the resources through LocalStack.

---

## 🛠️ Prerequisites

* Docker
* Terraform CLI 1.0+
* AWS CLI

---

## 📁 Project Structure

```text
terraform-vpc-lab/
├── provider.tf
├── variables.tf
├── main.tf
└── README.md
```

---

## 🚀 Getting Started

### 1. Start LocalStack

```bash
docker run --rm -it \
  -p 4566:4566 \
  -p 4571:4571 \
  localstack/localstack
```

Keep LocalStack running while performing the lab.

### 2. Initialize Terraform

```bash
terraform init
```

### 3. Validate the configuration

```bash
terraform validate
```

### 4. Preview the infrastructure

```bash
terraform plan
```

### 5. Deploy

```bash
terraform apply -auto-approve
```

---

## 🔍 Verify with AWS CLI

The AWS CLI can query LocalStack using the `--endpoint-url` option.

### VPC

```bash
aws --endpoint-url=http://localhost:4566 \
  ec2 describe-vpcs \
  --query "Vpcs[*].[VpcId,CidrBlock]" \
  --output table
```

### Subnets

```bash
aws --endpoint-url=http://localhost:4566 \
  ec2 describe-subnets \
  --query "Subnets[*].[SubnetId,CidrBlock]" \
  --output table
```

### Security Groups

```bash
aws --endpoint-url=http://localhost:4566 \
  ec2 describe-security-groups \
  --query "SecurityGroups[*].[GroupId,GroupName]" \
  --output table
```

---

## 🧹 Cleanup

Destroy the infrastructure created by Terraform:

```bash
terraform destroy -auto-approve
```

Stop LocalStack with `Ctrl+C`.

---

## 🎓 Key Learnings

This lab gave me hands-on experience with:

* **Terraform** — providers, resources, variables, outputs, dependencies, and the plan/apply/destroy workflow
* **AWS VPC** — CIDR blocks and network segmentation
* **Subnets** — creating public subnets
* **Internet Gateway** — providing internet routing
* **Route Tables** — routing traffic through an IGW
* **Security Groups** — controlling inbound and outbound traffic
* **AWS CLI** — querying and verifying infrastructure
* **LocalStack** — practicing AWS infrastructure locally without cloud costs

---

## 🚀 Next Steps

Possible extensions to this lab:

* Add EC2 instances
* Create private subnets
* Add NAT Gateway
* Create separate public/private route tables
* Introduce Terraform variables and outputs
* Refactor the infrastructure into Terraform modules

> **A small lab, but a good way to get hands-on with Terraform + AWS networking before moving to real cloud infrastructure.**
