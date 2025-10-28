# ⚡ Quick Start Guide

Get up and running with the DevOps CI/CD pipeline in 15 minutes!

---

## 🎯 Prerequisites Checklist

Before starting, ensure you have:

- [ ] **Azure Account** with active subscription ([Get free account](https://azure.microsoft.com/free))
- [ ] **GitHub Account** ([Sign up](https://github.com/join))
- [ ] **Computer** with internet connection
- [ ] **30 minutes** of your time

---

## 🚀 5-Step Quick Deployment

### Step 1: Set Up Azure (5 minutes)

```bash
# Install Azure CLI (choose your OS)

# macOS:
brew install azure-cli

# Windows (PowerShell as Administrator):
winget install Microsoft.AzureCLI

# Linux:
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Login to Azure
az login

# Create Service Principal
az ad sp create-for-rbac --name "terraform-devops" --role="Contributor"
```

**⚠️ SAVE THE OUTPUT** - You'll need it later!

---

### Step 2: Install Terraform (2 minutes)

```bash
# macOS:
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Windows (PowerShell as Administrator):
choco install terraform

# Linux:
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform

# Verify installation
terraform version
```

---

### Step 3: Clone and Configure (3 minutes)

```bash
# Clone the repository
git clone https://github.com/YOUR_USERNAME/devops-cicd-project.git
cd devops-cicd-project

# Edit Terraform variables
cd terraform
nano terraform.tfvars  # or use your favorite editor
```

**Update these values in `terraform.tfvars`:**
```hcl
subscription_id = "YOUR_AZURE_SUBSCRIPTION_ID"
client_id       = "YOUR_SERVICE_PRINCIPAL_APP_ID"
client_secret   = "YOUR_SERVICE_PRINCIPAL_PASSWORD"
tenant_id       = "YOUR_AZURE_TENANT_ID"
admin_password  = "YourStrongP@ssw0rd123!"  # Change this!
```

---

### Step 4: Deploy Infrastructure (5 minutes)

```bash
# Initialize Terraform
terraform init

# Review what will be created
terraform plan

# Deploy (type 'yes' when prompted)
terraform apply

# Wait for completion (3-5 minutes)
```

---

### Step 5: Access Your Application (1 minute)

```bash
# Get the public IP
terraform output public_ip_address

# Open in browser
# http://YOUR_PUBLIC_IP
```

**🎉 Congratulations!** Your application is live!

---

## 🔧 Optional: Set Up Jenkins CI/CD

### Quick Jenkins Setup (10 minutes)

```bash
# Install Jenkins using Docker (easiest method)
docker run -d -p 8080:8080 -p 50000:50000 \
  --name jenkins \
  -v jenkins_home:/var/jenkins_home \
  jenkins/jenkins:lts

# Get initial password
docker exec jenkins cat /var/jenkins_home/secrets/initialAdminPassword

# Open Jenkins
# http://localhost:8080
```

**Configure Jenkins**:
1. Paste initial admin password
2. Install suggested plugins (wait 5 minutes)
3. Create admin user
4. Install additional plugins:
   - Git plugin
   - GitHub plugin
   - Pipeline plugin
   - Terraform plugin

**Create Pipeline**:
1. New Item → Pipeline
2. Pipeline script from SCM → Git
3. Repository URL: `https://github.com/YOUR_USERNAME/devops-cicd-project.git`
4. Script Path: `jenkins/Jenkinsfile`
5. Save and Build!

---

## 🎓 What You Just Did

✅ Created Azure infrastructure with Terraform  
✅ Deployed a web application automatically  
✅ Set up CI/CD pipeline with Jenkins (optional)  
✅ Learned DevOps practices hands-on  

---

## 📋 Quick Command Reference

```bash
# View all resources
terraform state list

# Get outputs again
terraform output

# SSH into VM
ssh azureuser@YOUR_PUBLIC_IP

# View application logs
ssh azureuser@YOUR_PUBLIC_IP
sudo tail -f /var/log/cloud-init.log

# Destroy everything (when done)
terraform destroy -auto-approve
```

---

## 🐛 Quick Troubleshooting

### Issue: "terraform apply" fails
**Solution**: Check your Azure credentials in `terraform.tfvars`

### Issue: Can't access application
**Solution**: Wait 2-3 minutes after deployment for VM initialization

### Issue: SSH connection refused
**Solution**: Check NSG rules allow port 22 from your IP

### Issue: Jenkins can't find Terraform
**Solution**: Install Terraform on Jenkins server (see full setup guide)

---

## 🎯 Next Steps

1. **Customize the application**: Edit `app/index.html` and push to GitHub
2. **Set up automated deployments**: Configure GitHub webhook to Jenkins
3. **Add monitoring**: Enable Azure Monitor for your resources
4. **Explore features**: Check out `/api/info` and `/api/health` endpoints
5. **Learn more**: Read the full [Architecture Documentation](./ARCHITECTURE.md)

---

## 💰 Cost Management

**Daily Cost**: ~$1-2 (with free tier, $0 for first month)

**To avoid charges**:
```bash
# Destroy all resources when not in use
terraform destroy -auto-approve
```

**Pro Tip**: Use `scripts/cleanup.sh` for safe cleanup with confirmation!

---

## 🆘 Need Help?

- 📖 **Full Guide**: See [SETUP_GUIDE.md](../SETUP_GUIDE.md)
- 🏗️ **Architecture**: See [ARCHITECTURE.md](./ARCHITECTURE.md)
- 🐛 **Issues**: Open a GitHub issue
- 💬 **Community**: Join discussions tab

---

## ✅ Success Checklist

- [ ] Azure account created and logged in
- [ ] Terraform installed and working
- [ ] Repository cloned
- [ ] `terraform.tfvars` configured with your credentials
- [ ] `terraform apply` completed successfully
- [ ] Application accessible via public IP
- [ ] Jenkins installed and configured (optional)
- [ ] First pipeline run successful (optional)

---

**Time to complete**: 15-25 minutes  
**Cost**: $0 (with Azure free tier) to $50/month  
**Skill level**: Beginner to Intermediate  

**Happy DevOps-ing! 🚀**