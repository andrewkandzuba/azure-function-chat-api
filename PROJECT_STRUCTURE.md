# Project Structure

```
azure-function-chat-api/
│
├── .github/
│   └── workflows/
│       └── deploy.yml              # GitHub Actions CI/CD workflow
│
├── .vscode/
│   ├── extensions.json             # Recommended VS Code extensions
│   ├── launch.json                 # Debug configurations
│   ├── settings.json               # VS Code settings
│   └── tasks.json                  # VS Code tasks
│
├── helm/
│   └── azure-function/
│       ├── Chart.yaml              # Helm chart metadata
│       ├── values.yaml             # Default configuration values
│       └── templates/
│           ├── _helpers.tpl        # Template helper functions
│           ├── deployment.yaml     # Kubernetes deployment
│           ├── hpa.yaml            # Horizontal Pod Autoscaler
│           ├── ingress.yaml        # Ingress configuration
│           ├── service.yaml        # Kubernetes service
│           └── serviceaccount.yaml # Service account
│
├── terraform/
│   ├── main.tf                     # Main Terraform configuration
│   ├── variables.tf                # Variable definitions
│   ├── outputs.tf                  # Output definitions
│   └── terraform.tfvars.example    # Example variable values
│
├── tests/
│   ├── __init__.py                 # Tests package init
│   ├── conftest.py                 # Pytest configuration
│   └── test_chat_api.py            # Chat API test cases
│
├── .dockerignore                   # Docker ignore patterns
├── .gitignore                      # Git ignore patterns
├── CONTRIBUTING.md                 # Contributing guidelines
├── Dockerfile                      # Container image definition
├── Makefile                        # Common task automation
├── README.md                       # Project documentation
├── function_app.py                 # Main Azure Function application
├── host.json                       # Azure Functions host configuration
├── local.settings.json             # Local development settings
├── pytest.ini                      # Pytest configuration
├── requirements-dev.txt            # Development dependencies
├── requirements.txt                # Production dependencies
└── setup.sh                        # Environment setup script
```

## Directory Descriptions

### `.github/workflows/`
Contains GitHub Actions workflows for CI/CD automation:
- **deploy.yml**: Main deployment workflow with testing, Terraform, and deployment jobs

### `.vscode/`
Visual Studio Code configuration for optimal development experience:
- **extensions.json**: Recommended extensions for Python, Azure, Terraform, and Kubernetes
- **launch.json**: Debug configurations for Azure Functions and tests
- **settings.json**: Python, linting, formatting, and Azure Functions settings
- **tasks.json**: Automated tasks for testing, linting, and deployment

### `helm/azure-function/`
Kubernetes deployment using Helm charts:
- **Chart.yaml**: Chart metadata and versioning
- **values.yaml**: Default configuration values (can be overridden)
- **templates/**: Kubernetes resource templates
  - Deployment: Pod management and container configuration
  - Service: Network access to pods
  - Ingress: External HTTP/HTTPS access
  - HPA: Auto-scaling based on CPU/memory
  - ServiceAccount: RBAC configuration

### `terraform/`
Infrastructure as Code using Terraform:
- **main.tf**: Resource definitions (Resource Group, Storage, Function App, AKS, etc.)
- **variables.tf**: Input variable declarations
- **outputs.tf**: Output values for use in other processes
- **terraform.tfvars.example**: Example configuration (copy to terraform.tfvars)

### `tests/`
Unit and integration tests:
- **conftest.py**: Shared test fixtures and configuration
- **test_chat_api.py**: Test cases for chat and health endpoints

## Key Files

### `function_app.py`
Main application file containing:
- Azure Functions app initialization
- Chat API endpoint (`/api/chat`)
- Health check endpoint (`/api/health`)
- Request logging and error handling

### `host.json`
Azure Functions runtime configuration:
- Logging settings
- Extension bundle version
- HTTP route prefix
- Timeout configuration

### `local.settings.json`
Local development settings:
- Azure Web Jobs Storage configuration
- Runtime version
- CORS settings
- Environment variables

### `Dockerfile`
Multi-stage container build:
- Based on Microsoft Azure Functions Python image
- Installs dependencies
- Configures runtime environment

### `Makefile`
Command shortcuts for:
- Environment setup
- Running tests
- Code formatting and linting
- Docker operations
- Terraform operations
- Helm deployments

### `setup.sh`
Automated environment setup:
- Creates virtual environment
- Installs dependencies
- Checks for required tools
- Runs initial tests

## Configuration Files

### `requirements.txt`
Production Python dependencies:
- azure-functions

### `requirements-dev.txt`
Development and testing dependencies:
- pytest, pytest-cov
- flake8, mypy, black
- requests

### `pytest.ini`
Test runner configuration:
- Test discovery patterns
- Coverage settings
- Output formatting

### `.gitignore`
Version control exclusions:
- Python cache files
- Virtual environments
- Terraform state
- Secrets and credentials
- Build artifacts

### `.dockerignore`
Docker build exclusions:
- Source control files
- Tests
- Documentation
- Development files

## Resource Flow

### Local Development
```
Developer → function_app.py → Azure Functions Core Tools → Local endpoint
```

### CI/CD Pipeline
```
Git Push → GitHub Actions → Tests → Terraform → Deploy
                                   ↓
                                Docker Build → ACR → AKS (Helm)
```

### Production Architecture
```
Internet → Ingress → Service → Pods (Function App)
                                    ↓
                              Storage Account
                                    ↓
                              Application Insights
```

## Development Workflow

1. **Setup**: Run `./setup.sh` or `make setup`
2. **Develop**: Edit `function_app.py` and tests
3. **Test**: Run `make test` or `pytest`
4. **Format**: Run `make format`
5. **Lint**: Run `make lint`
6. **Local Run**: Run `make func-start` or `func start`
7. **Commit**: Git commit with conventional message
8. **Push**: Git push triggers CI/CD pipeline

## Deployment Options

### Option 1: Azure Functions (Serverless)
- Managed by Azure
- Auto-scaling included
- Pay per execution
- Deployed via GitHub Actions

### Option 2: Kubernetes (AKS)
- Full control over infrastructure
- Custom scaling policies
- Deployed via Helm charts
- More complex but flexible

## Monitoring and Logging

- **Application Insights**: All logs and telemetry
- **Azure Monitor**: Infrastructure metrics
- **Kubernetes Dashboard**: Pod and service metrics (AKS only)
- **GitHub Actions**: Build and deployment logs
