# 🚀 GITHUB DEPLOYMENT INSTRUCTIONS

## 📋 **DEPLOYMENT CHECKLIST - DO THIS BEFORE PUSHING**

### ⚠️ **CRITICAL: Configure GitHub Secrets First**

**YOU MUST ADD THESE 3 SECRETS TO GITHUB BEFORE PUSHING:**

#### **1. ACR_USERNAME**
- **Name:** `ACR_USERNAME`
- **Value:** `RedTextExtractor`

#### **2. ACR_PASSWORD**
- **Name:** `ACR_PASSWORD`
- **Value:** `Fo/y6FojW7Le2bHB/ap8UXxH41GlGa1PkoqhkzE3Es+ACRBakaZK`

#### **3. AZURE_CREDENTIALS** (REQUIRED)
- **Name:** `AZURE_CREDENTIALS`
- **Value:** JSON from Azure Service Principal (get from Azure Portal)

**🔗 WHERE TO ADD SECRETS:**
1. Go to your GitHub repository
2. Click **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add each secret one by one

---

## 🎯 **DEPLOYMENT STEPS**

### **Step 1: Push to GitHub**
```bash
cd /Users/leizhengwang/Desktop/subsection_extraction_app2
git commit -m "🚀 Deploy ABS Rules Red Text Extractor with Azure CI/CD"
git push origin main
```

### **Step 2: Watch Deployment**
1. Go to your GitHub repository
2. Click **Actions** tab
3. Watch the workflow execute with 6 jobs:
   - 🔨 Build & Test
   - 🐳 Build Docker Image
   - 🚀 Deploy to Production
   - 🔒 Security Scan
   - ⚡ Performance Test

### **Step 3: Access Your App**
After successful deployment:
- **Production URL:** `https://absrulesextractor.azurewebsites.net`

---

## ⚠️ **WHAT HAPPENS IF SECRETS ARE MISSING**

If you push without configuring secrets:
- ❌ Docker build will fail (ACR login error)
- ❌ Azure deployment will fail (authentication error)
- ❌ Workflow will show red X in GitHub Actions

**Solution:** Add the secrets and re-run the workflow

---

## 🎉 **SUCCESS INDICATORS**

✅ **All GitHub Actions jobs green**
✅ **App accessible at production URL**
✅ **No security vulnerabilities found**
✅ **Performance tests pass**

---

## 🔧 **IF DEPLOYMENT FAILS**

1. **Check GitHub Actions logs** for error details
2. **Verify secrets are configured correctly**
3. **Ensure Azure resources exist** (Web App, Container Registry, Resource Group)
4. **Check Azure resource names** match workflow environment variables

---

## 📞 **GET AZURE_CREDENTIALS**

If you don't have AZURE_CREDENTIALS yet:

1. **Go to Azure Portal** (portal.azure.com)
2. **Search for "App registrations"**
3. **Create new registration** named "github-actions"
4. **Create client secret**
5. **Assign Contributor role** to your resource group
6. **Format as JSON:**
```json
{
  "clientId": "your-client-id",
  "clientSecret": "your-client-secret",
  "subscriptionId": "your-subscription-id",
  "tenantId": "your-tenant-id"
}
```

**Ready to deploy? Configure secrets first, then push!**
