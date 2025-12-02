#!/bin/bash

# ====================================================================
# AZURE CONTAINER REGISTRY SETUP - COMPLETE
# ====================================================================

echo "✅ Azure Container Registry Created Successfully!"
echo ""
echo "Registry Details:"
echo "=================="
echo "Name: redtextextractor"
echo "Login Server: redtextextractor.azurecr.io"
echo "Resource Group: LeiWang"
echo "SKU: Basic ($20/month)"
echo "Status: Active"
echo ""

# ====================================================================
# STEP 1: ADD GITHUB SECRETS (REQUIRED)
# ====================================================================

echo "🔐 STEP 1: Add ACR Credentials to GitHub Secrets"
echo "=================================================="
echo ""
echo "Go to: https://github.com/Leizhengwang/abs-rules-extractor/settings/secrets/actions"
echo ""
echo "Add these two secrets:"
echo ""
echo "Secret Name: ACR_USERNAME"
echo "Secret Value: redtextextractor"
echo ""
echo "Secret Name: ACR_PASSWORD"
echo "Secret Value: [Run: az acr credential show --name redtextextractor --resource-group LeiWang]"
echo ""
echo "Press Enter after you've added both secrets..."
read

# ====================================================================
# STEP 2: COMMIT AND PUSH WORKFLOW CHANGES
# ====================================================================

echo ""
echo "🚀 STEP 2: Commit and Push Changes"
echo "===================================="
echo ""

git add .github/workflows/azure-deploy.yml

git commit -m "Recreate Azure Container Registry and update workflow

- ACR created: redtextextractor.azurecr.io
- Basic SKU: \$20/month
- Admin enabled for GitHub Actions
- Workflow updated to use ACR credentials
- Ready for automated deployment"

echo ""
echo "Pushing to GitHub..."
git push origin main

echo ""
echo "✅ Changes pushed! GitHub Actions will now:"
echo "   1. Build Docker image"
echo "   2. Push to Azure Container Registry"
echo "   3. Deploy to Azure Web App"
echo "   4. Run health checks and performance tests"
echo ""
echo "Monitor the deployment:"
echo "https://github.com/Leizhengwang/abs-rules-extractor/actions"
echo ""
echo "Your app will be available at:"
echo "https://absrulered2.azurewebsites.net"
echo ""
