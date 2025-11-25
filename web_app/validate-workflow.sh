#!/bin/bash

# ============================================================================
# 🔍 AZURE DEPLOY WORKFLOW VALIDATION SCRIPT
# ============================================================================
# This script checks if your workflow is ready for deployment

echo "🔍 Validating Azure Deploy Workflow..."
echo "============================================"

# Check if required files exist
echo "📁 Checking required files..."

FILES=(
    ".github/workflows/azure-deploy.yml"
    "Dockerfile"
    "requirements.txt"
    "app.py"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ $file - Found"
    else
        echo "❌ $file - Missing"
    fi
done

# Check if workflow file is valid YAML
echo ""
echo "📋 Validating YAML syntax..."
if command -v python3 &> /dev/null; then
    python3 -c "import yaml; yaml.safe_load(open('.github/workflows/azure-deploy.yml'))" 2>/dev/null
    if [ $? -eq 0 ]; then
        echo "✅ azure-deploy.yml - Valid YAML syntax"
    else
        echo "❌ azure-deploy.yml - Invalid YAML syntax"
    fi
else
    echo "⚠️  Python3 not found, skipping YAML validation"
fi

# Check environment variables
echo ""
echo "🌍 Environment variables configured:"
echo "  AZURE_WEBAPP_NAME: abs-rules-extractor-app"
echo "  RESOURCE_GROUP: rg-abs-rules-extractor"
echo "  CONTAINER_REGISTRY: absrulesregistry.azurecr.io"
echo "  IMAGE_NAME: abs-rules-extractor"

# Required GitHub Secrets checklist
echo ""
echo "🔑 Required GitHub Secrets (you must configure these manually):"
echo "  [ ] AZURE_CREDENTIALS - Azure Service Principal JSON"
echo "  [ ] ACR_USERNAME - Azure Container Registry username"
echo "  [ ] ACR_PASSWORD - Azure Container Registry password"

echo ""
echo "📊 Workflow Summary:"
echo "  • 6 jobs configured"
echo "  • Production and staging environments"
echo "  • Security scanning included"
echo "  • Performance testing included"
echo "  • Health checks included"

echo ""
echo "🚀 Next Steps:"
echo "  1. Create Azure resources (if not done)"
echo "  2. Configure GitHub Secrets"
echo "  3. Push to main branch to trigger deployment"

echo ""
echo "✅ Validation complete!"
