##############################################
# VARIABLES DEFINITION
# Compatible with main.tf (fixed region + validation)
##############################################

# ===== Azure Authentication =====
variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  sensitive   = true
}

variable "client_id" {
  description = "Azure Service Principal Client ID"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Azure Service Principal Client Secret"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Azure Tenant ID"
  type        = string
  sensitive   = true
}

# ===== Resource Configuration =====
variable "resource_group_name" {
  description = "Name of the Azure Resource Group"
  type        = string
  default     = "devops-cicd-rg"
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "centralindia"   # ✅ changed to an allowed region

  validation {
    condition     = contains(["eastus", "westus", "centralus", "westeurope", "northeurope", "centralindia", "southindia"], lower(var.location))
    error_message = "Location must be one of: eastus, westus, centralus, westeurope, northeurope, centralindia, southindia"
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], lower(var.environment))
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "devopscicd"   # ✅ lowercase, no hyphens (for storage account)
}

# ===== Network Configuration =====
variable "vnet_address_space" {
  description = "Address space for Virtual Network"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefix" {
  description = "Address prefix for subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "allowed_ssh_ips" {
  description = "List of IPs allowed to SSH (CIDR notation)"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # WARNING: Change this in production!
}

variable "allowed_http_ips" {
  description = "List of IPs allowed for HTTP access (CIDR notation)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

# ===== VM Configuration =====
variable "vm_size" {
  description = "Size of the Virtual Machine"
  type        = string
  default     = "Standard_B1s"  # ✅ smaller for testing; upgrade for prod
}

variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
  default     = "azureuser"

  validation {
    condition     = length(var.admin_username) >= 3 && length(var.admin_username) <= 20
    error_message = "Admin username must be between 3 and 20 characters"
  }
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.admin_password) >= 12
    error_message = "Password must be at least 12 characters long"
  }
}

variable "os_disk_size_gb" {
  description = "Size of the OS disk in GB"
  type        = number
  default     = 30

  validation {
    condition     = var.os_disk_size_gb >= 30 && var.os_disk_size_gb <= 1024
    error_message = "OS disk size must be between 30 and 1024 GB"
  }
}

# ===== Application Configuration =====
variable "app_port" {
  description = "Port for the web application"
  type        = number
  default     = 8080   # ✅ match your VM app port
}

variable "app_name" {
  description = "Application name"
  type        = string
  default     = "devops-web-app"
}

# ===== Tags =====
variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Project     = "DevOps-CICD"
    ManagedBy   = "Terraform"
    Environment = "Development"
    Owner       = "DevOps-Team"
  }
}

# ===== Feature Flags =====
variable "enable_monitoring" {
  description = "Enable Azure Monitor for resources"
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Enable VM backup"
  type        = bool
  default     = false
}

variable "deploy_app_service" {
  description = "Deploy as App Service instead of VM"
  type        = bool
  default     = false
}
