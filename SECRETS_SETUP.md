# GitHub Secrets and Variables Configuration

This document lists all required GitHub secrets and variables for the CI/CD pipeline.

## 🔐 GitHub Secrets

Navigate to: Repository → Settings → Secrets and variables → Actions → New repository secret

### Required Secrets

#### Azure Credentials

**AZURE_CREDENTIALS**
```json
{
  "clientId": "<service-principal-client-id>",
  "clientSecret": "<service-principal-client-secret>",
  "subscriptionId": "<azure-subscription-id>",
  "tenantId": "<azure-tenant-id>"
}
```
*How to create:*
```bash
az ad sp create-for-rbac --name "github-actions-sp" \
  --role contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth
```

#### Terraform Backend

**TF_BACKEND_RESOURCE_GROUP**
- Description: Resource group name for Terraform state storage
- Example: `rg-terraform-state`

**TF_BACKEND_STORAGE_ACCOUNT**
- Description: Storage account name for Terraform state
- Example: `sttfstate12345`

**TF_BACKEND_CONTAINER**
- Description: Blob container name for Terraform state
- Example: `tfstate`

**TF_BACKEND_KEY**
- Description: Blob name for Terraform state file
- Example: `chatapi/terraform.tfstate`

#### Terraform Service Principal

**ARM_CLIENT_ID**
- Description: Azure service principal client ID for Terraform
- Example: `12345678-1234-1234-1234-123456789012`

**ARM_CLIENT_SECRET**
- Description: Azure service principal client secret for Terraform
- Example: `your-client-secret`

**ARM_SUBSCRIPTION_ID**
- Description: Azure subscription ID
- Example: `12345678-1234-1234-1234-123456789012`

**ARM_TENANT_ID**
- Description: Azure tenant ID
- Example: `12345678-1234-1234-1234-123456789012`

#### Azure Function Deployment

**AZURE_FUNCTIONAPP_PUBLISH_PROFILE**
- Description: Publish profile for Azure Function App
- How to get: Azure Portal → Function App → Get publish profile

**AZURE_FUNCTION_KEY**
- Description: Function key for API authentication (for smoke tests)
- How to get: Azure Portal → Function App → Function Keys

#### Container Registry (Required if ENABLE_AKS_DEPLOYMENT=true)

**ACR_USERNAME**
- Description: Azure Container Registry admin username
- How to get: Azure Portal → Container Registry → Access keys

**ACR_PASSWORD**
- Description: Azure Container Registry admin password
- How to get: Azure Portal → Container Registry → Access keys

#### Application Configuration (Required if ENABLE_AKS_DEPLOYMENT=true)

**AZURE_STORAGE_CONNECTION_STRING**
- Description: Azure Storage connection string for Function App
- How to get: Azure Portal → Storage Account → Access keys

**APPLICATION_INSIGHTS_KEY**
- Description: Application Insights instrumentation key
- How to get: Azure Portal → Application Insights → Properties

---

## 📋 GitHub Variables

Navigate to: Repository → Settings → Secrets and variables → Actions → Variables → New repository variable

### Required Variables

#### Azure Resources

**AZURE_FUNCTIONAPP_NAME**
- Description: Name of the Azure Function App
- Example: `func-chatapi-prod`
- Must be globally unique

**AZURE_RESOURCE_GROUP**
- Description: Azure resource group name
- Example: `rg-chatapi-prod`

**STORAGE_ACCOUNT_NAME**
- Description: Storage account name for Function App
- Example: `stchatapiprod12345`
- Must be globally unique, lowercase, 3-24 chars

**APP_SERVICE_PLAN_NAME**
- Description: App Service Plan name
- Example: `asp-chatapi-prod`

**APPLICATION_INSIGHTS_NAME**
- Description: Application Insights resource name
- Example: `appi-chatapi-prod`

**KEY_VAULT_NAME**
- Description: Azure Key Vault name
- Example: `kv-chatapi-prod`
- Must be globally unique

#### Container and Kubernetes (Optional)

**ENABLE_AKS_DEPLOYMENT**
- Description: Enable AKS/Kubernetes deployment
- Values: `true` or `false`
- Default: `false`

**CONTAINER_REGISTRY**
- Description: Azure Container Registry login server
- Example: `acrchatapiprod.azurecr.io`
- Required if ENABLE_AKS_DEPLOYMENT=true

**AKS_CLUSTER_NAME**
- Description: Azure Kubernetes Service cluster name
- Example: `aks-chatapi-prod`
- Required if ENABLE_AKS_DEPLOYMENT=true

**INGRESS_ENABLED**
- Description: Enable Kubernetes ingress
- Values: `true` or `false`
- Default: `false`
- Required if ENABLE_AKS_DEPLOYMENT=true

**INGRESS_HOST**
- Description: Ingress hostname
- Example: `chatapi.example.com`
- Required if INGRESS_ENABLED=true

---

## 🚀 Quick Setup Commands

### 1. Create Azure Service Principal

```bash
# Create service principal for GitHub Actions
az ad sp create-for-rbac --name "github-actions-chatapi" \
  --role contributor \
  --scopes /subscriptions/<your-subscription-id> \
  --sdk-auth

# Save the output JSON as AZURE_CREDENTIALS secret
```

### 2. Create Terraform Backend Resources

```bash
# Variables
RESOURCE_GROUP="rg-terraform-state"
STORAGE_ACCOUNT="sttfstate$RANDOM"
CONTAINER="tfstate"
LOCATION="eastus"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --resource-group $RESOURCE_GROUP \
  --name $STORAGE_ACCOUNT \
  --sku Standard_LRS \
  --encryption-services blob

# Get storage account key
ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $RESOURCE_GROUP \
  --account-name $STORAGE_ACCOUNT \
  --query '[0].value' -o tsv)

# Create blob container
az storage container create \
  --name $CONTAINER \
  --account-name $STORAGE_ACCOUNT \
  --account-key $ACCOUNT_KEY

# Save these values as GitHub secrets:
# TF_BACKEND_RESOURCE_GROUP=$RESOURCE_GROUP
# TF_BACKEND_STORAGE_ACCOUNT=$STORAGE_ACCOUNT
# TF_BACKEND_CONTAINER=$CONTAINER
```

### 3. Get Function App Publish Profile

```bash
# After Terraform creates the Function App
az functionapp deployment list-publishing-profiles \
  --name <your-function-app-name> \
  --resource-group <your-resource-group> \
  --xml

# Save the entire XML output as AZURE_FUNCTIONAPP_PUBLISH_PROFILE
```

### 4. Get Container Registry Credentials

```bash
# Enable admin account
az acr update --name <your-acr-name> --admin-enabled true

# Get credentials
az acr credential show --name <your-acr-name>

# Save username as ACR_USERNAME
# Save password as ACR_PASSWORD
```

### 5. Get Storage Connection String

```bash
az storage account show-connection-string \
  --name <your-storage-account-name> \
  --resource-group <your-resource-group> \
  --output tsv

# Save output as AZURE_STORAGE_CONNECTION_STRING
```

### 6. Get Application Insights Key

```bash
az monitor app-insights component show \
  --app <your-appinsights-name> \
  --resource-group <your-resource-group> \
  --query instrumentationKey \
  --output tsv

# Save output as APPLICATION_INSIGHTS_KEY
```

---

## ✅ Verification Checklist

Before running the CI/CD pipeline, ensure:

### Core Deployment (Azure Functions)
- [ ] AZURE_CREDENTIALS is set
- [ ] ARM_CLIENT_ID is set
- [ ] ARM_CLIENT_SECRET is set
- [ ] ARM_SUBSCRIPTION_ID is set
- [ ] ARM_TENANT_ID is set
- [ ] TF_BACKEND_RESOURCE_GROUP is set
- [ ] TF_BACKEND_STORAGE_ACCOUNT is set
- [ ] TF_BACKEND_CONTAINER is set
- [ ] TF_BACKEND_KEY is set
- [ ] AZURE_FUNCTIONAPP_PUBLISH_PROFILE is set
- [ ] AZURE_FUNCTION_KEY is set (for smoke tests)
- [ ] AZURE_FUNCTIONAPP_NAME variable is set
- [ ] AZURE_RESOURCE_GROUP variable is set
- [ ] STORAGE_ACCOUNT_NAME variable is set
- [ ] APP_SERVICE_PLAN_NAME variable is set
- [ ] APPLICATION_INSIGHTS_NAME variable is set
- [ ] KEY_VAULT_NAME variable is set

### AKS Deployment (Optional)
- [ ] ENABLE_AKS_DEPLOYMENT is set to `true`
- [ ] ACR_USERNAME is set
- [ ] ACR_PASSWORD is set
- [ ] AZURE_STORAGE_CONNECTION_STRING is set
- [ ] APPLICATION_INSIGHTS_KEY is set
- [ ] CONTAINER_REGISTRY variable is set
- [ ] AKS_CLUSTER_NAME variable is set
- [ ] INGRESS_ENABLED variable is set
- [ ] INGRESS_HOST variable is set (if ingress enabled)

---

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Rotate secrets regularly** (every 90 days recommended)
3. **Use least privilege** for service principals
4. **Enable MFA** for Azure accounts with portal access
5. **Audit access logs** regularly
6. **Use separate credentials** for production and non-production
7. **Store production secrets** in Azure Key Vault
8. **Limit secret access** to necessary team members only

---

## 📚 Additional Resources

- [Azure Service Principal Documentation](https://docs.microsoft.com/azure/active-directory/develop/howto-create-service-principal-portal)
- [GitHub Actions Secrets](https://docs.github.com/actions/security-guides/encrypted-secrets)
- [Azure Function App Settings](https://docs.microsoft.com/azure/azure-functions/functions-app-settings)
- [Terraform Azure Backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html)
