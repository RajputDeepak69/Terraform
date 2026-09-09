# Terraform Workspaces Lab

## Overview

This lab demonstrates the practical use of **Terraform Workspaces** for maintaining separate Terraform states while reusing the same infrastructure configuration.

A simple AWS EC2 instance is used as the infrastructure resource. The EC2 configuration is implemented through a small reusable module, while Terraform Workspaces are used to represent different environments such as:

* Development
* Staging
* Production

The primary focus of this lab is **Terraform Workspace and state management**. Terraform modules and variables are used only as supporting components to create a realistic multi-environment scenario.

---

## Objective

The main objectives of this lab are to:

* Create and manage multiple Terraform Workspaces.
* Understand how Terraform maintains separate state for each Workspace.
* Reuse the same Terraform configuration across different environments.
* Use environment-specific `.tfvars` files with different Workspaces.
* Understand the relationship between Workspaces and Terraform state.
* Observe how switching Workspaces changes the state context used by Terraform.
* Use a reusable EC2 module as a common infrastructure component across environments.

---

## Lab Scenario

The scenario is based on a simple multi-environment infrastructure setup.

The idea is to have a common infrastructure component that can be reused across:

```text
Development
Staging
Production
```

Instead of maintaining separate copies of the Terraform configuration for every environment, the same configuration is used with different Terraform Workspaces.

Conceptually:

```text
                    Terraform Configuration
                             |
                     EC2 Instance Module
                             |
             +---------------+---------------+
             |               |               |
             v               v               v
            DEV            STAGE            PROD
             |               |               |
             v               v               v
         dev.tfvars      stage.tfvars      prod.tfvars
             |               |               |
             v               v               v
        dev Workspace  stage Workspace  prod Workspace
             |               |               |
             v               v               v
          Dev State       Stage State      Prod State
```

The infrastructure is intentionally kept small because the purpose of the lab is to demonstrate **Workspace behavior and state separation**, rather than to build a complex AWS environment.

---

## Project Structure

```text
workspace-lab/
│
├── main.tf
├── provider.tf
├── terraform.tfvars
├── dev.tfvars
├── stage.tfvars
│
├── modules/
│   └── instances/
│       └── main.tf
│
└── README.md
```

Terraform also generates local state-related files while working with Workspaces:

```text
terraform.tfstate
terraform.tfstate.backup

terraform.tfstate.d/
├── dev/
├── stage/
└── prod/
```

These generated state files are intentionally not part of the Git repository.

---

## Infrastructure

The infrastructure for this lab consists of a single AWS EC2 instance.

A small reusable module is used for the EC2 resource:

```text
Root Configuration
       |
       v
instances module
       |
       v
AWS EC2 Instance
```

The module provides the common infrastructure configuration, while variables allow environment-specific values to be supplied.

The module itself is not the primary subject of this lab. It is used to demonstrate a practical situation where the same infrastructure component can be reused across multiple environments.

---

# Workspace Setup

## Initialize Terraform

The Terraform working directory is initialized using:

```bash
terraform init
```

This initializes the working directory and downloads the required provider/module dependencies.

---

## Check Existing Workspaces

The available Workspaces can be listed using:

```bash
terraform workspace list
```

Terraform initially provides a `default` Workspace.

---

## Create Environment Workspaces

The environment Workspaces can be created using:

```bash
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod
```

After creating them:

```bash
terraform workspace list
```

Example:

```text
  default
  dev
  stage
* prod
```

The `*` indicates the currently selected Workspace.

---

# Selecting a Workspace

A Workspace can be selected using:

```bash
terraform workspace select dev
```

For staging:

```bash
terraform workspace select stage
```

For production:

```bash
terraform workspace select prod
```

The currently selected Workspace can be checked with:

```bash
terraform workspace show
```

For example:

```text
dev
```

The selected Workspace is important because Terraform operations operate against the state associated with that Workspace.

---

# Using Environment-Specific Variables

The lab uses separate variable files for environment-specific configuration.

For example:

```text
dev.tfvars
stage.tfvars
prod.tfvars
```

The same Terraform configuration can therefore be used with different values.

For example:

```bash
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"
```

The staging environment can use the same configuration:

```bash
terraform workspace select stage
terraform plan -var-file="stage.tfvars"
terraform apply -var-file="stage.tfvars"
```

The important relationship is:

```text
Same Terraform Configuration
          |
          +---- dev.tfvars  → dev Workspace
          |
          +---- stage.tfvars → stage Workspace
          |
          +---- prod.tfvars → prod Workspace
```

---

# Workspace State Isolation

Each Workspace maintains its own Terraform state.

For example:

```text
dev Workspace
     |
     └── Dev State


stage Workspace
     |
     └── Stage State


prod Workspace
     |
     └── Prod State
```

When switching from:

```bash
terraform workspace select dev
```

to:

```bash
terraform workspace select stage
```

Terraform changes the state context from the `dev` Workspace to the `stage` Workspace.

The state belonging to `dev` is not automatically used by `stage`.

---

# Local Workspace State

This lab uses Terraform's local state backend.

With local state, Workspace-specific state is stored under:

```text
terraform.tfstate.d/
```

The resulting structure can look like:

```text
terraform.tfstate.d/
│
├── dev/
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
│
├── stage/
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
│
└── prod/
```

This provides a practical view of how Terraform maintains separate state for different Workspaces.

These state files should not be committed to Git.

---

# Git and Terraform Files

Environment-specific `.tfvars` files are kept outside the Git repository.

Files such as:

```text
dev.tfvars
stage.tfvars
terraform.tfvars
```

are excluded using `.gitignore`.

This is intentional because `.tfvars` files may contain environment-specific or sensitive configuration.

If the configuration needs to be documented for someone else, sanitized example files can be provided:

```text
dev.tfvars.example
stage.tfvars.example
prod.tfvars.example
```

These files can contain placeholder values without exposing the actual local configuration.

---

# Files Excluded from Git

Terraform-generated state files should not be committed:

```text
terraform.tfstate
terraform.tfstate.backup
terraform.tfstate.d/
```

Environment-specific variable files should also remain excluded when they contain local or sensitive configuration:

```text
*.tfvars
```

The repository should contain the Terraform configuration and safe example files rather than generated state or private configuration.

---

# Basic Workflow

The overall workflow demonstrated in this lab is:

```text
Initialize Terraform
        |
        v
Create Workspaces
        |
        v
Select Environment
        |
        v
Load Environment Variables
        |
        v
Terraform Plan
        |
        v
Terraform Apply
        |
        v
Switch Workspace
        |
        v
Work with Different State
```

Example:

```bash
# Initialize
terraform init

# List workspaces
terraform workspace list

# Create environment workspaces
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod

# Select development
terraform workspace select dev

# Deploy development infrastructure
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# Switch to staging
terraform workspace select stage

# Deploy staging infrastructure
terraform plan -var-file="stage.tfvars"
terraform apply -var-file="stage.tfvars"

# Check current workspace
terraform workspace show
```

---

# Cleanup

Resources should be destroyed after completing the experiment to avoid unnecessary AWS charges.

The appropriate Workspace should be selected before running `terraform destroy`.

For example:

```bash
terraform workspace select dev
terraform destroy -var-file="dev.tfvars"
```

For staging:

```bash
terraform workspace select stage
terraform destroy -var-file="stage.tfvars"
```

If resources were created in the production Workspace:

```bash
terraform workspace select prod
terraform destroy -var-file="prod.tfvars"
```

After the resources have been removed, the Workspaces can be deleted if they are no longer required:

```bash
terraform workspace delete dev
terraform workspace delete stage
terraform workspace delete prod
```

The `default` Workspace is normally retained.

---

# What This Lab Demonstrates

The main concept demonstrated by this lab is:

> **The same Terraform configuration can be reused across multiple Workspaces while each Workspace maintains its own Terraform state.**

The EC2 module provides the reusable infrastructure component, while `.tfvars` files provide environment-specific configuration.

Together, the setup represents a simple multi-environment Terraform workflow:

```text
             Same Terraform Code
                    |
        +-----------+-----------+
        |           |           |
        v           v           v
       DEV        STAGE        PROD
        |           |           |
        v           v           v
      State       State       State
        #1          #2          #3
```

---

# Key Takeaways

* Terraform Workspaces provide separate state instances for the same Terraform configuration.
* Workspaces allow a configuration to be reused across multiple environments.
* Switching Workspaces changes the state context Terraform is operating against.
* Environment-specific variables can be supplied using `.tfvars` files.
* A reusable module can be combined with Workspaces to represent common infrastructure across environments.
* Local Workspace states are stored under `terraform.tfstate.d/`.
* Terraform state files should not be committed to Git.
* Environment-specific `.tfvars` files should be kept out of version control when they contain local or sensitive values.

---

## Conclusion

This lab provides a small practical demonstration of **Terraform Workspaces and state isolation**.

A single AWS EC2 resource was used as the infrastructure example, with a reusable module representing the common infrastructure component and separate variable files representing environment-specific configuration.

The main idea demonstrated is:

```text
Same Terraform Configuration
        +
Environment-Specific Variables
        +
Separate Terraform Workspaces
        =
Reusable Infrastructure with Isolated States
```

The lab provides a practical foundation for understanding how Terraform Workspaces operate and how they can be used to model multiple environments using shared Terraform configuration.
