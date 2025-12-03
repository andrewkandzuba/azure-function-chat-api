.PHONY: help setup clean test coverage lint format docker-build docker-run tf-init tf-plan tf-apply helm-install func-start

# Variables
PYTHON := python3
VENV := .venv
DOCKER_IMAGE := azure-function-chat-api
DOCKER_TAG := latest
HELM_RELEASE := azure-function-chat-api

help:
	@echo "Available commands:"
	@echo "  make setup          - Set up local development environment"
	@echo "  make clean          - Clean build artifacts and cache"
	@echo "  make test           - Run tests"
	@echo "  make coverage       - Run tests with coverage report"
	@echo "  make lint           - Run linting checks"
	@echo "  make format         - Format code with black"
	@echo "  make func-start     - Start Azure Function locally"
	@echo "  make docker-build   - Build Docker image"
	@echo "  make docker-run     - Run Docker container locally"
	@echo "  make tf-init        - Initialize Terraform"
	@echo "  make tf-plan        - Run Terraform plan"
	@echo "  make tf-apply       - Apply Terraform configuration"
	@echo "  make helm-install   - Install Helm chart"
	@echo "  make all            - Run format, lint, and test"

setup:
	@echo "Setting up development environment..."
	$(PYTHON) -m venv $(VENV)
	. $(VENV)/bin/activate && pip install --upgrade pip
	. $(VENV)/bin/activate && pip install -r requirements-dev.txt
	@echo "Setup complete! Activate venv with: source $(VENV)/bin/activate"

clean:
	@echo "Cleaning up..."
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".mypy_cache" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name "htmlcov" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name ".coverage" -delete
	find . -type f -name "coverage.xml" -delete
	@echo "Cleanup complete!"

test:
	@echo "Running tests..."
	. $(VENV)/bin/activate && pytest tests/ -v

coverage:
	@echo "Running tests with coverage..."
	. $(VENV)/bin/activate && pytest tests/ -v --cov=function_app --cov-report=html --cov-report=term
	@echo "Coverage report generated in htmlcov/index.html"

lint:
	@echo "Running linting checks..."
	. $(VENV)/bin/activate && flake8 function_app.py --count --select=E9,F63,F7,F82 --show-source --statistics
	. $(VENV)/bin/activate && flake8 function_app.py --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics
	. $(VENV)/bin/activate && mypy function_app.py --ignore-missing-imports

format:
	@echo "Formatting code..."
	. $(VENV)/bin/activate && black .
	@echo "Code formatted!"

func-start:
	@echo "Starting Azure Function locally..."
	. $(VENV)/bin/activate && func start

docker-build:
	@echo "Building Docker image..."
	docker build -t $(DOCKER_IMAGE):$(DOCKER_TAG) .
	@echo "Docker image built: $(DOCKER_IMAGE):$(DOCKER_TAG)"

docker-run:
	@echo "Running Docker container..."
	docker run -p 8080:80 \
		-e AzureWebJobsStorage="UseDevelopmentStorage=true" \
		-e FUNCTIONS_WORKER_RUNTIME="python" \
		$(DOCKER_IMAGE):$(DOCKER_TAG)

tf-init:
	@echo "Initializing Terraform..."
	cd terraform && terraform init

tf-plan:
	@echo "Running Terraform plan..."
	cd terraform && terraform plan

tf-apply:
	@echo "Applying Terraform configuration..."
	cd terraform && terraform apply

helm-install:
	@echo "Installing Helm chart..."
	helm upgrade --install $(HELM_RELEASE) ./helm/azure-function \
		--set image.repository=$(DOCKER_IMAGE) \
		--set image.tag=$(DOCKER_TAG)

all: format lint test
	@echo "All checks passed!"
