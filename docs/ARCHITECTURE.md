# 🏗️ Architecture Documentation

## System Architecture Overview

This document provides a comprehensive view of the DevOps CI/CD pipeline architecture, including all components, data flows, and integrations.

---

## 1. High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Developer Workflow                        │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│  GitHub Repository (Source Code + Infrastructure Code)          │
│  - Application Code (Python/HTML)                               │
│  - Terraform Configs                                            │
│  - Jenkinsfile                                                  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Webhook Trigger
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Jenkins CI/CD Server                          │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Pipeline Stages:                                         │  │
│  │  1. Checkout Code                                         │  │
│  │  2. Install Dependencies                                  │  │
│  │  3. Validate Configuration                                │  │
│  │  4. Terraform Plan                                        │  │
│  │  5. Terraform Apply                                       │  │
│  │  6. Build Application                                     │  │
│  │  7. Deploy to Azure                                       │  │
│  │  8. Health Check                                          │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Azure API Calls
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Microsoft Azure Cloud                         │
│  ┌───────────────────────────────────────────────────────────┐  │
│  │  Resource Group                                           │  │
│  │  ├── Virtual Network                                      │  │
│  │  │   ├── Subnet                                          │  │
│  │  │   └── Network Security Group                          │  │
│  │  ├── Virtual Machine (Ubuntu 22.04)                      │  │
│  │  │   ├── Nginx Web Server                                │  │
│  │  │   └── Python Flask App                                │  │
│  │  ├── Public IP Address                                   │  │
│  │  └── Storage Account                                     │  │
│  └───────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ HTTP/HTTPS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                         End Users                                │
│  - Web Browser Access                                           │
│  - API Consumers                                                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. Component Details

### 2.1 Source Control (GitHub)

**Purpose**: Version control and code collaboration

**Components**:
- Git repository hosting
- Branch management (main/feature branches)
- Pull request workflow
- Webhook integration with Jenkins

**Files Stored**:
```
├── app/                  # Application code
├── terraform/            # Infrastructure as Code
├── jenkins/              # CI/CD pipeline definition
├── scripts/              # Deployment scripts
└── docs/                 # Documentation
```

---

### 2.2 CI/CD Server (Jenkins)

**Purpose**: Automation orchestration and pipeline execution

**Key Features**:
- Multi-stage pipeline execution
- Automated builds on code commits
- Terraform integration
- Azure CLI integration
- Build artifacts management

**Pipeline Flow**:
1. **Checkout**: Pull latest code from GitHub
2. **Validate**: Check Terraform syntax and configuration
3. **Plan**: Generate infrastructure execution plan
4. **Apply**: Deploy/update Azure resources
5. **Build**: Compile and package application
6. **Deploy**: Deploy application to Azure VM
7. **Test**: Run health checks
8. **Report**: Generate deployment reports

**Plugins Required**:
- Git Plugin
- GitHub Plugin
- Pipeline Plugin
- Terraform Plugin
- Azure CLI Plugin
- Credentials Binding Plugin

---

### 2.3 Infrastructure as Code (Terraform)

**Purpose**: Define and provision Azure infrastructure

**Resources Managed**:

#### Core Resources:
```hcl
Resource Group
├── Virtual Network
│   ├── Subnet (10.0.1.0/24)
│   └── NSG (Security Rules)
├── Public IP (Static)
├── Network Interface
├── Virtual Machine
│   ├── OS: Ubuntu 22.04 LTS
│   ├── Size: Standard_B2s
│   └── Cloud-init configuration
└── Storage Account
    └── Static Website hosting
```

#### Network Security Rules:
- Port 22 (SSH) - Management access
- Port 80 (HTTP) - Web application
- Port 443 (HTTPS) - Secure web access
- Custom application ports (configurable)

**State Management**:
- Local state file (default)
- Optional: Azure Blob Storage backend for teams

---

### 2.4 Cloud Infrastructure (Azure)

**Purpose**: Host application and provide cloud services

#### Virtual Machine Specifications:
- **OS**: Ubuntu 22.04 LTS
- **Size**: Standard_B2s (2 vCPU, 4GB RAM)
- **Disk**: 30GB Standard SSD
- **Network**: Public IP with NSG protection

#### Software Stack on VM:
```
┌─────────────────────────────┐
│     Nginx Web Server        │ ← Port 80/443
├─────────────────────────────┤
│   Python Flask App          │ ← Port 5000
├─────────────────────────────┤
│    Ubuntu 22.04 LTS         │
└─────────────────────────────┘
```

#### Cloud-init Bootstrap Process:
1. Update system packages
2. Install Nginx, Python, Git
3. Configure web server
4. Deploy application files
5. Start services
6. Configure firewall

---

### 2.5 Application Layer

**Purpose**: Serve web application to end users

#### Technology Stack:
- **Frontend**: HTML5, CSS3, JavaScript
- **Backend**: Python 3.11 + Flask
- **Web Server**: Nginx (reverse proxy)
- **Container** (optional): Docker

#### Application Features:
- Interactive web interface
- RESTful API endpoints
- Health check endpoint
- System information display
- Real-time deployment status

#### API Endpoints:
```
GET  /                 → Main web page (HTML)
GET  /api/info         → Server information (JSON)
GET  /api/health       → Health check (JSON)
GET  /api/status       → Deployment status (JSON)
```

---

## 3. Data Flow Diagrams

### 3.1 CI/CD Deployment Flow

```
┌────────────┐
│ Developer  │
│ commits    │
│ code       │
└─────┬──────┘
      │
      ▼
┌────────────┐     ┌──────────────┐
│  GitHub    │────▶│  Webhook     │
│ Repository │     │  Triggers    │
└────────────┘     └──────┬───────┘
                          │
                          ▼
                   ┌──────────────┐
                   │   Jenkins    │
                   │   Pipeline   │
                   └──────┬───────┘
                          │
         ┌────────────────┼────────────────┐
         ▼                ▼                ▼
┌─────────────┐   ┌─────────────┐  ┌─────────────┐
│  Terraform  │   │    Build    │  │   Deploy    │
│  Provision  │   │ Application │  │  to Azure   │
└─────────────┘   └─────────────┘  └─────────────┘
         │                │                │
         └────────────────┴────────────────┘
                          │
                          ▼
                   ┌──────────────┐
                   │    Azure     │
                   │ Infrastructure│
                   └──────────────┘
```

### 3.2 Application Request Flow

```
┌──────────┐         ┌──────────────┐         ┌──────────────┐
│   User   │────────▶│  Public IP   │────────▶│     NSG      │
│ Browser  │         │ (Azure Load) │         │ (Firewall)   │
└──────────┘         └──────────────┘         └──────┬───────┘
                                                      │
                                                      ▼
                     ┌───────────────────────────────────────┐
                     │        Azure Virtual Machine          │
                     │  ┌─────────────────────────────────┐  │
                     │  │         Nginx (Port 80)         │  │
                     │  └─────────────┬───────────────────┘  │
                     │                ▼                      │
                     │  ┌─────────────────────────────────┐  │
                     │  │    Flask App (Port 5000)        │  │
                     │  └─────────────────────────────────┘  │
                     └───────────────────────────────────────┘
                                    │
                                    ▼
                     ┌───────────────────────────────┐
                     │    HTTP Response to User      │
                     └───────────────────────────────┘
```

---

## 4. Security Architecture

### 4.1 Authentication & Authorization

**Azure Service Principal**:
- Application ID (Client ID)
- Client Secret (Password)
- Tenant ID
- Subscription ID

**Jenkins Credentials Management**:
- Encrypted credential storage
- Credentials binding in pipeline
- No hardcoded secrets in code

**SSH Access**:
- Password authentication (demo)
- SSH key authentication (production recommended)

### 4.2 Network Security

**Network Security Group Rules**:
```
Priority  | Direction | Protocol | Port  | Source        | Destination
----------|-----------|----------|-------|---------------|-------------
1001      | Inbound   | TCP      | 22    | 0.0.0.0/0     | *
1002      | Inbound   | TCP      | 80    | 0.0.0.0/0     | *
1003      | Inbound   | TCP      | 443   | 0.0.0.0/0     | *
1004      | Inbound   | TCP      | 5000  | 0.0.0.0/0     | *
```

**Production Recommendations**:
- Restrict SSH to specific IPs
- Enable Azure Firewall
- Implement Web Application Firewall (WAF)
- Use Azure Key Vault for secrets
- Enable Azure DDoS Protection

---

## 5. Monitoring & Logging

### 5.1 Infrastructure Monitoring

**Azure Monitor**:
- VM performance metrics
- Network traffic analysis
- Resource utilization
- Cost monitoring

**Available Metrics**:
- CPU utilization
- Memory usage
- Disk I/O
- Network throughput

### 5.2 Application Logging

**Log Locations**:
- Nginx access log: `/var/log/nginx/access.log`
- Nginx error log: `/var/log/nginx/error.log`
- Application log: `/var/log/app/app.log`
- Cloud-init log: `/var/log/cloud-init.log`

**Jenkins Pipeline Logs**:
- Build console output
- Stage execution time
- Deployment artifacts

---

## 6. Scalability & High Availability

### 6.1 Current Architecture
- **Type**: Single VM deployment
- **Availability**: Single instance
- **Scaling**: Vertical (VM size increase)

### 6.2 Production Enhancements

**Horizontal Scaling**:
```
                    ┌─────────────┐
                    │ Azure Load  │
                    │  Balancer   │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
   ┌────────┐         ┌────────┐         ┌────────┐
   │  VM 1  │         │  VM 2  │         │  VM 3  │
   └────────┘         └────────┘         └────────┘
```

**High Availability Options**:
- Azure Availability Sets
- Azure Availability Zones
- Azure VM Scale Sets
- Azure App Service (PaaS alternative)

**Database Layer** (if needed):
- Azure SQL Database
- Azure Database for PostgreSQL
- Azure Cosmos DB

---

## 7. Disaster Recovery

### 7.1 Backup Strategy

**Infrastructure**:
- Terraform state file backup
- Configuration files in Git

**Data**:
- Azure VM snapshots
- Azure Backup service
- Storage account replication

### 7.2 Recovery Procedures

**Infrastructure Recovery**:
1. Clone Git repository
2. Run Terraform apply
3. Redeploy application

**Estimated RTO** (Recovery Time Objective):
- Infrastructure: 10-15 minutes
- Application: 5 minutes
- Total: ~20 minutes

---

## 8. Cost Optimization

### 8.1 Current Costs (Approximate)

| Resource              | SKU           | Monthly Cost (USD) |
|-----------------------|---------------|--------------------|
| Virtual Machine       | Standard_B2s  | $30-40            |
| Public IP (Static)    | Standard      | $3-4              |
| Storage Account       | Standard LRS  | $2-5              |
| Network Traffic       | First 5GB free| $0.08/GB          |
| **Total**             |               | **~$35-50/month** |

### 8.2 Cost Optimization Tips

1. **Use Azure Free Tier**: 750 hours free VM time/month
2. **Auto-shutdown**: Schedule VM shutdown during off-hours
3. **Right-size VM**: Use B1s ($10/month) for demos
4. **Reserved Instances**: 30-70% savings for long-term use
5. **Spot VMs**: 70-90% discount for non-critical workloads

---

## 9. Future Enhancements

### 9.1 Short-term (1-3 months)
- [ ] Implement Azure Key Vault for secrets
- [ ] Add automated testing in pipeline
- [ ] Set up Azure Monitor alerts
- [ ] Implement blue-green deployment

### 9.2 Medium-term (3-6 months)
- [ ] Migrate to Azure Kubernetes Service (AKS)
- [ ] Implement container registry
- [ ] Add multi-region deployment
- [ ] Implement CI/CD for multiple environments

### 9.3 Long-term (6-12 months)
- [ ] Implement full observability stack
- [ ] Add automated security scanning
- [ ] Implement GitOps workflow
- [ ] Multi-cloud deployment capability

---

## 10. Troubleshooting Guide

### Common Issues and Solutions

| Issue | Cause | Solution |
|-------|-------|----------|
| Terraform fails to apply | Invalid credentials | Verify service principal credentials |
| Jenkins can't access Git | Missing credentials | Add GitHub token to Jenkins |
| VM not accessible | NSG blocking traffic | Check NSG rules, verify public IP |
| Application not responding | Service not started | SSH to VM, check service status |
| High costs | Resources not destroyed | Run cleanup script regularly |

---

## Conclusion

This architecture provides a solid foundation for learning DevOps practices while remaining simple enough for educational purposes. It demonstrates key concepts including Infrastructure as Code, CI/CD automation, and cloud deployment while being cost-effective and easy to understand.

For production use, consider implementing the security and high-availability enhancements mentioned in this document.

---

**Last Updated**: 2024  
**Version**: 1.0  
**Maintained by**: DevOps Team