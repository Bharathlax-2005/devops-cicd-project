#!/bin/bash
###############################################################################
# Deployment Script
# Automates the deployment process for DevOps CI/CD project
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_header() {
    echo ""
    echo "========================================="
    echo "  $1"
    echo "========================================="
    echo ""
}

# Check if running from project root
if [ ! -d "terraform" ] || [ ! -d "app" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "DevOps CI/CD Deployment Script"

# Parse arguments
AUTO_APPROVE=false
SKIP_PLAN=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_APPROVE=true
            shift
            ;;
        --skip-plan)
            SKIP_PLAN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes        Auto-approve Terraform apply"
            echo "  --skip-plan      Skip Terraform plan step"
            echo "  -h, --help       Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Step 1: Check prerequisites
print_header "Step 1: Checking Prerequisites"

# Check Terraform
if ! command -v terraform &> /dev/null; then
    print_error "Terraform is not installed"
    print_info "Install from: https://www.terraform.io/downloads"
    exit 1
fi
print_status "Terraform: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"

# Check Azure CLI
if ! command -v az &> /dev/null; then
    print_error "Azure CLI is not installed"
    print_info "Install from: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli"
    exit 1
fi
print_status "Azure CLI: $(az version --query '\"azure-cli\"' -o tsv)"

# Check Git
if ! command -v git &> /dev/null; then
    print_warning "Git is not installed (optional but recommended)"
else
    print_status "Git: $(git --version | cut -d' ' -f3)"
fi

# Step 2: Azure authentication check
print_header "Step 2: Verifying Azure Authentication"

if az account show &> /dev/null; then
    SUBSCRIPTION_NAME=$(az account show --query name -o tsv)
    SUBSCRIPTION_ID=$(az account show --query id -o tsv)
    print_status "Authenticated to Azure"
    print_info "Subscription: $SUBSCRIPTION_NAME"
    print_info "ID: $SUBSCRIPTION_ID"
else
    print_error "Not authenticated to Azure"
    print_info "Please run: az login"
    exit 1
fi

# Step 3: Validate Terraform configuration
print_header "Step 3: Validating Terraform Configuration"

cd terraform

# Check if terraform.tfvars exists
if [ ! -f "terraform.tfvars" ]; then
    print_error "terraform.tfvars not found"
    print_info "Please create terraform.tfvars with your Azure credentials"
    exit 1
fi

# Initialize Terraform
print_info "Initializing Terraform..."
terraform init -upgrade

# Validate configuration
print_info "Validating Terraform configuration..."
if terraform validate; then
    print_status "Terraform configuration is valid"
else
    print_error "Terraform configuration validation failed"
    exit 1
fi

# Step 4: Create execution plan
if [ "$SKIP_PLAN" = false ]; then
    print_header "Step 4: Creating Execution Plan"
    
    print_info "Creating Terraform plan..."
    terraform plan -out=tfplan -var-file=terraform.tfvars
    
    print_status "Plan created successfully"
    print_warning "Review the plan above carefully"
    
    if [ "$AUTO_APPROVE" = false ]; then
        echo ""
        read -p "Do you want to apply this plan? (yes/no): " CONFIRM
        if [ "$CONFIRM" != "yes" ]; then
            print_warning "Deployment cancelled"
            rm -f tfplan
            exit 0
        fi
    fi
else
    print_warning "Skipping plan step (--skip-plan flag set)"
fi

# Step 5: Apply Terraform configuration
print_header "Step 5: Deploying Infrastructure"

print_info "Applying Terraform configuration..."
START_TIME=$(date +%s)

if [ "$SKIP_PLAN" = false ]; then
    terraform apply tfplan
else
    if [ "$AUTO_APPROVE" = true ]; then
        terraform apply -auto-approve -var-file=terraform.tfvars
    else
        terraform apply -var-file=terraform.tfvars
    fi
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

print_status "Infrastructure deployed successfully!"
print_info "Deployment time: ${DURATION} seconds"

# Step 6: Get outputs
print_header "Step 6: Deployment Information"

# Save outputs
terraform output -json > outputs.json
terraform output > outputs.txt

# Display key information
PUBLIC_IP=$(terraform output -raw public_ip_address 2>/dev/null || echo "N/A")
VM_NAME=$(terraform output -raw vm_name 2>/dev/null || echo "N/A")
RESOURCE_GROUP=$(terraform output -raw resource_group_name 2>/dev/null || echo "N/A")

print_status "Resource Group: $RESOURCE_GROUP"
print_status "VM Name: $VM_NAME"
print_status "Public IP: $PUBLIC_IP"

if [ "$PUBLIC_IP" != "N/A" ]; then
    print_status "Application URL: http://$PUBLIC_IP"
    print_status "SSH Command: ssh $(terraform output -raw admin_username)@$PUBLIC_IP"
fi

# Step 7: Wait for VM initialization
print_header "Step 7: Waiting for Application Initialization"

print_info "Waiting for VM to complete cloud-init (90 seconds)..."
for i in {1..90}; do
    echo -n "."
    sleep 1
done
echo ""

# Step 8: Health check
print_header "Step 8: Performing Health Check"

if [ "$PUBLIC_IP" != "N/A" ]; then
    print_info "Checking application availability..."
    
    MAX_RETRIES=10
    RETRY_COUNT=0
    
    while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
        if curl -s -o /dev/null -w "%{http_code}" "http://$PUBLIC_IP" | grep -q "200"; then
            print_status "Application is responding!"
            break
        else
            RETRY_COUNT=$((RETRY_COUNT + 1))
            print_info "Retry $RETRY_COUNT/$MAX_RETRIES - Waiting 10 seconds..."
            sleep 10
        fi
    done
    
    if [ $RETRY_COUNT -eq $MAX_RETRIES ]; then
        print_warning "Application may still be initializing"
        print_info "Please check manually at: http://$PUBLIC_IP"
    fi
fi

# Step 9: Generate deployment report
print_header "Step 9: Generating Deployment Report"

REPORT_FILE="../deployment-report-$(date +%Y%m%d-%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
========================================
DevOps CI/CD Deployment Report
========================================

Deployment Date: $(date)
Deployment Duration: ${DURATION} seconds

Infrastructure Details:
-----------------------
Resource Group: $RESOURCE_GROUP
Location: $(terraform output -raw location 2>/dev/null || echo "N/A")
VM Name: $VM_NAME
VM Size: $(az vm show -g "$RESOURCE_GROUP" -n "$VM_NAME" --query hardwareProfile.vmSize -o tsv 2>/dev/null || echo "N/A")
Public IP: $PUBLIC_IP

Access Information:
-------------------
Application URL: http://$PUBLIC_IP
SSH Access: ssh $(terraform output -raw admin_username 2>/dev/null)@$PUBLIC_IP

Terraform Outputs:
------------------
$(cat outputs.txt)

Next Steps:
-----------
1. Access application: http://$PUBLIC_IP
2. Verify deployment: Check Azure Portal
3. Test CI/CD: Make changes and push to GitHub
4. Monitor: Check application logs

To destroy resources:
cd $(pwd)
terraform destroy -var-file=terraform.tfvars

========================================
EOF

print_status "Deployment report saved: $REPORT_FILE"

# Step 10: Final summary
print_header "🎉 Deployment Completed Successfully!"

cat << EOF
┌─────────────────────────────────────────┐
│          Quick Access Links             │
├─────────────────────────────────────────┤
│ Application: http://$PUBLIC_IP
│ Azure Portal: https://portal.azure.com
│ Resource Group: $RESOURCE_GROUP
└─────────────────────────────────────────┘

Next Steps:
1. Open http://$PUBLIC_IP in your browser
2. Set up Jenkins pipeline for CI/CD
3. Configure GitHub webhooks
4. Test automated deployments

For cleanup: ./scripts/cleanup.sh
For help: ./scripts/deploy.sh --help
EOF

cd ..

exit 0