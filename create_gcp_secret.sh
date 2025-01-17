#!/bin/bash

# Exit script on error
set -e

# Define variables
PROJECT_ID="project_id"
SECRET_NAME="cloudflare_apitoken_dns"
SECRET_VALUE="demosecret"

# Set the GCP project
echo "Setting project to $PROJECT_ID..."
gcloud config set project "$PROJECT_ID"

# Create the secret if it does not already exist
if gcloud secrets describe "$SECRET_NAME" &>/dev/null; then
    echo "Secret $SECRET_NAME already exists. Skipping creation."
else
    echo "Creating secret $SECRET_NAME..."
    gcloud secrets create "$SECRET_NAME" --replication-policy="automatic"
fi

# Add a version with the secret value
echo "Adding secret value..."
echo -n "$SECRET_VALUE" | gcloud secrets versions add "$SECRET_NAME" --data-file=-

# Validate the secret
echo "Validating secret $SECRET_NAME..."

# Check if the secret exists and retrieve the latest version value
SECRET_CONTENT=$(gcloud secrets versions access latest --secret="$SECRET_NAME" 2>/dev/null || true)

if [ -z "$SECRET_CONTENT" ]; then
    echo "Validation failed: Secret $SECRET_NAME exists but is empty."
    exit 1
else
    echo "Validation successful: Secret $SECRET_NAME exists and is non-empty."
fi
