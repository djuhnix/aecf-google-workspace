# Developer Guide: Google Workspace Management

This guide provides step-by-step instructions for developers to initialize the environment, authenticate with Google services, and manage users.

## 🛠️ Repository Initialization

To get started with the repository locally:

1. **Clone the repository**:
   ```bash
   git clone <repository-url>
   cd aecf-google-workspace
   ```

2. **Configure Environment Variables**:
   Copy the example variables file and fill in your domain and customer details.
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```
   Edit `terraform.tfvars` with your specific Google Workspace details.

3. **Initialize Terraform**:
   ```bash
   terraform init
   ```

4. **Validate Configuration**:
   ```bash
   terraform fmt
   terraform validate
   ```

---

## 🔐 Authentication

### 1. Google Cloud SDK (`gcloud`)
You need `gcloud` installed to interact with GCP and provide credentials for Terraform.

- **Login to your account**:
  ```bash
  gcloud auth login
  ```
- **Set Application Default Credentials (ADC)**:
  This is critical for Terraform to authenticate your local session.
  ```bash
  gcloud auth application-default login
  ```
- **Set your project**:
  ```bash
  gcloud config set project <YOUR_PROJECT_ID>
  ```

### 2. Google Apps Manager (`GAM`)
GAM is used for advanced Workspace management that Terraform might not cover.

- **Setup**:
  Follow the setup instructions in the `gam/` directory.
- **Login/Authorize**:
  Run the GAM initialization process to authorize the tool with your Admin account.
  ```bash
  # Example: If using the provided Dockerfile
  docker build -t gam-tool ./gam
  docker run -it gam-tool gam oauth create
  ```

---

## 👤 Adding a New User

Users are provisioned via a **GitOps flow**. Instead of editing YAML files manually, you trigger a GitHub Action via a `repository_dispatch` event.

### Triggering via GitHub API
You can use `curl` to send a request to GitHub to trigger the `new_user` workflow.

**Example Request**:
```bash
curl -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer <YOUR_GITHUB_TOKEN>" \
  https://api.github.com/repos/<OWNER>/<REPO>/dispatches \
  -d '{
    "event_type": "new_user",
    "client_payload": {
      "first_name": "Jane",
      "last_name": "Smith",
      "email": "jane.smith@yourcompany.com",
      "personal_email": "jane.personal@gmail.com",
      "ou_path": "/Engineering/DevOps",
      "groups": [
        { "email": "devops@yourcompany.com", "role": "MEMBER" },
        { "email": "all-staff@yourcompany.com", "role": "MEMBER" }
      ],
      "commit_id": "user-provisioning-123"
    }
  }'
```

### What happens next?
1. The **`Provision Google Workspace User`** workflow triggers.
2. It decrypts the current config using **SOPS**.
3. It appends the new user to `config/users.yaml` and updates `config/groups.yaml`.
4. It re-encrypts the files and commits the changes to the repo.
5. **Terraform Apply** is executed to create the user in the actual Google Workspace.

---

## 📝 Maintenance Tasks

- **Updating Group Memberships**: Edit `config/groups.yaml` directly, commit, and push.
- **Modifying OU Structure**: Update `config/org_units.yaml`.
- **Changing User Roles**: Update `config/roles.yaml`.
