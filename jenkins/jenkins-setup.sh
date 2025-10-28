#!/bin/bash
###############################################################################
# Jenkins Setup Script
# This script automates Jenkins installation and initial configuration
###############################################################################

set -e  # Exit on error

echo "========================================="
echo "  Jenkins Installation Script"
echo "========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    print_error "Please run this script as root or with sudo"
    exit 1
fi

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    print_error "Cannot detect OS"
    exit 1
fi

print_status "Detected OS: $OS"

# Update system
print_status "Updating system packages..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt-get update -qq
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum update -y -q
fi

# Install Java
print_status "Installing Java..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt-get install -y openjdk-11-jdk
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum install -y java-11-openjdk java-11-openjdk-devel
fi

# Verify Java installation
if java -version 2>&1 | grep -q "openjdk version"; then
    print_status "Java installed successfully"
else
    print_error "Java installation failed"
    exit 1
fi

# Install Jenkins
print_status "Installing Jenkins..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    # Add Jenkins repository
    curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key | \
        tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
    
    echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
        https://pkg.jenkins.io/debian-stable binary/ | \
        tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    
    apt-get update -qq
    apt-get install -y jenkins
    
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    # Add Jenkins repository
    wget -O /etc/yum.repos.d/jenkins.repo \
        https://pkg.jenkins.io/redhat-stable/jenkins.repo
    rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io.key
    
    yum install -y jenkins
fi

# Start Jenkins
print_status "Starting Jenkins service..."
systemctl start jenkins
systemctl enable jenkins

# Wait for Jenkins to start
print_status "Waiting for Jenkins to start..."
sleep 30

# Check if Jenkins is running
if systemctl is-active --quiet jenkins; then
    print_status "Jenkins is running"
else
    print_error "Jenkins failed to start"
    exit 1
fi

# Install additional tools
print_status "Installing additional tools..."

# Install Git
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt-get install -y git
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum install -y git
fi

# Install Terraform
print_status "Installing Terraform..."
TERRAFORM_VERSION="1.6.0"
wget -q https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip -q terraform_${TERRAFORM_VERSION}_linux_amd64.zip
mv terraform /usr/local/bin/
rm terraform_${TERRAFORM_VERSION}_linux_amd64.zip
chmod +x /usr/local/bin/terraform

# Verify Terraform
if terraform version &> /dev/null; then
    print_status "Terraform installed successfully"
else
    print_warning "Terraform installation may have issues"
fi

# Install Azure CLI
print_status "Installing Azure CLI..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | bash
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    rpm --import https://packages.microsoft.com/keys/microsoft.asc
    echo -e "[azure-cli]
name=Azure CLI
baseurl=https://packages.microsoft.com/yumrepos/azure-cli
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc" | \
        tee /etc/yum.repos.d/azure-cli.repo
    yum install -y azure-cli
fi

# Install Docker (optional)
print_status "Installing Docker..."
if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apt-get install -y docker.io
    systemctl start docker
    systemctl enable docker
    usermod -aG docker jenkins
elif [ "$OS" = "centos" ] || [ "$OS" = "rhel" ]; then
    yum install -y docker
    systemctl start docker
    systemctl enable docker
    usermod -aG docker jenkins
fi

# Configure firewall
print_status "Configuring firewall..."
if command -v ufw &> /dev/null; then
    ufw allow 8080/tcp
    ufw allow 22/tcp
    print_status "Firewall configured (ufw)"
elif command -v firewall-cmd &> /dev/null; then
    firewall-cmd --permanent --add-port=8080/tcp
    firewall-cmd --permanent --add-port=22/tcp
    firewall-cmd --reload
    print_status "Firewall configured (firewalld)"
fi

# Get initial admin password
print_status "========================================="
echo ""
print_status "Jenkins installation completed!"
echo ""
print_status "Access Jenkins at: http://$(hostname -I | awk '{print $1}'):8080"
echo ""
print_status "Initial admin password:"
echo ""
cat /var/lib/jenkins/secrets/initialAdminPassword
echo ""
print_status "========================================="
echo ""
print_warning "Next steps:"
echo "1. Open Jenkins in your browser"
echo "2. Enter the initial admin password shown above"
echo "3. Install suggested plugins"
echo "4. Create admin user"
echo "5. Configure Jenkins with Azure credentials"
echo ""
print_status "========================================="

# Save installation info
cat > /root/jenkins-installation-info.txt << EOF
Jenkins Installation Information
=================================
Installation Date: $(date)
Jenkins URL: http://$(hostname -I | awk '{print $1}'):8080
Initial Admin Password: $(cat /var/lib/jenkins/secrets/initialAdminPassword)

Installed Tools:
- Java: $(java -version 2>&1 | head -n 1)
- Git: $(git --version)
- Terraform: $(terraform version | head -n 1)
- Azure CLI: $(az --version | head -n 1)
- Docker: $(docker --version)

Configuration Files:
- Jenkins Home: /var/lib/jenkins
- Jenkins Logs: /var/log/jenkins/jenkins.log
- Service Status: systemctl status jenkins

Next Steps:
1. Access Jenkins at http://$(hostname -I | awk '{print $1}'):8080
2. Complete initial setup wizard
3. Install required plugins
4. Configure credentials
5. Create your first pipeline

EOF

print_status "Installation information saved to: /root/jenkins-installation-info.txt"

exit 0