variable "customer_id" {
  description = "The Google Workspace customer ID (e.g., C01234567 or 'my_customer')"
  type        = string
  default     = "my_customer"
  sensitive   = true
}

variable "domain" {
  description = "The primary Google Workspace domain name (e.g., example.com)"
  type        = string
}

variable "config_dir" {
  description = "Directory containing the YAML configuration files"
  type        = string
  default     = "./config"
}

variable "target_service_account" {
  description = "The email address of the target service account for automated provisioning"
  type        = string
  sensitive   = true
}

variable "enable_user_creation" {
  description = "Feature flag to enable/disable automated user provisioning from YAML"
  type        = bool
  default     = true
}

variable "enable_group_creation" {
  description = "Feature flag to enable/disable automated group provisioning from YAML"
  type        = bool
  default     = true
}

variable "enable_ou_creation" {
  description = "Feature flag to enable/disable automated organizational unit provisioning from YAML"
  type        = bool
  default     = true
}

variable "default_user_password" {
  description = "Default password for users without an explicit initial password"
  type        = string
  default     = "P@ssw0rdChangeMe123!"
  sensitive   = true
}

# Outscale provider variables
variable "osc_access_key_id" {
  description = "Outscale API access key ID"
  type        = string
  sensitive   = true
}

variable "osc_secret_key_id" {
  description = "Outscale API secret key ID"
  type        = string
  sensitive   = true
}