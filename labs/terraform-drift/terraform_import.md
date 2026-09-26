# Terraform Import: Adopting Existing Infrastructure

> How to bring resources Terraform doesn't know about under its management.

---

## Why Import?

Terraform only manages resources it created (or that you've told it about). If something already exists in AWS and Terraform doesn't know about it, the next `apply` will **destroy** it. Import fixes this.

**Import = telling Terraform "this already exists, here it is, manage it now."**

---

## When to Import vs. Rebuild

| Situation | Action |
|---|---|
| Resource has state/data that can't be recreated (RDS, EBS, Route53) | **Import** |
| Resource is ephemeral and cheap to recreate (EC2, ALB, SQS) | **Rebuild** |
| Heavy drift, no clear desired state | **Rebuild** |
| Minor drift, stable and well-understood | **Import** + align config |

---

## Prerequisites

- Terraform **1.5+** (for `import` blocks)
- AWS credentials configured (`aws configure` or env vars)
- The resource exists in the same region your provider points to

---

## Step-by-Step

### 1. Find the Resource ID

| Resource | Where |
|---|---|
| EC2 | Console → EC2 → Instance ID (`i-0abc...`) |
| VPC | Console → VPC → VPC ID (`vpc-0abc...`) |
| S3 | Console → S3 → Bucket name |
| RDS | Console → RDS → DB Instance Identifier |
| SG | Console → EC2 → Security Groups → SG ID |

---

### 2. Write the Import Block

Create `imports.tf`:

```hcl
import {
  to = aws_s3_bucket.data
  id = "my-company-data"
}
```

---

### 3. Generate the Config

```bash
terraform plan -generate-config-out=generated.tf
```

This reads the live resource and writes a draft resource block into `generated.tf`.

---

### 4. Clean Up the Generated Config

Open `generated.tf`, then:

- [ ] Remove attributes you don't want to manage
- [ ] Add attributes you want to enforce going forward
- [ ] Move the resource block into your proper `.tf` file
- [ ] Delete `generated.tf`

**Example:**

```hcl
# s3.tf (your real file)
resource "aws_s3_bucket" "data" {
  bucket = "my-company-data"
  tags   = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

---

### 5. Plan (Safety Check)

```bash
terraform plan
```

**Expected output:**

```text
Plan: 1 to import, 0 to add, 0 to change, 0 to destroy.
```

> ⚠️ **Warning:** If you see "destroy" → **STOP**. Your config is wrong. Fix it before applying. Never let Terraform replace a production resource during an import.

---

### 6. Apply

```bash
terraform apply
```

**Output:**

```text
aws_s3_bucket.data: Importing... [id=my-company-data]
aws_s3_bucket.data: Import successful!
Apply complete! Resources: 1 imported.
```

---

### 7. Remove the Import Block

Delete the `import { ... }` block from `imports.tf` and commit your changes.

The `import` block is a one-time operation. Leaving it in causes errors on subsequent runs.

---

### 8. Verify Clean State

```bash
terraform plan
```

**Expected output:**

```text
No changes. Your infrastructure matches the configuration.
```

If drift appears, apply the **Drift Decision Framework** to resolve it.

---

## Bulk Import with `for_each`

```hcl
locals {
  existing_buckets = {
    logs      = "company-logs-prod"
    artifacts = "company-artifacts-prod"
    backups   = "company-backups-prod"
  }
}

import {
  for_each = local.existing_buckets
  to       = aws_s3_bucket.this[each.key]
  id       = each.value
}

resource "aws_s3_bucket" "this" {
  for_each = local.existing_buckets
  bucket   = each.value
}
```

A single `terraform apply` imports all three resources simultaneously.

---

## Import Order (Dependencies)

When importing a stack of related resources, go bottom-up:

```text
VPC → Subnets → Route Tables → Security Groups → Instances
```

Importing a subnet before its parent VPC will fail.

---

## Common Pitfalls

| Pitfall | Fix |
|---|---|
| Importing a "family" partially (S3 bucket but not versioning/encryption) | Next plan will destroy missing sub-resources. Import the whole family. |
| Hardcoded IDs in config | Replace with references: `vpc_id = aws_vpc.main.id` |
| Forgetting `force_new` attributes | Fill in `ami`, `instance_type`, etc. before first apply or Terraform will recreate the resource |
| No state backup | Run `terraform state pull > backup.tfstate` before starting |
| Importing into a module | Use full path: `module.web.aws_instance.app` |

---

## Automation for Large Imports

| Tool | Use case |
|---|---|
| **Terraformer** (Google) | Bulk-imports an entire account/region |
| **former2** | Generates Terraform config from existing AWS resources |
| `terraform plan -generate-config-out` | Auto-generates HCL for a single import |

**Terraformer example (all S3 buckets in a region):**

```bash
terraform import aws --resources=s3 --regions=us-east-1 \
  --filter="Name=tags.Name;Value=myprefix"
```

---

## Post-Import: Reconciling Drift

Your first `terraform plan` after import will likely show diffs. For each:

| Diff Type | Action |
|---|---|
| `force_new` attribute (changing = destroy + recreate) | Align config to match live value |
| Updatable attribute | Revert live or align config (see drift framework) |
| Managed by another system | `ignore_changes` with justification |

---

## Cheat Sheet

```bash
# 1. Write import block in imports.tf

# 2. Generate config
terraform plan -generate-config-out=generated.tf

# 3. Clean up → move into your .tf files → delete generated.tf

# 4. Safety check
terraform plan

# 5. Do it
terraform apply

# 6. Remove imports.tf → commit

# 7. Verify
terraform plan
```

Five commands. One file to clean up. Done.

---

## Golden Rule

> **Always plan before apply after an import.**
> 
> If the plan says "destroy and recreate," stop — your config is wrong.
> Fix the config first. Never let an import trigger an unintended replacement.