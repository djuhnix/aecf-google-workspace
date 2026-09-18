
.PHONY: lint plan apply init-gcloud init-gam gshell gam-build gam-shell install-hooks list-wip wip-info list-sas

# Terraform targets

lint: fmt
	terraform fmt -check
	terraform validate

fmt:
	terraform fmt

plan:
	terraform plan -out=tfplan

apply: plan
	terraform apply tfplan

install-hooks:
	@echo "Installing pre-commit hooks..."
	@printf '#!/bin/sh\nmake lint\n' > .git/hooks/pre-commit
	@chmod +x .git/hooks/pre-commit
	@echo "Pre-commit hook installed successfully."

clean: lint
	rm -f tfplan

# Google
init-gcloud:
	@echo "Initializing Google Cloud SDK..."
	docker run -it --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim gcloud auth application-default login

init-gam:
	@echo "Initializing GAM OAuth credentials..."
	@echo "A browser window will open for authentication. Please follow the instructions."
	docker run --rm -it -v "${PWD}/gam/.gam:/root/.gam" gam7 gam oauth create

gshell:
	@echo "Starting Google Shell..."
	docker run -it --platform linux/amd64 --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim bash
	@echo "Google Shell exited."

gam-build:
	@echo "Building GAM Docker image..."
	docker build -t gam7:latest gam
	@echo "GAM Docker image built."

gam-shell:
	@echo "Starting GAM Shell..."
	docker run -it --rm -v "${PWD}/gam/.gam:/root/.gam" gam7:latest bash
	@echo "GAM Shell exited."

# Workload Identity Federation
list-wip:
	@echo "Listing Workload Identity Pools..."
	docker run --platform linux/amd64 --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim gcloud iam workload-identity-pools list --location=global

wip-info:
	@echo "Fetching Workload Identity Pool Provider info..."
	docker run --platform linux/amd64 --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim gcloud iam workload-identity-pools providers list --location=global --workload-identity-pool $(WIP_POOL)"

list-sas:
	@echo "Listing Service Accounts..."
	docker run --platform linux/amd64 --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim gcloud iam service-accounts list
