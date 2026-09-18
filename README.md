# Google Workspace Management with Terraform (YAML-driven)

Enterprise-ready Infrastructure as Code (IaC) repository for declarative management of **Google Workspace** resources (Organizational Units, Groups, Users, and Admin Roles) using **Terraform**, version-controlled **YAML** definitions, and **GitHub Actions** for automated provisioning.

---

## 🏗 Architecture Overview

```
.
├── .github/workflows/terraform.yml # Automation: Provisioning via Repository Dispatch
├── config/                      # Human-readable & auditable YAML configurations
│   ├── credentials.json.example # Service Account credentials schema
│   ├── groups.yaml              # Group definitions, permissions & members
│   ├── org_units.yaml           # Organizational Unit hierarchy
│   ├── roles.yaml               # Admin role assignments
│   └── users.yaml               # Provisioned users & identities
├── locals.tf                    # Transformation logic mapping YAML -> Terraform types
├── org_units.tf                 # googleworkspace_org_unit resources
├── groups.tf                    # googleworkspace_group, settings & members
├── users.tf                     # googleworkspace_user resources & random passwords
├── roles.tf                     # googleworkspace_role_assignment resources
├── providers.tf                 # Google Workspace provider with required OAuth scopes
├── versions.tf                  # Required Terraform & provider versions
├── variables.tf                 # Input variables & feature toggles
├── outputs.tf                   # Deployment summaries and resource counts
└── terraform.tfvars.example     # Parameter template
```

### Why YAML-Driven Configuration?
- **Separation of Concerns:** Non-Terraform engineers (HR, IT Helpdesk, Operations) can review and contribute to PRs modifying YAML files without writing HCL.
- **Auditable & GitOps-Ready:** Every user, group, and OU change produces a clear, concise Git diff and can trigger automated CI/CD plans.
- **Safety by Default:** Feature flags enable targeted migrations (`enable_user_creation`, `enable_group_creation`, `enable_ou_creation`).

---

## 🤖 Automated Provisioning (GitHub Actions)

This repository is configured to automatically provision users via a **Repository Dispatch** event (e.g., triggered by a Google Form or external portal).

### Trigger Event
**Event Type**: `new_user`

**Payload Schema**:
```json
{
    "event_type": "new_user",
    "client_payload": {
      "first_name": "John",
      "last_name": "Doe",
      "email": "john.doe@example.com",
      "personal_email": "john.personal@gmail.com",
      "ou_path": "/Engineering/DevOps",
      "groups": [
        { "email": "devops@example.com", "role": "MEMBER" },
        { "email": "all-staff@example.com", "role": "MEMBER" }
      ]
    }
}
```

### Automation Flow
1. **Receive Event**: GitHub Action triggers on `repository_dispatch`.
2. **Update Config**: The workflow uses `yq` to append the new user to `config/users.yaml` and update `config/groups.yaml`.
3. **Git Commit**: The changes are committed back to the repository (GitOps).
4. **Apply**: Terraform is initialized and applied using an OIDC token via Workload Identity Federation for secure authentication.

---

## 🔐 Prerequisites & GCP Setup

### 1. Create a Google Cloud Service Account
1. Open [Google Cloud Console](https://console.cloud.google.com/).
2. Create or select a GCP project (e.g. `gsuite-terraform-mgmt`).
3. Navigate to **IAM & Admin > Service Accounts** and create a service account:
   - Name: `terraform-saworkspace`
4. Enable the **Admin SDK API** and **Cloud Identity API** in your GCP project.
5. Create and download a **JSON Service Account Key** and place it securely at `./credentials.json` (git-ignored).

### 2. Configure Domain-Wide Delegation (DWD)
1. In the GCP Console, copy the Service Account's **Client ID** (OAuth 2 Client ID, a 21-digit number).
2. Go to the [Google Workspace Admin Console](https://admin.google.com/).
3. Navigate to **Security > Access and data control > API controls > Manage Domain Wide Delegation**.
4. Click **Add new** and paste the **Client ID**.
5. Grant the following **OAuth Scopes** (comma-separated):
   ```text
   https://www.googleapis.com/auth/admin.directory.orgunit,
   https://www.googleapis.com/auth/admin.directory.group,
   https://www.googleapis.com/auth/admin.directory.group.member,
   https://www.googleapis.com/auth/admin.directory.user,
   https://www.googleapis.com/auth/admin.directory.user.alias,
   https://www.googleapis.com/auth/admin.directory.rolemanagement,
   https://www.googleapis.com/auth/apps.groups.settings
   ```

### 3. Configure GitHub Secrets (for Automation)
Add the following secrets to your GitHub repository:
- `GCP_WORKLOAD_IDENTITY_PROVIDER`: Your Workload Identity Pool provider ID.
- `GCP_SERVICE_ACCOUNT`: The service account email.
- `GWS_DOMAIN`: Your primary Google Workspace domain.
- `GWS_CUSTOMER_ID`: Your Google Workspace Customer ID.
- `GWS_ADMIN_EMAIL`: The super admin email for impersonation.

---

## 🚀 Quick Start

### 1. Initialize Configuration
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars`:
```hcl
domain                  = "yourcompany.com"
customer_id             = "my_customer"
impersonated_user_email = "admin@yourcompany.com"
credentials_file        = "credentials.json"
```

### 2. Format & Validate
```bash
terraform init
terraform fmt
terraform validate
```

### 3. Review Plan & Apply
```bash
terraform plan
terraform apply
```

---

## 📝 YAML Schema Reference

### `config/org_units.yaml`
```yaml
org_units:
  - name: "Engineering"
    path: "/Engineering"
    parent_path: "/"
    description: "Core Engineering Department"
    block_inheritance: false

  - name: "DevOps"
    path: "/Engineering/DevOps"
    parent_path: "/Engineering"
    description: "DevOps & SRE Team"
    block_inheritance: false
```

### `config/groups.yaml`
```yaml
groups:
  - email: "devops@yourcompany.com"
    name: "DevOps Team"
    description: "DevOps mailing list and permissions"
    aliases:
      - "sre@yourcompany.com"
    settings:
      who_can_join: "INVITED_CAN_JOIN"
      who_can_view_membership: "ALL_IN_DOMAIN_CAN_VIEW"
      who_can_post_message: "ALL_IN_DOMAIN_CAN_POST"
      allow_external_members: "false"
      who_can_view_group: "ALL_IN_DOMAIN_CAN_VIEW"
      spam_moderation_level: "MODERATE"
    members:
      - email: "alex@yourcompany.com"
        role: "OWNER"
        type: "USER"
      - email: "sam@yourcompany.com"
        role: "MEMBER"
        type: "USER"
```

### `config/users.yaml`
```yaml
users:
  - first_name: "Alex"
    last_name: "Doe"
    email: "alex@yourcompany.com"
    org_unit_path: "/Engineering/DevOps"
    suspended: false
    change_password_at_next_login: true
    recovery_email: "alex.personal@gmail.com"
    aliases:
      - "alex.doe@yourcompany.com"
```

---

## 🔒 Production Recommendations

1. **Remote State Backend:** Store Terraform state in a secured Google Cloud Storage (GCS) bucket with versioning and encryption enabled.
2. **CI/CD Integration:** Use the provided GitHub Action for automated user provisioning. For general infra changes, run `terraform plan` on PRs.
3. **Least Privilege:** Restrict GCP Service Account access and audit DWD scopes periodically.