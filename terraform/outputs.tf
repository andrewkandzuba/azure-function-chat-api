output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "function_app_name" {
  description = "Name of the Function App"
  value       = azurerm_linux_function_app.main.name
}

output "function_app_url" {
  description = "Default hostname of the Function App"
  value       = "https://${azurerm_linux_function_app.main.default_hostname}"
}

output "function_app_principal_id" {
  description = "Principal ID of the Function App's managed identity"
  value       = azurerm_linux_function_app.main.identity[0].principal_id
}

output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.function.name
}

output "application_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  value       = azurerm_application_insights.function.instrumentation_key
  sensitive   = true
}

output "application_insights_connection_string" {
  description = "Application Insights connection string"
  value       = azurerm_application_insights.function.connection_string
  sensitive   = true
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

# Container Registry outputs (if AKS is enabled)
output "container_registry_login_server" {
  description = "Login server URL for the Container Registry"
  value       = var.enable_aks_deployment ? azurerm_container_registry.main[0].login_server : null
}

output "container_registry_admin_username" {
  description = "Admin username for the Container Registry"
  value       = var.enable_aks_deployment ? azurerm_container_registry.main[0].admin_username : null
  sensitive   = true
}

output "container_registry_admin_password" {
  description = "Admin password for the Container Registry"
  value       = var.enable_aks_deployment ? azurerm_container_registry.main[0].admin_password : null
  sensitive   = true
}

# AKS outputs (if enabled)
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = var.enable_aks_deployment ? azurerm_kubernetes_cluster.main[0].name : null
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = var.enable_aks_deployment ? azurerm_kubernetes_cluster.main[0].id : null
}

output "aks_kube_config" {
  description = "Kubeconfig for the AKS cluster"
  value       = var.enable_aks_deployment ? azurerm_kubernetes_cluster.main[0].kube_config_raw : null
  sensitive   = true
}
