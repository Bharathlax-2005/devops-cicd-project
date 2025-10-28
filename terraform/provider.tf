# Azure Provider Configuration
# This file configures the Azure provider and sets up the backend

terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  # Optional: Remote backend for team collaboration
  # Uncomment and configure for production use
  # backend "azurerm" {
  #   resource_group_name  = "terraform-state-rg"
  #   storage_account_name = "tfstatedevops"
  #   container_name       = "tfstate"
  #   key                  = "devops-cicd.tfstate"
  # }
}

# Configure Azure Provider
provider "azurerm" {
  features {
    # Ensure resources are properly cleaned up
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    
    virtual_machine {
      delete_os_disk_on_deletion     = true
      graceful_shutdown              = false
      skip_shutdown_and_force_delete = false
    }
  }

  # Authentication via Service Principal
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

# Generate random ID for unique resource names
resource "random_id" "random" {
  byte_length = 4
}