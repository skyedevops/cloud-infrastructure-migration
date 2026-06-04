SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help

ENV        ?= dev
TF_DIR     := terraform
APP_DIR    := app
BUCKET     ?= my-tf-state
LOCKS      ?= my-tf-locks
REGION     ?= us-east-1

export PATH := $$HOME/.local/bin:$(PATH)

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.PHONY: init-backend
init-backend: ## Bootstrap S3 + DynamoDB for remote state
	BUCKET=$(BUCKET) TABLE=$(LOCKS) REGION=$(REGION) ./scripts/bootstrap-state.sh

.PHONY: fmt
fmt: ## terraform fmt
	terraform -chdir=$(TF_DIR) fmt -recursive

.PHONY: validate
validate: ## terraform validate
	./scripts/validate.sh

.PHONY: plan
plan: ## terraform plan (ENV=dev)
	cd $(TF_DIR) && terraform init -input=false && terraform plan -var-file=terraform.tfvars.$(ENV) -out=tfplan

.PHONY: apply
apply: ## terraform apply (ENV=dev, set AUTO_APPROVE=true to skip prompt)
	cd $(TF_DIR) && terraform apply $(if $(AUTO_APPROVE),-auto-approve,) tfplan

.PHONY: deploy
deploy: validate ## Validate + deploy (ENV=dev)
	AUTO_APPROVE=$(AUTO_APPROVE) ./scripts/deploy.sh $(ENV)

.PHONY: destroy
destroy: ## Destroy an environment (ENV=dev)
	./scripts/destroy.sh $(ENV)

.PHONY: outputs
outputs: ## Show Terraform outputs
	terraform -chdir=$(TF_DIR) output

.PHONY: app-install
app-install: ## Install app dependencies
	cd $(APP_DIR) && npm install

.PHONY: app-test
app-test: ## Run app tests
	cd $(APP_DIR) && npm test

.PHONY: app-run
app-run: ## Run the app locally (requires .env)
	cd $(APP_DIR) && npm run dev

.PHONY: app-sync
app-sync: ## Sync local app build to S3 + invalidate CloudFront
	@if [[ -z "$$BUCKET" || -z "$$DIST" ]]; then \
		echo "Usage: make app-sync BUCKET=<bucket> DIST=<distribution-id>"; exit 1; \
	fi
	./scripts/sync-static.sh $(APP_DIR) $$BUCKET $$DIST

.PHONY: clean
clean: ## Remove local plan files and .terraform dirs
	rm -f $(TF_DIR)/tfplan $(TF_DIR)/tfplan-destroy
	rm -rf $(TF_DIR)/.terraform

.PHONY: tflint
tflint: ## Run tflint if installed
	@if command -v tflint >/dev/null 2>&1; then \
		cd $(TF_DIR) && tflint --recursive; \
	else \
		echo "tflint not installed; skipping"; \
	fi
