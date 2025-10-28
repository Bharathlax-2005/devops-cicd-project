# 🚀 Automated Deployment Pipeline - Azure, Terraform & Jenkins

## Project Overview
Complete DevOps pipeline automating web application deployment on Microsoft Azure using:
- **Terraform** - Infrastructure as Code
- **Jenkins** - CI/CD Pipeline
- **Docker** - Containerization
- **Azure** - Cloud Platform

## 📋 Table of Contents
1. [Prerequisites](#prerequisites)
2. [Project Architecture](#project-architecture)
3. [Setup Guide](#setup-guide)
4. [Project Structure](#project-structure)
5. [Deployment Steps](#deployment-steps)
6. [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Required Accounts
- **Azure Account** (Free tier available)
- **GitHub Account**
- **Jenkins Server** (VM or local)

### Required Tools
- Azure CLI
- Terraform (v1.0+)
- Git
- Docker (optional)
- Text editor (VS Code recommended)

### System Requirements
- OS: Windows 10/11, macOS, or Linux
- RAM: 4GB minimum
- Storage: 10GB free space

---

## Project Architecture

```
┌─────────────┐         ┌──────────────┐         ┌─────────────┐
│   GitHub    │────────▶│   Jenkins    │────────▶│    Azure    │
│ (Source)    │         │  (CI/CD)     │         │   (Cloud)   │
└─────────────┘         └──────────────┘         └─────────────┘
      │                        │                         │
      │                        ▼                         ▼
      │                  ┌──────────┐            ┌─────────────┐
      └─────────────────▶│ Terraform│───────────▶│   Web App   │
                         │  (IaC)   │            │  (Running)  │
                         └──────────┘            └─────────────┘
```

---

## Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/devops-cicd-project.git
cd devops-cicd-project

# 2. Initialize Terraform
cd terraform
terraform init

# 3. Deploy infrastructure
terraform plan
terraform apply -auto-approve

# 4. Access your application
# Check outputs for public IP/URL
```

---

## 📁 Project Structure

```
devops-cicd-project/
│
├── README.md
├── SETUP_GUIDE.md
├── .gitignore
│
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars
│   └── provider.tf
│
├── app/
│   ├── index.html
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── jenkins/
│   ├── Jenkinsfile
│   └── jenkins-setup.sh
│
├── scripts/
│   ├── deploy.sh
│   └── cleanup.sh
│
└── docs/
    ├── architecture-diagram.png
    └── screenshots/
```

---

## 🎯 Learning Outcomes

By completing this project, you will:
- ✅ Understand Infrastructure as Code (IaC)
- ✅ Master CI/CD pipeline creation
- ✅ Learn cloud resource management
- ✅ Practice DevOps best practices
- ✅ Gain hands-on Azure experience

---

## 📞 Support

- **Issues**: Open a GitHub issue
- **Documentation**: Check `/docs` folder
- **Contact**: [your-email@example.com]

---

## 📄 License

This project is licensed under the MIT License - see LICENSE file for details.

---

**Created for DevOps Learning | 2024**