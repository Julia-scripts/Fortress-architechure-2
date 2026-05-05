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
