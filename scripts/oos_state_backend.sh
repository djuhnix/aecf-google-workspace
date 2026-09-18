#!/usr/bin/env bash
set -euo pipefail

# --- CONFIGURATION ---
OOS_ENDPOINT="https://oos.eu-west-2.outscale.com"  # Update region if using cloudgouv-eu-west-1
REGION="eu-west-2"
BUCKET_NAME="aecf-tf-state"
STATE_KEY="workspace/terraform.tfstate"

echo "=== 1. Creating Outscale OOS Bucket: ${BUCKET_NAME} ==="
aws s3api create-bucket \
  --endpoint-url "${OOS_ENDPOINT}" \
  --bucket "${BUCKET_NAME}" \
  --region "${REGION}"

echo "=== 2. Enabling Object Versioning ==="
aws s3api put-bucket-versioning \
  --endpoint-url "${OOS_ENDPOINT}" \
  --bucket "${BUCKET_NAME}" \
  --versioning-configuration Status=Enabled

echo "=== 3. Setting Bucket ACL to Private ==="
aws s3api put-bucket-acl \
  --endpoint-url "${OOS_ENDPOINT}" \
  --bucket "${BUCKET_NAME}" \
  --acl private

echo "=== 4. Updating backend.tf for Outscale OOS ==="
cat <<EOF > backend.tf
terraform {
  backend "s3" {
    bucket                      = "${BUCKET_NAME}"
    key                         = "${STATE_KEY}"
    region                      = "${REGION}"
    endpoint                    = "${OOS_ENDPOINT}"
    skip_credentials_validation = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_s3_checksum            = true
    use_path_style              = true
  }
}
EOF

echo "=== 5. Initializing Terraform Backend ==="
terraform init -reconfigure

echo "✅ Outscale backend configured and initialized successfully!"
