
# Google Cloud and Google Workspace providers configuration
provider "google" {
  alias = "impersonation"
}

data "google_service_account_access_token" "workspace" {
  provider               = google.impersonation
  target_service_account = var.target_service_account
  scopes = [
    "https://www.googleapis.com/auth/admin.directory.user",
    "https://www.googleapis.com/auth/admin.directory.group",
    "https://www.googleapis.com/auth/admin.directory.orgunit",
    "https://www.googleapis.com/auth/admin.directory.rolemanagement",
    "https://www.googleapis.com/auth/apps.groups.settings"
  ]
  lifetime = "3600s"
}

provider "googleworkspace" {
  customer_id  = var.customer_id
  access_token = data.google_service_account_access_token.workspace.access_token
}

# Outscale provider configuration
provider "outscale" {
  access_key_id = var.osc_access_key_id
  secret_key_id = var.osc_secret_key_id

  api {
    endpoint = "https://api.eu-west-2.outscale.com"
    region   = "eu-west-2"
  }
}