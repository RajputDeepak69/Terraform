# Vault Integration

This lab demonstrates the integration of **HashiCorp Vault with Terraform** for secrets management.

In this lab, Vault was installed on an Ubuntu EC2 instance and run in Dev mode. Different Vault authentication methods were explored, a policy was created to restrict access to a specific secret, and a Vault token with that policy was used by Terraform to retrieve the secret.

The **EC2 instance tag name** was used as the secret stored in the **KV v2 secrets engine**.

---

## Create an AWS EC2 Instance with Ubuntu

An Ubuntu EC2 instance was created to host the Vault development environment.

The instance was launched through the AWS Management Console and accessed using SSH.

---

## Install Vault on the EC2 Instance

Vault was installed using the official HashiCorp APT repository.

**Install GPG**

```bash
sudo apt update && sudo apt install gpg
```

**Download the signing key to a new keyring**

```bash
wget -O- https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor \
-o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

**Verify the key's fingerprint**

```bash
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```

**Add the HashiCorp repository**

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list
```

**Update the package repository**

```bash
sudo apt update
```

**Install Vault**

```bash
sudo apt install vault
```

Verify the installation:

```bash
vault version
```

---

## Start Vault

For this lab, Vault was started in development mode:

```bash
vault server -dev -dev-listen-address="0.0.0.0:8200"
```

Vault Dev mode provides a simple environment for learning and testing.

> **Note:** Dev mode is intended for development and testing purposes and should not be used for a production Vault deployment.

---

## Explore Vault Authentication Methods

Vault supports multiple authentication methods. Some commonly available methods are:

- Token
- AppRole
- AWS
- Kubernetes
- LDAP
- OIDC

These authentication methods were explored to understand the different ways users and applications can authenticate with Vault.

For the Terraform integration in this lab, **Token authentication** was used.

---

## Create a Vault Policy

Vault policies define what an authenticated user or application is allowed to access.

A policy was created specifically for the EC2 secret:

```hcl
path "secret/data/aws/ec2" {
  capabilities = ["read", "list"]
}

path "secret/metadata/aws/ec2" {
  capabilities = ["read", "list"]
}
```

The policy provides only `read` and `list` access to the required KV v2 paths.

It does not provide permissions to create, update, or delete the secret.

Save the policy in a file such as:

```text
terraform-policy.hcl
```

The policy can then be created in Vault using:

```bash
vault policy write terraform terraform-policy.hcl
```

The policy can be viewed using:

```bash
vault policy read terraform
```

---

## Create a Vault Token

A Vault token was created with the `terraform` policy attached.

The token acts as the authentication mechanism between Terraform and Vault.

The overall flow is:

```text
Terraform
    |
    | Token
    v
Vault
    |
    | Policy
    v
secret/data/aws/ec2
```

The token should be treated as a secret and should not be committed to GitHub.

---

## Configure the KV v2 Secrets Engine

The lab used the **KV v2 (Key-Value) secrets engine**.

The `secret/` mount was used to store the EC2 instance tag name.

The secret was stored at:

```text
secret/aws/ec2
```

For KV v2, Vault internally uses separate data and metadata paths:

```text
secret/data/aws/ec2
secret/metadata/aws/ec2
```

This is why both paths were included in the Vault policy.

---

## Store the EC2 Tag Name in Vault

The EC2 instance tag name was stored as a secret using the KV v2 engine.

For example:

```bash
vault kv put secret/aws/ec2 instance_name="my-ec2-instance"
```

The stored secret can be viewed using:

```bash
vault kv get secret/aws/ec2
```

The secret structure is:

```text
secret/
└── aws/
    └── ec2
        └── instance_name = <EC2 tag name>
```

The actual EC2 tag name used in the lab can be substituted for `my-ec2-instance`.

---

## Configure Terraform to Read the Secret from Vault

Terraform was configured to communicate with Vault using the **Vault provider**.

The Vault token created earlier was used to authenticate Terraform with Vault.

The basic flow is:

```text
Terraform
    |
    | Vault Token
    v
HashiCorp Vault
    |
    | Policy validation
    v
terraform policy
    |
    | Read
    v
KV v2 Secret
    |
    v
secret/aws/ec2
```

Terraform can then read the secret from Vault instead of storing the value directly in the Terraform configuration.

---

## Authentication and Authorization

The lab demonstrates the difference between authentication and authorization.

**Authentication** determines who is accessing Vault.

In this lab:

```text
Terraform → Vault Token
```

**Authorization** determines what that authenticated client is allowed to access.

In this lab:

```text
Vault Token
     |
     v
terraform Policy
     |
     v
Read/List access
     |
     v
secret/data/aws/ec2
secret/metadata/aws/ec2
```

Therefore, even though Terraform has a valid Vault token, its access is restricted by the policy attached to that token.

---

## Key Learnings

Through this lab, the following concepts were explored:

- Installing and running HashiCorp Vault.
- Using Vault in Dev mode.
- Understanding different Vault authentication methods.
- Using token-based authentication.
- Creating and applying Vault policies.
- Understanding Vault policy capabilities.
- Using the KV v2 secrets engine.
- Understanding KV v2 data and metadata paths.
- Storing an EC2 tag name as a secret.
- Using a Vault token to authenticate Terraform.
- Retrieving a secret from Vault through Terraform.
- Understanding the separation between authentication and authorization.

---

## Important Note

This lab uses **Vault Dev mode** for learning and experimentation.

A production Vault implementation would require additional considerations such as secure token management, TLS, persistent storage, fine-grained policies, audit logging, backups, network security, and high availability.

The purpose of this lab was to understand the basic concepts of **Vault authentication, policies, KV secrets, and Terraform integration**.