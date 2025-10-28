# Output Values
# Display important information after deployment

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "location" {
  description = "Azure region where resources are deployed"
  value       = azurerm_resource_group.main.location
}

output "public_ip_address" {
  description = "Public IP address of the VM"
  value       = data.azurerm_public_ip.main.ip_address
}

output "vm_name" {
  description = "Name of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.name
}

output "vm_id" {
  description = "ID of the virtual machine"
  value       = azurerm_linux_virtual_machine.main.id
}

output "admin_username" {
  description = "Admin username for SSH access"
  value       = var.admin_username
}

output "ssh_command" {
  description = "SSH command to connect to the VM"
  value       = "ssh ${var.admin_username}@${data.azurerm_public_ip.main.ip_address}"
}

output "application_url" {
  description = "URL to access the web application"
  value       = "http://${data.azurerm_public_ip.main.ip_address}"
}

output "app_service_url" {
  description = "App Service URL (if deployed)"
  value       = var.deploy_app_service ? azurerm_linux_web_app.main[0].default_hostname : "Not deployed"
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_website_endpoint" {
  description = "Static website endpoint"
  value       = azurerm_storage_account.main.primary_web_endpoint
}

output "virtual_network_name" {
  description = "Name of the virtual network"
  value       = azurerm_virtual_network.main.name
}

output "subnet_id" {
  description = "ID of the subnet"
  value       = azurerm_subnet.main.id
}

output "network_security_group_name" {
  description = "Name of the network security group"
  value       = azurerm_network_security_group.main.name
}

# Formatted summary output
output "deployment_summary" {
  description = "Summary of deployed resources"
  value = <<-EOT
    ========================================
    🚀 DEPLOYMENT SUCCESSFUL
    ========================================
    
    Resource Group: ${azurerm_resource_group.main.name}
    Location:       ${azurerm_resource_group.main.location}
    Environment:    ${var.environment}
    
    📍 Virtual Machine:
       Name:        ${azurerm_linux_virtual_machine.main.name}
       Size:        ${var.vm_size}
       Public IP:   ${data.azurerm_public_ip.main.ip_address}
    
    🌐 Access Information:
       Web App:     http://${data.azurerm_public_ip.main.ip_address}
       SSH Access:  ssh ${var.admin_username}@${data.azurerm_public_ip.main.ip_address}
    
    📦 Storage:
       Account:     ${azurerm_storage_account.main.name}
       Website:     ${azurerm_storage_account.main.primary_web_endpoint}
    
    ========================================
    Next Steps:
    1. Wait 2-3 minutes for VM initialization
    2. Open: http://${data.azurerm_public_ip.main.ip_address}
    3. View logs: ssh then check /var/log/cloud-init.log
    ========================================
  EOT
}

# JSON output for programmatic access
output "deployment_info_json" {
  description = "Deployment information in JSON format"
  value = jsonencode({
    resource_group = azurerm_resource_group.main.name
    location       = azurerm_resource_group.main.location
    vm = {
      name       = azurerm_linux_virtual_machine.main.name
      public_ip  = data.azurerm_public_ip.main.ip_address
      size       = var.vm_size
    }
    urls = {
      web_app     = "http://${data.azurerm_public_ip.main.ip_address}"
      storage_web = azurerm_storage_account.main.primary_web_endpoint
    }
    access = {
      ssh_user    = var.admin_username
      ssh_command = "ssh ${var.admin_username}@${data.azurerm_public_ip.main.ip_address}"
    }
  })
}