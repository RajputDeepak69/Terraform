# HashiCorp Vault — Learning Notes

HashiCorp Vault is a secrets management tool used to securely store, access, and manage sensitive information such as passwords, API keys, tokens, certificates, and cloud credentials.

Instead of storing secrets directly in code or configuration files, applications and tools can retrieve them dynamically from Vault when required.

---

## Why Vault?

Without a secrets-management system, sensitive values often leak into:

* Source-code repositories
* `.env` files
* Terraform variables
* CI/CD variables
* Configuration files

Vault provides a centralized place to manage these secrets with fine-grained access control.

```text
Application / Terraform
          |
          v
        Vault
          |
          v
        Secret
```

---

## Core Concepts

The flow of requests in Vault follows this hierarchy:

```text
Authentication
      |
      v
   Identity
      |
      v
    Policy
      |
      v
Secrets Engine
      |
      v
    Secret
```

---

## Authentication

Authentication answers: **Who are you?**

Vault supports multiple authentication methods depending on the client and environment:

* **Token**
* **AppRole**
* **AWS**
* **Kubernetes**
* **LDAP**
* **OIDC**

---

## Policies

Policies answer: **What are you allowed to do?**

Policies control what an authenticated identity is permitted to access using Path-Based Access Control (PBAC).

**Example Policy (`hcl`):**

```hcl
path "secret/data/application/database" {
  capabilities = ["read"]
}
```

Common capabilities include:

* `create`
* `read`
* `update`
* `delete`
* `list`

> This follows the **principle of least privilege** — grant clients only the permissions strictly required.

---

## Secrets Engines

Secrets engines are components responsible for storing, generating, or encrypting secrets.

| Secrets Engine | Purpose |
|---|---|
| **KV** | Store key-value secrets (v1 unversioned, v2 versioned) |
| **Database** | Generate dynamic, short-lived database credentials |
| **AWS** | Generate dynamic IAM user keys or STS assume-role credentials |
| **PKI** | Manage, issue, and revoke X.509 certificates |
| **Transit** | Cryptography-as-a-service (encryption/decryption without storing data) |

---

## KV Secrets Engine

The **KV (Key-Value)** engine is commonly used for static application secrets.

**Example Structure:**

```text
secret/
└── application/
    └── database
        ├── username
        └── password
```

**KV v2** adds secret versioning and uses two separate internal paths:

* `secret/data/<path>`: Contains the actual secret payload.
* `secret/metadata/<path>`: Contains versions, timestamps, and metadata.

---

## Dynamic Secrets

Unlike traditional vaults that store static passwords, Vault can generate temporary credentials on-demand with automatic expiration and revocation.

```text
Application
     |
     v
   Vault
     |
     v
Temporary Credential
     |
     v
   Expires
```

Dynamic secrets eliminate credential sharing and manual rotation for databases, cloud providers, and message queues.

---

## Vault + Terraform

Terraform integrates natively via the **HashiCorp Vault provider** to fetch values at runtime:

```text
Terraform
    |
    | Authenticate (Token, AppRole, AWS IAM, etc.)
    v
  Vault
    |
    | Policy validation
    v
Secret
```

This prevents hardcoding plain-text passwords or secret keys into `.tfvars` or Git repositories.

---

## Vault vs Simple Secret Storage

Vault is more than just an encrypted key-value store. It provides:

* Centralized secret management
* Identity and authentication integration
* Authorization through path-based policies
* Secret versioning and soft deletes (KV v2)
* Dynamic, on-demand credentials
* Secret leasing, TTLs, and automated revocation
* Encryption-as-a-service (Transit)
* Full audit logging for compliance

---

## Important Security Practices

* **Enforce least privilege:** Grant only the specific capabilities (`read`, `list`) required for explicit paths.
* **Keep secrets out of Git:** Never commit Vault tokens, unseal keys, or live credentials.
* **Enable TLS:** Always enforce TLS in production to prevent token interception.
* **Turn on Audit Devices:** Send all operational logs to secure, tamper-proof sinks.
* **Use production-ready auth:** Prefer platform identities (AppRole, AWS IAM, Kubernetes) over long-lived root tokens.
* **Automate rotation:** Make use of dynamic secrets and time-to-live (TTL) limits.
* **Avoid catch-all policies:** Restrict the use of `*` wildcards in policy paths.

---

## Key Takeaway

The core operational pattern of Vault:

```text
Authentication
      ↓
   Who are you?
      ↓
    Policy
      ↓
What can you access?
      ↓
Secrets Engine
      ↓
Secret / Credential
```

> **Vault = centralized secrets + authentication + authorization + secret lifecycle management.**