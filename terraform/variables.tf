variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region for resources"
  type        = string
  default     = "eastus"
}

variable "storage_account_name" {
  description = "Name of the storage account (must be globally unique)"
  type        = string
}

variable "app_service_plan_name" {
  description = "Name of the App Service Plan"
  type        = string
}

variable "app_service_plan_sku" {
  description = "SKU for the App Service Plan"
  type        = string
  default     = "B1"
}

variable "function_app_name" {
  description = "Name of the Function App (must be globally unique)"
  type        = string
}

variable "application_insights_name" {
  description = "Name of Application Insights"
  type        = string
}

variable "key_vault_name" {
  description = "Name of the Key Vault (must be globally unique)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "cors_allowed_origins" {
  description = "List of allowed CORS origins"
  type        = list(string)
  default     = ["*"]
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "development"
    ManagedBy   = "Terraform"
    Project     = "ChatAPI"
  }
}

# AKS/Container variables (optional)
variable "enable_aks_deployment" {
  description = "Enable AKS cluster creation for Helm deployment"
  type        = bool
  default     = false
}

variable "container_registry_name" {
  description = "Name of the Azure Container Registry"
  type        = string
  default     = "chatapiacr"
}

variable "aks_cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
  default     = "chatapi-aks"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = "chatapi"
}

variable "aks_node_count" {
  description = "Number of nodes in the AKS cluster"
  type        = number
  default     = 2
}

variable "aks_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_D2_v2"
}
