#!/bin/bash
set -e

DRIVE_NAME="$1"
MANAGER_EMAIL="$2"

if [ -z "$DRIVE_NAME" ] || [ -z "$MANAGER_EMAIL" ]; then
  echo "Usage: $0 <drive_name> <manager_email>"
  exit 1
fi

echo "Checking if Shared Drive '$DRIVE_NAME' already exists..."

# Attempt to find the Shared Drive ID by name. 
# GAM print shareddrives typically outputs a CSV/table. 
# We use grep to find the line containing the drive name and awk to extract the first column (ID).
DRIVE_ID=$(docker run --rm -v "${PWD}/gam/.gam:/root/.gam" gam7 gam print shareddrives | grep "$DRIVE_NAME" | head -n 1 | awk -F',' '{print $1}' | xargs)

if [ -z "$DRIVE_ID" ]; then
  echo "Shared Drive not found. Creating '$DRIVE_NAME' with manager $MANAGER_EMAIL..."
  docker run --rm -v "${PWD}/gam/.gam:/root/.gam" gam7 gam create shareddrive "$DRIVE_NAME" admin "$MANAGER_EMAIL"
else
  echo "Shared Drive already exists (ID: $DRIVE_ID). Ensuring manager $MANAGER_EMAIL is assigned..."
  # Use 'add drive' to ensure the manager has the admin role without duplicating it if they already are
  docker run --rm -v "${PWD}/gam/.gam:/root/.gam" gam7 gam add drive "$DRIVE_ID" admin "$MANAGER_EMAIL"
fi

echo "Successfully synchronized Shared Drive: $DRIVE_NAME"
