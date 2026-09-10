# Terraform Workspaces

## What Is a Terraform Workspace?

A **Terraform Workspace** is an isolated state environment within a Terraform configuration.

Terraform uses state to keep track of the infrastructure it manages. By default, a Terraform configuration starts with a `default` Workspace.

Additional Workspaces can be created when the same Terraform configuration needs to maintain multiple independent states.

For example:

```text
Terraform Configuration
        |
        +---- dev Workspace
        |
        +---- stage Workspace
        |
        +---- prod Workspace
```

Each Workspace has its own state.

The configuration can remain the same while Terraform keeps the state associated with each Workspace separate.

---

# Why Are Workspaces Used?

The primary purpose of Workspaces is to allow **one Terraform configuration to manage multiple instances of infrastructure with separate states**.

Consider a configuration that creates an EC2 instance.

Without Workspaces, one possible approach would be to create separate configurations:

```text
dev/
    main.tf

stage/
    main.tf

prod/
    main.tf
```

This can result in duplicated Terraform configuration.

With Workspaces, the same configuration can conceptually be used as:

```text
                 main.tf
                    |
       +------------+------------+
       |            |            |
       v            v            v
      dev          stage        prod
   Workspace     Workspace    Workspace
```

The configuration is reused, while the states remain separate.

---

# How Workspaces Work

Terraform maintains state for the currently selected Workspace.

For example:

```bash
terraform workspace select dev
```

Terraform now operates using the `dev` Workspace's state.

If the Workspace is changed:

```bash
terraform workspace select stage
```

Terraform operates using the `stage` Workspace's state.

The Terraform configuration itself has not necessarily changed.

The state context has changed.

Conceptually:

```text
                     Configuration
                           |
             +-------------+-------------+
             |             |             |
             v             v             v
           dev           stage          prod
             |             |             |
             v             v             v
         State #1       State #2       State #3
```

---

# Terraform Workspace Commands

## List Workspaces

```bash
terraform workspace list
```

Shows all available Workspaces.

The `*` indicates the currently selected Workspace.

Example:

```text
  default
* dev
  stage
  prod
```

---

## Create a Workspace

```bash
terraform workspace new dev
```

This creates a new Workspace and selects it.

Other examples:

```bash
terraform workspace new stage
terraform workspace new prod
```

---

## Select a Workspace

```bash
terraform workspace select dev
```

This switches Terraform to the specified Workspace.

---

## Show Current Workspace

```bash
terraform workspace show
```

Example output:

```text
dev
```

---

## Delete a Workspace

```bash
terraform workspace delete dev
```

A Workspace should generally have no managed resources before it is deleted.

---

# Workspaces and Terraform State

The most important concept to understand is the relationship between Workspaces and state.

Terraform state records information about the infrastructure managed by Terraform.

With multiple Workspaces, each Workspace has an independent state.

For example:

```text
dev
 └── State A

stage
 └── State B

prod
 └── State C
```

Changing from `dev` to `stage` does not merge the two states.

This is the primary reason Workspaces can be useful when the same Terraform configuration needs to manage multiple independent environments.

---

# Local Workspace State

When Terraform uses the local backend, Workspace-specific state is stored using a structure similar to:

```text
terraform.tfstate
terraform.tfstate.backup

terraform.tfstate.d/
├── dev/
│   └── terraform.tfstate
├── stage/
│   └── terraform.tfstate
└── prod/
    └── terraform.tfstate
```

The exact state storage behavior depends on the backend being used.

The important concept is that Terraform maintains a distinct state for each Workspace.

---

# Workspaces and Variables

Workspaces themselves do not automatically provide environment-specific values.

For example, simply creating:

```text
dev
stage
prod
```

does not automatically change:

```text
instance_type
region
AMI
instance_name
```

Those differences need to be implemented through Terraform configuration and variables.

One possible pattern is:

```text
dev.tfvars
stage.tfvars
prod.tfvars
```

combined with:

```text
dev Workspace
stage Workspace
prod Workspace
```

For example:

```bash
terraform workspace select dev
terraform apply -var-file="dev.tfvars"
```

and:

```bash
terraform workspace select stage
terraform apply -var-file="stage.tfvars"
```

This separates two concepts:

**Workspace**

> Which Terraform state am I working with?

**Variables**

> What configuration values should be used?

They can be used together, but they solve different problems.

---

# Workspaces and Modules

Modules and Workspaces solve different problems.

### Module

A module is primarily about **reusing infrastructure configuration**.

For example:

```text
EC2 Module
    |
    +── Create instance
    +── Configure instance
    +── Return outputs
```

### Workspace

A Workspace is primarily about **maintaining separate Terraform states for the same configuration**.

For example:

```text
EC2 Module
    |
    +── dev state
    +── stage state
    +── prod state
```

They can therefore be combined.

A reusable module can represent the infrastructure, while Workspaces can represent different instances/environments of that infrastructure.

---

# When Are Workspaces Useful?

Workspaces are particularly useful when:

* The infrastructure configuration is largely the same between environments.
* Multiple independent instances of the same configuration are required.
* State separation is needed.
* A small or relatively simple Terraform project needs multiple environment states.
* Temporary environments need to be created from the same configuration.
* You want to experiment with multiple infrastructure instances without duplicating the entire configuration.

A common conceptual example is:

```text
Same Application Infrastructure

       |
       +── Development
       +── Testing
       +── Staging
       +── Temporary Environment
```

Each environment can have its own Terraform state.

---

# When Should You Be Careful With Workspaces?

Workspaces should not automatically be treated as the best solution for every multi-environment architecture.

Production environments often have requirements beyond simply separating Terraform state.

For example:

* Different AWS accounts.
* Different IAM permissions.
* Different state backends.
* Different security boundaries.
* Different deployment pipelines.
* Different teams responsible for environments.
* Stronger protection around production infrastructure.
* Independent infrastructure lifecycles.

In these situations, separate Terraform configurations or directories may provide clearer isolation.

---

# Workspaces vs Separate Environment Configurations

There are two common approaches.

## Approach 1 — Workspaces

```text
terraform/
│
├── main.tf
├── variables.tf
├── modules/
│
└── Workspaces
      ├── dev
      ├── stage
      └── prod
```

The configuration is shared.

The state is separated through Workspaces.

### Advantages

* Less configuration duplication.
* Simple to understand.
* Convenient when environments are structurally very similar.
* Easy to create temporary environments.
* Useful for smaller projects and experiments.

### Disadvantages

* Environment separation can become less obvious as the project grows.
* Easy to accidentally run commands against the wrong Workspace.
* Workspaces do not provide complete security or account isolation.
* Different environments may eventually require significantly different configurations.

---

## Approach 2 — Separate Environment Configurations

Another approach is:

```text
terraform/
│
├── modules/
│   └── instances/
│
└── environments/
    ├── dev/
    ├── stage/
    └── prod/
```

Each environment has its own root configuration and potentially its own backend/state.

### Advantages

* Clear environment boundaries.
* Easier to apply different policies to production.
* Can use different AWS accounts or backends.
* Better suited to larger infrastructure architectures.
* Environment configuration is explicit.

### Disadvantages

* More configuration to maintain.
* Some duplication may occur if the architecture is not properly modularized.
* Slightly more setup.

---

# Workspaces Do Not Create Infrastructure Isolation

A very important distinction:

> **Terraform Workspaces provide state isolation, not complete infrastructure or security isolation.**

For example, creating:

```text
dev
stage
prod
```

Workspaces does not automatically create:

```text
AWS Account A
AWS Account B
AWS Account C
```

nor does it automatically create separate:

* IAM permissions
* VPCs
* AWS accounts
* credentials
* security boundaries
* CI/CD pipelines

Those must be designed separately.

Therefore, Workspaces should be understood primarily as a **Terraform state-management mechanism**.

---

# The Risk of the Wrong Workspace

One practical risk of Workspaces is running Terraform commands against the wrong Workspace.

For example:

```bash
terraform workspace select prod
terraform apply
```

If the user intended to work with `dev`, the command could affect production infrastructure.

For this reason, it is good practice to verify the active Workspace:

```bash
terraform workspace show
```

before performing important operations.

A simple workflow is:

```bash
terraform workspace show
terraform plan
terraform apply
```

This makes the current state context explicit before making infrastructure changes.

---

# Workspaces and State Backends

Terraform state can be stored locally or remotely.

In a local setup, Workspace-specific state may appear under:

```text
terraform.tfstate.d/
```

In real infrastructure environments, Terraform state is commonly stored remotely so that teams and automation systems can access it.

Remote state can provide capabilities such as:

* Centralized state storage.
* Team collaboration.
* State locking, depending on the backend.
* Better protection of state.
* Integration with CI/CD workflows.

The exact Workspace behavior and state organization depend on the backend being used.

---

# Workspaces and Git

Terraform state should generally not be committed to Git.

Avoid committing:

```text
terraform.tfstate
terraform.tfstate.backup
terraform.tfstate.d/
```

State files can contain infrastructure information and potentially sensitive values.

Similarly, environment-specific `.tfvars` files should not be committed when they contain sensitive or private configuration.

A safer repository can contain:

```text
terraform.tfvars.example
dev.tfvars.example
stage.tfvars.example
prod.tfvars.example
```

with placeholder values.

---

# Typical Multi-Environment Pattern

A simple Workspace-based environment setup can look like:

```text
                        Terraform Code
                              |
               +--------------+--------------+
               |              |              |
               v              v              v
             dev            stage           prod
               |              |              |
               v              v              v
          dev.tfvars     stage.tfvars     prod.tfvars
               |              |              |
               v              v              v
          Dev State       Stage State       Prod State
```

The configuration is shared, while the state and input values can differ.

---

# Example Workflow

A basic environment workflow could be:

```bash
# Create environments
terraform workspace new dev
terraform workspace new stage
terraform workspace new prod

# Development
terraform workspace select dev
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="dev.tfvars"

# Staging
terraform workspace select stage
terraform plan -var-file="stage.tfvars"
terraform apply -var-file="stage.tfvars"

# Production
terraform workspace select prod
terraform plan -var-file="prod.tfvars"
terraform apply -var-file="prod.tfvars"
```

The important thing to understand is that the same Terraform configuration is being reused while Terraform operates against different Workspace states.

---

# Important Concepts to Remember

### Workspace

**Defines which Terraform state instance is currently being used.**

```text
dev
stage
prod
```

### Variables

**Define the values used by the configuration.**

```text
instance_type
ami_id
instance_name
```

### `.tfvars`

**Provides concrete values for variables.**

```text
dev.tfvars
stage.tfvars
prod.tfvars
```

### Module

**Provides reusable infrastructure configuration.**

```text
EC2 module
```

### State

**Records Terraform's knowledge of managed infrastructure.**

```text
Dev state
Stage state
Prod state
```

Together:

```text
Module
  +
Variables
  +
Workspace
  +
State
  =
Reusable Multi-Environment Terraform Configuration
```

---

# Key Takeaway

The easiest way to remember Terraform Workspaces is:

> **A Workspace gives the same Terraform configuration a different state.**

For example:

```text
Same Code
   |
   +── dev   → State A
   |
   +── stage → State B
   |
   +── prod  → State C
```

Workspaces are therefore mainly about **state separation and configuration reuse**, not about creating complete security or infrastructure boundaries between environments.

For small, similar environments and learning/experimental setups, Workspaces can be a convenient solution.

For larger production environments with strong isolation requirements, separate configurations, state backends, AWS accounts, and deployment pipelines may be more appropriate.
