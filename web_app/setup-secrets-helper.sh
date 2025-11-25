#!/bin/bash

# ============================================================================
# 🎯 QUICK AZURE CREDENTIALS HELPER
# ============================================================================
# This script helps you understand where to put Azure credentials

echo "🔑 Azure Credentials Setup Helper"
echo "=================================="
echo ""

echo "📍 WHERE TO ADD SECRETS:"
echo "1. Go to your GitHub repository"
echo "2. Click Settings → Secrets and variables → Actions"
echo "3. Click 'New repository secret'"
echo ""

echo "🔑 REQUIRED SECRETS (3 total):"
echo ""

echo "Secret 1:"
echo "  Name: AZURE_CREDENTIALS"
echo "  Value: JSON from service principal (see guide)"
echo ""

echo "Secret 2:"
echo "  Name: ACR_USERNAME" 
echo "  Value: Your container registry username"
echo ""

echo "Secret 3:"
echo "  Name: ACR_PASSWORD"
echo "  Value: Your container registry password"
echo ""

echo "📋 HOW TO GET VALUES:"
echo "Option 1: Azure Portal (web interface)"
echo "  - No CLI needed!"
echo "  - Go to portal.azure.com"
echo "  - See AZURE_CREDENTIALS_SETUP.md for detailed steps"
echo ""

echo "Option 2: Azure Cloud Shell"
echo "  - Click shell icon in Azure Portal"
echo "  - Run commands from the guide"
echo ""

echo "✅ VERIFICATION:"
echo "After adding secrets, test by pushing code:"
echo "  git add ."
echo "  git commit -m 'test deployment'"
echo "  git push origin main"
echo ""

echo "📖 Full guide: AZURE_CREDENTIALS_SETUP.md"
echo "🚀 Your workflow will work once secrets are configured!"
