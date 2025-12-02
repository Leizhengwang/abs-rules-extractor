#!/bin/bash

# Script to add ACR credentials to GitHub Secrets
# This will add the Azure Container Registry credentials to your GitHub repository

echo "🔐 Setting up ACR credentials in GitHub Secrets..."

# ACR Credentials
ACR_USERNAME="redtextextractor"
ACR_PASSWORD=$(az acr credential show --name redtextextractor --resource-group LeiWang --query "passwords[0].value" -o tsv)

# Get repository info
REPO_OWNER=$(git config --get remote.origin.url | sed -n 's/.*github.com[:/]\([^/]*\).*/\1/p')
REPO_NAME=$(git config --get remote.origin.url | sed -n 's/.*github.com[:/][^/]*\/\([^.]*\).*/\1/p')

echo "Repository: $REPO_OWNER/$REPO_NAME"
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "Please install it: brew install gh"
    echo ""
    echo "Or manually add these secrets to GitHub:"
    echo "Go to: https://github.com/$REPO_OWNER/$REPO_NAME/settings/secrets/actions"
    echo ""
    echo "ACR_USERNAME: $ACR_USERNAME"
    echo "ACR_PASSWORD: $ACR_PASSWORD"
    exit 1
fi

# Set secrets using gh CLI
echo "Adding ACR_USERNAME..."
echo "$ACR_USERNAME" | gh secret set ACR_USERNAME

echo "Adding ACR_PASSWORD..."
echo "$ACR_PASSWORD" | gh secret set ACR_PASSWORD

echo ""
echo "✅ ACR credentials added to GitHub Secrets!"
echo ""
echo "Next steps:"
echo "1. Commit and push the workflow changes"
echo "2. GitHub Actions will automatically build and deploy using ACR"
