
.PHONY: lint plan apply init-gcloud init-gam gshell gam-build gam-shell

# Terraform targets

lint:
	terraform fmt -check
	terraform validate

fmt: lint
	terraform fmt

plan:
	terraform plan -out=tfplan

apply: plan
	terraform apply tfplan

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
	docker run -it --rm -v ~/.config/gcloud:/root/.config/gcloud google/cloud-sdk:slim bash
	@echo "Google Shell exited."

gam-build:
	@echo "Building GAM Docker image..."
	docker build -t gam7:latest gam
	@echo "GAM Docker image built."

gam-shell:
	@echo "Starting GAM Shell..."
	docker run -it --rm -v "${PWD}/gam/.gam:/root/.gam" gam7:latest bash
	@echo "GAM Shell exited."
