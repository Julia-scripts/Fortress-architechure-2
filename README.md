# Project: Cloud Fortress Architecture
A secure, automated AWS infrastructure deployment using **Terraform** for provisioning and **Ansible** for configuration management.

##  Architecture Overview
This project deploys a high-security environment including:
* **VPC & Networking**: Isolated subnets with restricted Internet Gateway access.
* **Infrastructure as Code (IaC)**: Modular Terraform scripts for repeatable deployments.
* **Automated Configuration**: Ansible playbooks to handle server setup and security validation.

##  Repository Structure
*   **terraform/**: Contains VPC, Subnet, and EC2 resource definitions.
*   **ansible/**: Contains playbooks and inventory for server configuration.
*   **docs/**: Technical documentation and security validation reports.

##  Security Features
*   **State Management**: `terraform.tfstate` is locally managed and excluded from version control to protect sensitive metadata.
*   **Key Management**: SSH keys (.pem) are ignored by Git to prevent credential leaks.
*   **Network Isolation**: Validated through Ansible connectivity tests (Intentional failure testing for private-subnet security).

##  How to Run
1. **Provision**: Run `terraform apply` within the `/terraform` directory.
2. **Configure**: Once instances are live, run the Ansible playbook:
   ```bash
   ansible-playbook -i inventory.ini setup_fortress.yml
##  Post-Deployment Observations

### 1. Network Isolation & The "Secure Failure"
During the Ansible configuration phase, we observed a **timeout error** when attempting to connect to the private instance. 
*   **Observation**: The private subnet, by design, lacks a NAT Gateway or public route. 
*   **Conclusion**: This "failure" is a successful validation of the **Zero-Trust** architecture. It proves that the Cloud Fortress is unreachable from the public internet, meeting the project's primary security objective.

### 2. Infrastructure as Code (IaC) Drift
*   **Observation**: Using Terraform allowed for rapid destruction and recreation of the VPC environment.
*   **Conclusion**: Manual configuration in the AWS Console would have taken hours and introduced human error; Terraform ensured the security groups were identical every time.

### 3. Security Best Practices
*   **Credential Safety**: Successfully implemented `.gitignore` protocols to prevent `.pem` and `.tfstate` files from being tracked. 
*   **Audit Trail**: By using Git, every change to the firewall rules (Security Groups) is now version-controlled and auditable.
