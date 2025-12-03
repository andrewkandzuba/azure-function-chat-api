# Quick Start Guide

Get your Azure Function Chat API up and running in minutes!

## 🎯 Prerequisites

Ensure you have the following installed:
- [Python 3.11+](https://www.python.org/downloads/)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli)
- [Azure Functions Core Tools](https://docs.microsoft.com/azure/azure-functions/functions-run-local)
- [Git](https://git-scm.com/downloads)

Optional (for advanced deployment):
- [Docker](https://docs.docker.com/get-docker/)
- [Terraform](https://www.terraform.io/downloads)
- [Helm](https://helm.sh/docs/intro/install/)
- [kubectl](https://kubernetes.io/docs/tasks/tools/)

## 🚀 Option 1: Local Development (5 minutes)

### Step 1: Clone and Setup

```bash
# Clone the repository
git clone <repository-url>
cd azure-function-chat-api

# Run setup script (Linux/Mac)
chmod +x setup.sh
./setup.sh

# OR use Make
make setup

# OR manual setup
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements-dev.txt
```

### Step 2: Start Function Locally

```bash
# Activate virtual environment (if not already active)
source .venv/bin/activate

# Start the function
func start

# OR use Make
make func-start
```

You should see output like:
```
Functions:
        chat_api: [POST] http://localhost:7071/api/chat
        health_check: [GET] http://localhost:7071/api/health
```

### Step 3: Test the API

Open a new terminal and run:

```bash
# Test health check
curl http://localhost:7071/api/health

# Test chat API
curl -X POST http://localhost:7071/api/chat \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello, Azure!","user_id":"quickstart-user"}'
```

Expected response:
```json
{
  "status": "success",
  "user_id": "quickstart-user",
  "message_received": "Hello, Azure!",
  "response": "Echo: Hello, Azure!",
  "timestamp": "2024-01-01T12:00:00.000000"
}
```

### Step 4: Run Tests

```bash
# Run all tests
pytest tests/ -v

# OR use Make
make test

# Run with coverage
make coverage
```

🎉 **Congratulations!** Your function is running locally.

---

## 🌐 Option 2: Deploy to Azure (15 minutes)

### Step 1: Azure Login

```bash
az login
az account set --subscription <your-subscription-id>
```

### Step 2: Create Azure Resources Manually (Quick Deploy)

```bash
# Set variables
RESOURCE_GROUP="rg-chatapi-quickstart"
LOCATION="eastus"
STORAGE_ACCOUNT="stchatapi$RANDOM"
FUNCTION_APP="func-chatapi-$RANDOM"
APP_INSIGHTS="appi-chatapi-quickstart"

# Create resource group
az group create --name $RESOURCE_GROUP --location $LOCATION

# Create storage account
az storage account create \
  --name $STORAGE_ACCOUNT \
  --resource-group $RESOURCE_GROUP \
  --location $LOCATION \
  --sku Standard_LRS

# Create Application Insights
az monitor app-insights component create \
  --app $APP_INSIGHTS \
  --location $LOCATION \
  --resource-group $RESOURCE_GROUP \
  --application-type web

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app $APP_INSIGHTS \
  --resource-group $RESOURCE_GROUP \
  --query instrumentationKey -o tsv)

# Create Function App
az functionapp create \
  --resource-group $RESOURCE_GROUP \
  --consumption-plan-location $LOCATION \
  --runtime python \
  --runtime-version 3.11 \
  --functions-version 4 \
  --name $FUNCTION_APP \
  --storage-account $STORAGE_ACCOUNT \
  --app-insights $APP_INSIGHTS \
  --app-insights-key $INSTRUMENTATION_KEY \
  --os-type Linux

echo "Function App created: https://$FUNCTION_APP.azurewebsites.net"
```

### Step 3: Deploy Function

```bash
# From project root
func azure functionapp publish $FUNCTION_APP
```

### Step 4: Test Deployed Function

```bash
# Get function URL
FUNCTION_URL=$(az functionapp function show \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_APP \
  --function-name chat_api \
  --query invokeUrlTemplate -o tsv)

# Test health endpoint
curl https://$FUNCTION_APP.azurewebsites.net/api/health

# Test chat endpoint (you'll need the function key)
FUNCTION_KEY=$(az functionapp keys list \
  --resource-group $RESOURCE_GROUP \
  --name $FUNCTION_APP \
  --query functionKeys.default -o tsv)

curl -X POST "https://$FUNCTION_APP.azurewebsites.net/api/chat?code=$FUNCTION_KEY" \
  -H "Content-Type: application/json" \
  -d '{"message":"Hello from Azure!","user_id":"azure-user"}'
```

🎉 **Success!** Your function is now running in Azure.

---

## 🏗️ Option 3: Full CI/CD with Terraform (30 minutes)

### Step 1: Prepare Terraform Backend

```bash
# Create backend storage
cd terraform

# Set variables
BACKEND_RG="rg-terraform-state"
BACKEND_STORAGE="sttfstate$RANDOM"
BACKEND_CONTAINER="tfstate"

# Create resources
az group create --name $BACKEND_RG --location eastus
az storage account create \
  --resource-group $BACKEND_RG \
  --name $BACKEND_STORAGE \
  --sku Standard_LRS

ACCOUNT_KEY=$(az storage account keys list \
  --resource-group $BACKEND_RG \
  --account-name $BACKEND_STORAGE \
  --query '[0].value' -o tsv)

az storage container create \
  --name $BACKEND_CONTAINER \
  --account-name $BACKEND_STORAGE \
  --account-key $ACCOUNT_KEY
```

### Step 2: Configure Terraform

```bash
# Copy example vars
cp terraform.tfvars.example terraform.tfvars

# Edit with your values
nano terraform.tfvars  # or your preferred editor
```

Update these values:
```hcl
resource_group_name      = "rg-chatapi-prod"
location                 = "eastus"
storage_account_name     = "stchatapi12345"  # Must be unique
function_app_name        = "func-chatapi-12345"  # Must be unique
key_vault_name           = "kv-chatapi-12345"  # Must be unique
```

### Step 3: Initialize and Apply Terraform

```bash
# Initialize
terraform init \
  -backend-config="resource_group_name=$BACKEND_RG" \
  -backend-config="storage_account_name=$BACKEND_STORAGE" \
  -backend-config="container_name=$BACKEND_CONTAINER" \
  -backend-config="key=chatapi.tfstate"

# Plan
terraform plan

# Apply
terraform apply
```

### Step 4: Setup GitHub Actions

1. **Create Service Principal:**
```bash
az ad sp create-for-rbac --name "github-actions-chatapi" \
  --role contributor \
  --scopes /subscriptions/<subscription-id> \
  --sdk-auth > github-credentials.json
```

2. **Add GitHub Secrets:**
   - Go to your repository → Settings → Secrets → Actions
   - Add all secrets from `SECRETS_SETUP.md`
   - Minimum required: See the verification checklist

3. **Add GitHub Variables:**
   - Go to your repository → Settings → Secrets → Variables
   - Add resource names (function app, resource group, etc.)

### Step 5: Deploy via GitHub Actions

```bash
# Commit and push
git add .
git commit -m "feat: initial deployment configuration"
git push origin main
```

Watch the deployment in the Actions tab!

---

## 📊 Common Commands Reference

### Development
```bash
make setup          # Setup environment
make test           # Run tests
make coverage       # Test coverage
make lint           # Lint code
make format         # Format code
make func-start     # Start locally
```

### Docker
```bash
make docker-build   # Build image
make docker-run     # Run container
```

### Terraform
```bash
make tf-init        # Initialize
make tf-plan        # Plan changes
make tf-apply       # Apply changes
```

### Azure CLI
```bash
# View logs
az functionapp log tail --name <function-app-name> --resource-group <resource-group>

# View settings
az functionapp config appsettings list --name <function-app-name> --resource-group <resource-group>

# Restart function
az functionapp restart --name <function-app-name> --resource-group <resource-group>
```

---

## 🐛 Troubleshooting

### Function won't start locally
```bash
# Check Python version
python --version  # Should be 3.11+

# Reinstall dependencies
pip install --force-reinstall -r requirements.txt

# Check Azure Functions Core Tools
func --version  # Should be 4.x
```

### Tests failing
```bash
# Install test dependencies
pip install -r requirements-dev.txt

# Clear cache
rm -rf .pytest_cache __pycache__

# Run specific test
pytest tests/test_chat_api.py::TestChatAPI::test_chat_api_success -v
```

### Azure deployment issues
```bash
# Check function app status
az functionapp show --name <function-app> --resource-group <resource-group>

# View logs
az functionapp log tail --name <function-app> --resource-group <resource-group>

# Sync triggers
az functionapp deployment list-publishing-credentials --name <function-app> --resource-group <resource-group>
```

### Terraform errors
```bash
# Re-initialize
terraform init -upgrade

# Validate configuration
terraform validate

# View state
terraform show
```

---

## 📚 Next Steps

1. **Customize the function**: Edit `function_app.py` to add your business logic
2. **Add more endpoints**: Create new functions following the same pattern
3. **Configure monitoring**: Check Application Insights for logs and metrics
4. **Setup alerts**: Configure Azure Monitor alerts for failures
5. **Add authentication**: Implement Azure AD or API key validation
6. **Scale**: Adjust App Service Plan or enable AKS deployment

---

## 🔗 Helpful Links

- [Full Documentation](README.md)
- [Project Structure](PROJECT_STRUCTURE.md)
- [Secrets Setup](SECRETS_SETUP.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Azure Functions Python Guide](https://docs.microsoft.com/azure/azure-functions/functions-reference-python)

---

## 💬 Need Help?

- Open an issue in the repository
- Check Application Insights logs
- Review Azure Function logs in the portal
- Consult the troubleshooting section in README.md

Happy coding! 🚀
