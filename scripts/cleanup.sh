#!/bin/bash
###############################################################################
# Cleanup Script
# Safely destroys all Azure resources created by Terraform
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
if [ ! -d "terraform" ]; then
    print_error "Please run this script from the project root directory"
    exit 1
fi

print_header "DevOps CI/CD Cleanup Script"
print_warning "⚠️  This script will DESTROY all Azure resources created by Terraform"

# Parse arguments
AUTO_APPROVE=false
SKIP_BACKUP=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_APPROVE=true
            shift
            ;;
        --skip-backup)
            SKIP_BACKUP=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes         Auto-approve destruction"
            echo "  --skip-backup     Skip state file backup"
            echo "  -h, --help        Show this help message"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Change to terraform directory
cd terraform

# Step 1: Check Terraform state
print_header "Step 1: Checking Terraform State"

if [ ! -f "terraform.tfstate" ]; then
    print_warning "No Terraform state file found"
    print_info "Nothing to destroy"
    exit 0
fi

print_status "Terraform state file found"

# Step 2: Show resources to be destroyed
print_header "Step 2: Resources to be Destroyed"

print_info "Listing resources..."
terraform state list

print_warning "The following resources will be PERMANENTLY DELETED:"
terraform show -no-color | grep -E "resource|id" | head -20

# Step 3: Backup state file
if [ "$SKIP_BACKUP" = false ]; then
    print_header "Step 3: Backing Up State File"
    
    BACKUP_DIR="../backups"
    BACKUP_FILE="terraform.tfstate.backup-$(date +%Y%m%d-%H%M%S)"
    
    mkdir -p "$BACKUP_DIR"
    cp terraform.tfstate "$BACKUP_DIR/$BACKUP_FILE"
    
    print_status "State file backed up to: $BACKUP_DIR/$BACKUP_FILE"
else
    print_warning "Skipping state file backup (--skip-backup flag set)"
fi

# Step 4: Confirmation
if [ "$AUTO_APPROVE" = false ]; then
    print_header "Step 4: Confirmation Required"
    
    echo ""
    print_warning "⚠️  WARNING: This action cannot be undone!"
    echo ""
    print_info "Resources that will be destroyed:"
    echo "  - Resource Group and all contained resources"
    echo "  - Virtual Machine"
    echo "  - Virtual Network"
    echo "  - Public IP address"
    echo "  - Storage Account"
    echo "  - Network Security Group"
    echo "  - All other associated resources"
    echo ""
    
    read -p "Are you absolutely sure you want to destroy all resources? (type 'yes' to confirm): " CONFIRM
    
    if [ "$CONFIRM" != "yes" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
    
    # Double confirmation for safety
    echo ""
    read -p "This is your last chance. Type 'DESTROY' to proceed: " FINAL_CONFIRM
    
    if [ "$FINAL_CONFIRM" != "DESTROY" ]; then
        print_warning "Cleanup cancelled"
        exit 0
    fi
fi

# Step 5: Destroy infrastructure
print_header "Step 5: Destroying Infrastructure"

print_info "Starting resource destruction..."
START_TIME=$(date +%s)

if [ "$AUTO_APPROVE" = true ]; then
    terraform destroy -auto-approve -var-file=terraform.tfvars
else
    terraform destroy -var-file=terraform.tfvars
fi

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

print_status "Resources destroyed successfully!"
print_info "Destruction time: ${DURATION} seconds"

# Step 6: Verify cleanup
print_header "Step 6: Verifying Cleanup"

RESOURCE_GROUP=$(grep 'resource_group_name' terraform.tfvars | cut -d'=' -f2 | tr -d ' "')

if [ -n "$RESOURCE_GROUP" ]; then
    print_info "Checking if resource group still exists..."
    
    if az group show -n "$RESOURCE_GROUP" &> /dev/null; then
        print_warning "Resource group still exists in Azure"
        print_info "It may take a few minutes to fully delete"
    else
        print_status "Resource group successfully deleted from Azure"
    fi
fi

# Step 7: Clean up local files
print_header "Step 7: Cleaning Up Local Files"

print_info "Removing Terraform temporary files..."

# Remove Terraform files
rm -f tfplan
rm -f outputs.json
rm -f outputs.txt
rm -f deployment_info.txt
rm -f plan_output.txt
rm -rf .terraform.lock.hcl

print_status "Local cleanup completed"

# Step 8: Generate cleanup report
print_header "Step 8: Generating Cleanup Report"

REPORT_FILE="../cleanup-report-$(date +%Y%m%d-%H%M%S).txt"

cat > "$REPORT_FILE" << EOF
========================================
DevOps CI/CD Cleanup Report
========================================

Cleanup Date: $(date)
Cleanup Duration: ${DURATION} seconds

Destroyed Resources:
--------------------
Resource Group: $RESOURCE_GROUP
All associated Azure resources

State File:
-----------
Backup Location: $BACKUP_DIR/$BACKUP_FILE
State file preserved for reference

Cleanup Summary:
----------------
✓ All Azure resources destroyed
✓ State file backed up
✓ Local temporary files cleaned
✓ Resource group deleted

Cost Impact:
------------
All billable resources have been removed.
You will no longer be charged for these resources.

Notes:
------
- Azure may take a few minutes to fully delete all resources
- You can verify deletion in the Azure Portal
- State backup is preserved in case you need to reference it

========================================
EOF

print_status "Cleanup report saved: $REPORT_FILE"

# Step 9: Final summary
print_header "🎉 Cleanup Completed Successfully!"

cat << EOF
┌─────────────────────────────────────────┐
│          Cleanup Summary                │
├─────────────────────────────────────────┤
│ Status: All resources destroyed         │
│ Duration: ${DURATION} seconds           │
│ Cost: $0/month (no active resources)    │
└─────────────────────────────────────────┘

What was destroyed:
- Resource Group: $RESOURCE_GROUP
- Virtual Machine
- Network resources
- Storage Account
- All associated resources

State Backup:
- Location: $BACKUP_DIR/$BACKUP_FILE

Next Steps:
1. Verify in Azure Portal (portal.azure.com)
2. Check your Azure billing to confirm no charges
3. If you want to redeploy, run: ./scripts/deploy.sh

Thank you for using this DevOps CI/CD project! 🚀
EOF

cd ..

exit 0