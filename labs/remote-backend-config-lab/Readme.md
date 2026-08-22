# ☁️ Terraform Remote Backend & State Locking

A quick hands-on note on using **Amazon S3 as a Terraform remote backend** and understanding **state locking**.

---

## 🤔 Why Remote State?

Terraform normally stores:

```text
terraform.tfstate
```

locally.

For team environments, remote state is preferred because it provides:

* 👥 **Collaboration** — shared state for multiple users
* 🔒 **Security** — centralized and encrypted state storage
* 💾 **Recovery** — state isn't tied to one local machine
* 🔐 **Locking** — prevents concurrent Terraform operations

---

# 🔐 State Locking

State locking prevents two Terraform operations from modifying the same state simultaneously.

Without locking:

```text
User A → terraform apply ─┐
                          ├──→ Same State ❌
User B → terraform apply ─┘
```

With locking:

```text
User A → 🔒 Lock → Apply → Unlock
                         ↓
User B → Wait → 🔓 → Apply
```

---

# ✅ S3 Native Locking — Recommended

Modern Terraform supports **native S3 state locking** using:

```hcl
use_lockfile = true
```

This is the preferred approach for **new projects**.

### `backend.tf`

```hcl
terraform {
  required_version = ">= 1.11.0"

  backend "s3" {
    bucket       = "my-terraform-state-bucket"
    key          = "prod/terraform.tfstate"
    region       = "us-east-1"

    use_lockfile = true
    encrypt      = true
  }
}
```

Initialize/reconfigure the backend:

```bash
terraform init -reconfigure
```

Terraform uses a `.tflock` object in S3 to coordinate state access.

### Why use it?

* ✅ No additional DynamoDB table
* 💰 Lower infrastructure cost
* 🧹 Less configuration and maintenance
* 🚀 Simpler setup

---

# ⚠️ DynamoDB Locking — Legacy

Older Terraform configurations commonly used DynamoDB for state locking:

```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state-bucket"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"

    dynamodb_table = "terraform-state-locks"

    encrypt        = true
  }
}
```

The DynamoDB table requires:

```text
Partition Key: LockID
Type: String
```

### Current recommendation

> ⚠️ **DynamoDB-based locking is a legacy approach. Use S3 native locking for new projects.**

Keep it mainly for understanding or maintaining existing Terraform infrastructure.

---

# ⚖️ Quick Comparison

|                   | S3 Native      | DynamoDB         |
| ----------------- | -------------- | ---------------- |
| Status            | ✅ Recommended  | ⚠️ Legacy        |
| Terraform         | `use_lockfile` | `dynamodb_table` |
| Resources         | S3             | S3 + DynamoDB    |
| Complexity        | Low            | Medium           |
| Extra DB required | ❌              | ✅                |
| New projects      | **Use this**   | Avoid            |

---

# 🔄 Migrating Existing Projects

If an existing project uses DynamoDB locking:

1. Use Terraform **1.11+**
2. Add:

```hcl
use_lockfile = true
```

3. Remove:

```hcl
dynamodb_table = "terraform-state-locks"
```

4. Reinitialize:

```bash
terraform init -reconfigure
```

5. Verify:

```bash
terraform plan
```

6. Once everything is confirmed, the old DynamoDB lock table can be removed if it is no longer used.

---

## 🎓 Key Takeaway

The main thing to remember:

```text
Old Terraform
S3 + DynamoDB
      ↓
Modern Terraform
S3 + Native Locking
```

> **For new Terraform projects, use an S3 remote backend with native `use_lockfile` locking. Keep DynamoDB locking mainly for legacy configurations.**
