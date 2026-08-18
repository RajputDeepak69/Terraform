# 🔧 Terraform Module Variable Management

A small hands-on lab documenting a Terraform concept that caused me **way more confusion than it should have** 😭

The goal was to understand how **variables, `terraform.tfvars`, and child modules** actually interact — especially when working with reusable Terraform modules.

---

## 🚩 The Problem

The confusing part:

> **Why doesn't my module automatically pick up the value from `terraform.tfvars`?**

Suppose the child module has:

```hcl
variable "ami_id" {
  type = string
}
```

And the project has:

```text
terraform.tfvars
```

containing:

```hcl
ami_id = "ami-xxxxxxxx"
```

You might expect the module to automatically see that value.

**It doesn't.** ❌

If the parent module doesn't pass `ami_id`, Terraform throws:

```text
Missing required argument
```

---

## 🧠 The Key Concept

Terraform modules have their **own variable scope**.

A child module does **not** automatically read:

* The root module's variables
* The root module's `terraform.tfvars`
* A `terraform.tfvars` file sitting inside the child module

This applies to both:

* 📁 Local modules
* 🌐 Remote/official modules

The parent module must explicitly provide the values the child module expects.

---

## 🔗 The "Bridge" Pattern

The easiest way to remember it:

```text
terraform.tfvars
       │
       ▼
 Root variable
       │
       ▼
 Module argument
       │
       ▼
Child variable
       │
       ▼
Terraform resource
```

### 📂 Typical Structure

```text
project/
├── .gitignore
├── variables.tf
├── terraform.tfvars
├── main.tf
│
└── modules/
    └── ec2_instance/
        ├── variables.tf
        └── main.tf
```

---

## 1️⃣ Root `variables.tf`

The root module defines the input:

```hcl
variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}
```

---

## 2️⃣ `terraform.tfvars`

The actual environment-specific value:

```hcl
ami_id = "ami-xxxxxxxx"
```

This file should normally be kept out of Git:

```gitignore
terraform.tfvars
```

---

## 3️⃣ Root `main.tf`

This is the **bridge** 👇

```hcl
module "ec2_instance" {
  source = "./modules/ec2_instance"

  ami_id = var.ami_id
}
```

The root variable:

```text
var.ami_id
```

is explicitly passed to the module:

```text
module.ec2_instance.ami_id
```

---

## 4️⃣ Child Module

The child module declares what it expects:

```hcl
variable "ami_id" {
  description = "AMI ID used by the EC2 instance"
  type        = string
}
```

It can then use:

```hcl
resource "aws_instance" "this" {
  ami = var.ami_id
}
```

---

# 🔐 Why Do It This Way?

This pattern keeps the module:

### 🔄 Reusable

The module doesn't care which AMI, subnet, key, environment, etc. you're using.

### 🌍 Environment-Agnostic

Different environments can provide different values:

```text
dev.tfvars
staging.tfvars
prod.tfvars
```

while using the same module code.

### 🔒 Safer

Environment-specific values don't need to be hardcoded into `.tf` files.

For example, avoid:

```hcl
ami = "ami-xxxxxxxx"
```

inside reusable module code.

Instead:

```hcl
ami = var.ami_id
```

and provide the value externally.

> ⚠️ **Important:** Don't commit secrets or sensitive `.tfvars` files to Git. Use `.gitignore` and secure secret management for real projects.

---

# 🤔 Local Module vs Official Module

This confused me initially too.

The rule is **the same**.

### Local module

```hcl
module "ec2" {
  source  = "./modules/ec2"
  ami_id  = var.ami_id
}
```

### Remote module

```hcl
module "ec2" {
  source  = "some-org/ec2/aws"
  ami_id  = var.ami_id
}
```

The source location doesn't change how module variables work.

The important rule is:

> **A module only receives the values explicitly passed to it by its caller.**

---

# ⚠️ One More Important Detail

If a module variable has a default:

```hcl
variable "instance_type" {
  type    = string
  default = "t2.micro"
}
```

you don't have to provide it.

But if it has **no default**:

```hcl
variable "ami_id" {
  type = string
}
```

then it is required.

That's when Terraform expects the parent module to provide a value.

---

# 🎯 What I Learned

After spending **way too long debugging this 😭**, the main takeaway is simple:

```text
terraform.tfvars
        ↓
   Root Module
        ↓
 Explicitly pass value
        ↓
   Child Module
        ↓
     Resource
```

### The rules worth remembering:

* 🧩 Modules have their own variable scope.
* 📄 `terraform.tfvars` provides values to the **root module**.
* 🔗 Child-module variables must be explicitly passed by the parent.
* ⚠️ Variables without defaults are required.
* ♻️ Keep reusable modules generic.
* 🔒 Keep secrets and environment-specific values out of Git.

> **The module doesn't care where the value came from. It only knows what the parent explicitly gives it.** 😭
