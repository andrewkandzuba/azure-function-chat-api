# Azure Function Chat API

A production-ready Azure Function App providing a REST API Chat endpoint with complete CI/CD pipeline, Infrastructure as Code (Terraform), and Kubernetes deployment (Helm charts).

## 📋 Features

- **Azure Functions REST API** - Chat endpoint with request logging
- **Health Check Endpoint** - For monitoring and load balancers
- **Comprehensive Testing** - Unit tests with pytest and coverage reports
- **CI/CD Pipeline** - GitHub Actions workflow with automated testing and deployment
- **Infrastructure as Code** - Terraform for Azure resource provisioning
- **Container Support** - Dockerized application for flexibility
- **Kubernetes Deployment** - Helm charts for AKS deployment
- **Secrets Management** - Azure Key Vault integration
- **Monitoring** - Application Insights integration
- **Auto-scaling** - Horizontal Pod Autoscaling for Kubernetes deployments

## 🏗️ Architecture

### Components

1. **Azure Function App** - Serverless Python 3.11 application
2. **Azure Storage Account** - Required for Azure Functions runtime
3. **App Service Plan** - Hosting plan for the Function App
4. **Application Insights** - Monitoring and logging
5. **Azure Key Vault** - Secrets and certificate management
6. **Azure Container Registry** - Docker image storage (optional)
7. **Azure Kubernetes Service** - Container orchestration (optional)

### API Endpoints

#### POST /api/chat
Chat endpoint that accepts JSON payloads and logs requests.

**Request:**
```json
{
  "message": "Hello, Azure!",
  "user_id": "user123"
}
```

**Response:**
```json
{
  "status": "success",
  "user_id": "user123",
  "message_received": "Hello, Azure!",
  "response": "Echo: Hello, Azure!",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

#### GET /api/health
Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "healthy",
  "timestamp": "2024-01-01T12:00:00Z"
}
```

## 🚀 Quick Start

### Prerequisites

- Python 3.11+
- Azure CLI
- Azure Functions Core Tools
- Docker (for containerized deployment)
- Terraform 1.0+
- Helm 3.0+ (for Kubernetes deployment)
- kubectl (for Kubernetes deployment)

### Local Development

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd azure-function-chat-api
   ```

2. **Create virtual environment:**
   ```bash
   python -m venv .venv
   source .venv/bin/activate  # On Windows: .venv\Scripts\activate
   ```

3. **Install dependencies:**
   ```bash
   pip install -r requirements-dev.txt
   ```

4. **Run locally:**
   ```bash
   func start
   ```

5. **Test the API:**
   ```bash
   # Health check
   curl http://localhost:7071/api/health

   # Chat API
   curl -X POST http://localhost:7071/api/chat \
     -H "Content-Type: application/json" \
     -d '{"message":"Hello","user_id":"test"}'
   ```

### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=function_app --cov-report=html

# Run specific test file
pytest tests/test_chat_api.py -v
```

## 📦 Deployment

### Option 1: Direct Azure Functions Deployment

1. **Configure Azure credentials:**
   Set up the following GitHub secrets:
   - `AZURE_CREDENTIALS` - Azure service principal credentials
   - `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` - Function App publish profile

2. **Configure GitHub variables:**
   - `AZURE_FUNCTIONAPP_NAME` - Your Function App name
   - `AZURE_RESOURCE_GROUP` - Resource group name

3. **Push to main branch:**
   ```bash
   git push origin main
   ```

### Option 2: Kubernetes (AKS) Deployment

1. **Configure additional secrets:**
   - `ACR_USERNAME` - Azure Container Registry username
   - `ACR_PASSWORD` - Azure Container Registry password
   - `AZURE_STORAGE_CONNECTION_STRING` - Storage connection string
   - `APPLICATION_INSIGHTS_KEY` - App Insights instrumentation key

2. **Configure additional variables:**
   - `ENABLE_AKS_DEPLOYMENT=true`
   - `CONTAINER_REGISTRY` - ACR login server
   - `AKS_CLUSTER_NAME` - AKS cluster name
   - `INGRESS_ENABLED` - Enable ingress (true/false)
   - `INGRESS_HOST` - Ingress hostname

3. **Deploy:**
   ```bash
   git push origin main
   ```

## 🔧 Terraform Infrastructure

### Initialize Terraform

```bash
cd terraform
terraform init
```

### Configure Variables

Copy the example variables file and customize:
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
```

### Deploy Infrastructure

```bash
terraform plan
terraform apply
```

### Infrastructure Components

The Terraform configuration creates:
- Resource Group
- Storage Account
- App Service Plan
- Function App with managed identity
- Application Insights
- Key Vault with access policies
- Container Registry (optional)
- AKS Cluster (optional)

## 🎛️ Configuration

### GitHub Secrets

| Secret | Description | Required |
|--------|-------------|----------|
| `AZURE_CREDENTIALS` | Azure service principal JSON | Yes |
| `AZURE_FUNCTIONAPP_PUBLISH_PROFILE` | Function App publish profile | Yes (Function deployment) |
| `ARM_CLIENT_ID` | Azure client ID for Terraform | Yes (Terraform) |
| `ARM_CLIENT_SECRET` | Azure client secret | Yes (Terraform) |
| `ARM_SUBSCRIPTION_ID` | Azure subscription ID | Yes (Terraform) |
| `ARM_TENANT_ID` | Azure tenant ID | Yes (Terraform) |
| `TF_BACKEND_RESOURCE_GROUP` | Terraform backend resource group | Yes (Terraform) |
| `TF_BACKEND_STORAGE_ACCOUNT` | Terraform backend storage account | Yes (Terraform) |
| `TF_BACKEND_CONTAINER` | Terraform backend container | Yes (Terraform) |
| `TF_BACKEND_KEY` | Terraform state file key | Yes (Terraform) |
| `ACR_USERNAME` | ACR username | Yes (AKS deployment) |
| `ACR_PASSWORD` | ACR password | Yes (AKS deployment) |
| `AZURE_STORAGE_CONNECTION_STRING` | Storage connection string | Yes (AKS deployment) |
| `APPLICATION_INSIGHTS_KEY` | App Insights key | Yes (AKS deployment) |
| `AZURE_FUNCTION_KEY` | Function key for smoke tests | Yes (smoke tests) |

### GitHub Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `AZURE_FUNCTIONAPP_NAME` | Function App name | - |
| `AZURE_RESOURCE_GROUP` | Resource group name | - |
| `STORAGE_ACCOUNT_NAME` | Storage account name | - |
| `APP_SERVICE_PLAN_NAME` | App Service Plan name | - |
| `APPLICATION_INSIGHTS_NAME` | App Insights name | - |
| `KEY_VAULT_NAME` | Key Vault name | - |
| `ENABLE_AKS_DEPLOYMENT` | Enable AKS deployment | `false` |
| `CONTAINER_REGISTRY` | ACR login server | - |
| `AKS_CLUSTER_NAME` | AKS cluster name | - |
| `INGRESS_ENABLED` | Enable Kubernetes ingress | `false` |
| `INGRESS_HOST` | Ingress hostname | - |

## 🐳 Docker Support

### Build Docker Image

```bash
docker build -t azure-function-chat-api:latest .
```

### Run Container Locally

```bash
docker run -p 8080:80 \
  -e AzureWebJobsStorage="UseDevelopmentStorage=true" \
  -e FUNCTIONS_WORKER_RUNTIME="python" \
  azure-function-chat-api:latest
```

### Push to Azure Container Registry

```bash
az acr login --name <your-acr-name>
docker tag azure-function-chat-api:latest <your-acr>.azurecr.io/azure-function-chat-api:latest
docker push <your-acr>.azurecr.io/azure-function-chat-api:latest
```

## ☸️ Helm Deployment

### Install/Upgrade Release

```bash
helm upgrade --install azure-function-chat-api ./helm/azure-function \
  --set image.repository=<your-acr>.azurecr.io/azure-function-chat-api \
  --set image.tag=latest \
  --namespace default
```

### Customize Values

Edit `helm/azure-function/values.yaml` or override values:

```bash
helm upgrade --install azure-function-chat-api ./helm/azure-function \
  --set replicaCount=3 \
  --set resources.requests.memory=512Mi \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=chatapi.example.com
```

### Verify Deployment

```bash
kubectl get pods
kubectl get svc
kubectl logs -l app.kubernetes.io/name=azure-function-chat-api
```

## 📊 Monitoring

### Application Insights

All logs are automatically sent to Application Insights. View them in the Azure Portal:

1. Navigate to your Application Insights resource
2. Go to "Logs" or "Live Metrics"
3. Query logs using KQL

### Kubernetes Monitoring

```bash
# View pod logs
kubectl logs -f <pod-name>

# View pod status
kubectl describe pod <pod-name>

# View service endpoints
kubectl get endpoints
```

## 🔒 Security Best Practices

1. **Never commit secrets** to the repository
2. **Use Azure Key Vault** for sensitive configuration
3. **Enable managed identities** for Azure resources
4. **Implement RBAC** for AKS clusters
5. **Use network policies** in Kubernetes
6. **Enable HTTPS only** for production endpoints
7. **Implement rate limiting** for API endpoints
8. **Regularly update dependencies** and scan for vulnerabilities

## 🧪 Testing Strategy

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test API endpoints and Azure services
- **Load Tests**: Verify performance under load
- **Smoke Tests**: Post-deployment validation in CI/CD

## 📝 Development Workflow

1. Create feature branch from `develop`
2. Make changes and write tests
3. Run tests locally
4. Create pull request
5. CI pipeline runs tests automatically
6. Merge to `develop` for staging deployment
7. Merge to `main` for production deployment

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License.

## 🆘 Troubleshooting

### Function App not responding
- Check Application Insights logs
- Verify storage account connection
- Check Function App configuration

### Kubernetes pod not starting
- Check pod logs: `kubectl logs <pod-name>`
- Verify image pull secrets
- Check resource limits

### Terraform apply fails
- Verify Azure credentials
- Check resource name uniqueness
- Review Terraform state

## 📞 Support

For issues and questions:
- Create an issue in the GitHub repository
- Check Application Insights for logs and errors
- Review Azure Monitor for infrastructure issues

## 🔄 Version History

- **1.0.0** - Initial release with Azure Functions, Terraform, and Helm support
