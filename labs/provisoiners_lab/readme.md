# Terraform Provisioners Lab 🚀

A hands-on Terraform lab to understand how **Terraform Provisioners** can be used to configure an AWS EC2 instance after infrastructure creation.

## 🏗️ Infrastructure

Created the following AWS resources using Terraform:

* VPC
* Public Subnet
* Internet Gateway
* Route Table & Route Table Association
* Security Group
* EC2 Key Pair
* EC2 Instance

The EC2 instance was configured with Terraform provisioners to deploy and run a simple Flask application.

## ⚙️ Provisioners Used

### `file` Provisioner

Copied the Flask application files from the local machine to the EC2 instance.

### `remote-exec` Provisioner

Configured the EC2 instance remotely by:

* Installing Python/Pip
* Creating a Python virtual environment
* Activating the virtual environment
* Installing the application's dependencies
* Starting the Flask application on **port 80**

The Flask application itself was configured to listen on port 80.

## 🔄 Deployment Flow

```text
Terraform
   ↓
AWS Infrastructure
   ↓
EC2 Instance
   ↓
file provisioner
   ↓
Flask App copied to EC2
   ↓
remote-exec
   ↓
Install Python/Pip + venv
   ↓
Create Virtual Environment
   ↓
Install Dependencies
   ↓
Run Flask App
   ↓
Access App through EC2 Public IP
```

## 🐛 Problems Faced & Recovery

### 1. SSH Connection / Provisioner Failure

**Problem:** Terraform created the EC2 instance, but the provisioner initially failed to connect.

**Recovery:** Verified the EC2 public IP, SSH key, username and Security Group SSH rule, then re-ran the deployment.

### 2. Flask App Not Accessible

**Problem:** The application was running on EC2 but was not reachable from the browser.

**Recovery:** Verified that the Security Group allowed inbound traffic on **port 80** and that the Flask application was listening on the correct interface/port.

### 3. Python Environment / Dependency Issues

**Problem:** The Flask application could not run correctly because the required Python environment/dependencies were not ready.

**Recovery:** Created a dedicated virtual environment on the EC2 instance and installed the application's dependencies before starting the application.

## 📚 Key Takeaways

* How Terraform creates and configures AWS infrastructure.
* Practical use of `file` and `remote-exec` provisioners.
* Using SSH connections for remote Terraform provisioning.
* Deploying a simple application directly from Terraform.
* Understanding the dependency between **infrastructure readiness, SSH connectivity, Security Groups and application availability**.
* Troubleshooting failed Terraform provisioning instead of rebuilding the entire infrastructure.

> **Note:** Provisioners are useful for learning and certain configuration tasks, but Terraform-native resources or dedicated configuration-management tools are generally preferred for production deployments.
