# Terraform Drift Decision Framework

This guide provides a decision framework for handling **Terraform drift** — situations where the live infrastructure differs from the configuration managed by Terraform.

The goal is to determine whether the detected drift should be **reverted**, **aligned (codified)**, or intentionally **ignored**.

---

## When to Use This

Use this framework when infrastructure drift has been detected through:

- `terraform plan`
- `terraform plan -refresh-only`
- HCP Terraform drift detection
- `driftctl`
- Manual inspection

Once drift is detected, investigate the reason for the difference before deciding how to handle it.

---

## Decision Flow

The basic decision process is:

```text
Drift Detected
      |
      v
Is it security-sensitive?
      |
   +--+--+
   |     |
  YES    NO
   |     |
   v     v
REVERT   Was the change intentional?
NOW             |
   |        +---+---+
   |        |       |
   |       NO      YES
   |        |       |
   |        v       v
   |     REVERT   Permanent or temporary?
   |                 |
   |              +--+--+
   |              |     |
   |         Permanent Temporary
   |              |       |
   |              v       v
   |            ALIGN   REVERT
   |           (Codify)
   |
   v
Escalate / Investigate
```

---

## Revert

Revert the live infrastructure so that it matches the Terraform configuration.

```bash
terraform apply
```

### Use When

Revert the change when:

- The change was unauthorized.
- The change was accidental.
- The drift is security-sensitive.
- A temporary change is no longer required.
- A manual change was made only for troubleshooting or incident response.

### Examples of Security-Sensitive Drift

- An unexpected security-group ingress rule.
- An unauthorized IAM permission.
- Encryption being disabled.
- A public bucket configuration.
- An unexpected change to access controls.

### Guardrails

- Revert security-critical drift as soon as practical and escalate the issue.
- Confirm that reverting the change will not disrupt an active incident.
- Investigate who or what made the change using audit logs.

---

## Align (Codify)

If the live change was intentional and should become the new desired state, update the Terraform configuration to match the live infrastructure.

After updating the `.tf` files, run:

```bash
terraform plan
```

The goal is for Terraform to show that no further changes are required.

### Use When

Align the Terraform configuration when:

- The change was intentional and should persist.
- An emergency change became the correct permanent configuration.
- A capacity or configuration change is now the desired baseline.

### Guardrails

- The change should be codified before the next `terraform apply`.
- Otherwise, Terraform may revert the manual change back to the configuration defined in the `.tf` files.
- Emergency or break-glass changes should be followed by a PR according to the organization's defined SLA.
- The PR should document:
  - What changed
  - Why it changed
  - Who authorized it

### Codification Flow

```text
Manual Change
      |
      v
Investigate
      |
      v
Confirm Intent
      |
      v
Update .tf Files
      |
      v
terraform plan
      |
      v
Verify Configuration
```

---

## Ignore

Sometimes another system is intentionally responsible for managing a particular Terraform attribute.

In such cases, Terraform can be configured to ignore changes to specific attributes using `ignore_changes`.

**Example:**

```hcl
lifecycle {
  ignore_changes = [desired_capacity, tags]
}
```

### Use When

Use `ignore_changes` when:

- Another system is authoritative for the attribute.
- The drift is expected.
- The drift is ongoing and benign.
- Terraform should not continuously overwrite changes made by the external system.

### Guardrails

- Scope `ignore_changes` to specific attributes.
- Do not use `ignore_changes = all` as a general solution.
- Do not ignore security-critical attributes such as IAM, encryption, or network access.
- Document the reason for every `ignore_changes` block.

**Example with documentation:**

```hcl
lifecycle {
  # Desired capacity is controlled by the autoscaling policy.
  ignore_changes = [desired_capacity]
}
```

---

## Common Ignore Candidates

Some attributes may legitimately be managed by systems other than Terraform.

| Attribute | Authoritative System |
| :--- | :--- |
| `desired_capacity` (ASG) | Auto-scaling policy |
| `ami` | AMI rotation pipeline |
| `tags` | Central tagging / compliance tool |
| `user_data` | External bootstrap system |
| `metadata_options` | Cloud provider or external configuration |

These are examples only. An attribute should be ignored only when another system is intentionally authoritative for that attribute.

---

## Drift Checklist

Use this checklist whenever drift is detected:

- [ ] Is the drift security-sensitive?
- [ ] If yes, should it be reverted and escalated?
- [ ] Who or what made the change?
- [ ] Check CloudTrail or other audit logs.
- [ ] Was the change authorized?
- [ ] Is the change still required?
- [ ] Is the change permanent or temporary?
- [ ] Is another system authoritative for this attribute?
- [ ] If ignoring the change, is the scope limited to the required attribute?
- [ ] Is the reason for `ignore_changes` documented?
- [ ] If aligning the configuration, has the change been added to Terraform?
- [ ] Has `terraform plan` been run after the change?
- [ ] If it was a break-glass change, has the required PR/SLA process been followed?

---

## Anti-Patterns

The following approaches should be avoided when dealing with Terraform drift:

| Anti-pattern | Why It's Bad |
| :--- | :--- |
| `ignore_changes = all` | Hides future drift across the entire resource |
| Ignoring security attributes | Can leave security issues unresolved |
| Reverting without checking context | Can break an active incident or emergency fix |
| Aligning without investigation | Can codify an unauthorized or incorrect change |
| No process for break-glass changes | Temporary changes can become permanent drift |
| Ignoring unexplained drift | The underlying cause of the change remains unknown |

---

## Tools for Detecting and Investigating Drift

| Tool | Purpose |
| :--- | :--- |
| `terraform plan` | Detect drift and show proposed changes |
| `terraform plan -refresh-only` | Refresh Terraform state and review infrastructure changes |
| HCP Terraform drift detection | Scheduled or continuous drift detection |
| `driftctl` | Open-source infrastructure drift detection |
| CloudTrail / audit logs | Identify who or what made a change |

---

## Key Principle

> **Terraform drift should have an intentional explanation.**
>
> If the difference between the Terraform configuration and live infrastructure is unexplained, investigate it before deciding to ignore it.

### Overall Approach

```text
Drift Detected
      |
      v
Investigate
      |
      +---- Security-sensitive? ---- YES ----> REVERT + ESCALATE
      |
      v
Was it authorized?
      |
      +---- NO ----> REVERT + INVESTIGATE
      |
      v
Is it permanent?
      |
      +---- YES ----> ALIGN / CODIFY
      |
      +---- NO -----> REVERT WHEN FINISHED
      |
      v
Is another system authoritative?
      |
      +---- YES ----> IGNORE SPECIFIC ATTRIBUTE + DOCUMENT WHY
      |
      +---- NO -----> INVESTIGATE
```

### The Three Possible Actions

1. **Revert:** When the live change should not remain.
2. **Align:** When the live change is intentional and should become the new Terraform-managed configuration.
3. **Ignore:** Only when another system is intentionally authoritative for that specific attribute.