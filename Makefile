# Makefile for Google Cloud Run Deployment
# Replicates functionality from demo-build.sh

# Variables
PROJECT_ID := $(shell gcloud config get-value project)
PROJECT_USER := $(shell gcloud config get-value core/account)
PROJECT_NUMBER := $(shell gcloud projects describe $(PROJECT_ID) --format="value(projectNumber)")
IDNS := $(PROJECT_ID).svc.id.goog
GCP_REGION := us-central1
GCP_ZONE := us-central1-a
NETWORK_NAME := default
REPO_NAME := demo-repo
IMAGE_NAME := hello
SERVICE_NAME := hello-web
DOCKER_URI := $(GCP_REGION)-docker.pkg.dev/$(PROJECT_ID)/$(REPO_NAME)/$(IMAGE_NAME)

# Default target
.PHONY: help
help: ## Show this help message
	@echo "Google Cloud Run Deployment Makefile"
	@echo ""
	@echo "Current Configuration:"
	@echo "  Project ID: $(PROJECT_ID)"
	@echo "  Project User: $(PROJECT_USER)"
	@echo "  Project Number: $(PROJECT_NUMBER)"
	@echo "  Region: $(GCP_REGION)"
	@echo "  Service Name: $(SERVICE_NAME)"
	@echo "  Docker URI: $(DOCKER_URI)"
	@echo ""
	@echo "Available targets:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: info
info: ## Display project information
	@echo "Project ID: $(PROJECT_ID)"
	@echo "Project User: $(PROJECT_USER)"
	@echo "Project Number: $(PROJECT_NUMBER)"
	@echo "Identity Domain: $(IDNS)"
	@echo "Region: $(GCP_REGION)"
	@echo "Zone: $(GCP_ZONE)"
	@echo "Network: $(NETWORK_NAME)"
	@echo "Repository: $(REPO_NAME)"
	@echo "Image: $(IMAGE_NAME)"
	@echo "Service: $(SERVICE_NAME)"
	@echo "Docker URI: $(DOCKER_URI)"

.PHONY: init
init: ## Initialize GCP services and configuration
	@echo "Initializing..."
	gcloud services enable \
		artifactregistry.googleapis.com \
		cloudbuild.googleapis.com \
		run.googleapis.com
	gcloud config set run/region $(GCP_REGION)
	gcloud config set artifacts/location $(GCP_REGION)
	@echo "Initialization complete."

.PHONY: create-repo
create-repo: ## Create Docker artifact repository
	gcloud artifacts repositories create $(REPO_NAME) \
		--repository-format=docker \
		--description="Docker repo"

.PHONY: list-repos
list-repos: ## List artifact repositories
	gcloud artifacts repositories list

.PHONY: auth-docker
auth-docker: ## Configure Docker authentication
	gcloud auth configure-docker $(GCP_REGION)-docker.pkg.dev

.PHONY: build-image
build-image: ## Build and push Docker image to artifact registry
	gcloud builds submit --tag $(DOCKER_URI)

.PHONY: deploy-service
deploy-service: ## Deploy service to Cloud Run
	gcloud run deploy $(SERVICE_NAME) --image $(DOCKER_URI)

.PHONY: list-services
list-services: ## List Cloud Run services
	gcloud run services list \
		--platform managed \
		--region $(GCP_REGION)

.PHONY: get-url
get-url: ## Get the service URL
	@gcloud run services describe $(SERVICE_NAME) \
		--platform managed \
		--region $(GCP_REGION) \
		--format="value(status.url)"

.PHONY: test-service
test-service: ## Test the deployed service
	@echo "Testing service..."
	@SVC_URL=$$(gcloud run services describe $(SERVICE_NAME) \
		--platform managed \
		--region $(GCP_REGION) \
		--format="value(status.url)"); \
	echo "Service URL: $$SVC_URL"; \
	curl -X GET $$SVC_URL

.PHONY: build
build: init create-repo list-repos auth-docker build-image deploy-service list-services test-service ## Complete build and deployment process
	@echo "--------------------------------------------------------"
	@echo " REGION: $(GCP_REGION), SERVICE: $(SERVICE_NAME) "
	@echo "--------------------------------------------------------"
	@echo "Build and deployment complete!"

.PHONY: delete-service
delete-service: ## Delete the Cloud Run service
	gcloud run services delete $(SERVICE_NAME) --region $(GCP_REGION)

.PHONY: delete-image
delete-image: ## Delete the Docker image from artifact registry
	gcloud artifacts docker images delete $(DOCKER_URI)

.PHONY: delete-repo
delete-repo: ## Delete the artifact repository
	gcloud artifacts repositories delete $(REPO_NAME) --location $(GCP_REGION)

.PHONY: destroy
destroy: init delete-service delete-image delete-repo ## Complete cleanup - delete service, image, and repository
	@echo "--------------------------------------------------------"
	@echo " REGION: $(GCP_REGION), SERVICE: $(SERVICE_NAME) "
	@echo "--------------------------------------------------------"
	@echo "Cleanup complete!"

.PHONY: local-build
local-build: ## Build Docker image locally for testing
	docker build -t $(IMAGE_NAME) .

.PHONY: local-run
local-run: ## Run Docker image locally for testing
	docker run -p 8080:8080 -e PORT=8080 $(IMAGE_NAME)

.PHONY: local-test
local-test: ## Test local Docker container
	curl -X GET http://localhost:8080

.PHONY: clean-local
clean-local: ## Clean up local Docker images
	docker rmi $(IMAGE_NAME) || true
	docker system prune -f

# Convenience targets
.PHONY: up down
up: build ## Alias for build
down: destroy ## Alias for destroy 