# 🚨 Azure Deployment Troubleshooting

## **Current Issue: GitHub Action Stuck at "Deploy to Production"**

### 🔍 **Possible Causes & Solutions:**

#### **1. Azure Web App Name Conflict** 
**Issue**: `ABSRuleRed` might not be available
- **Check**: Go to Azure Portal → App Services → Create → check if the name is available
- **Fix**: Use a more unique name like `ABSRuleRed-[YOUR_INITIALS]-[DATE]`

#### **2. Incorrect Azure Credentials**
**Issue**: `AZURE_CREDENTIALS` GitHub secret is wrong/expired
- **Check**: GitHub repo → Settings → Secrets → `AZURE_CREDENTIALS` 
- **Fix**: Generate new service principal credentials:
  ```bash
  az ad sp create-for-rbac --name "abs-rules-extractor-sp" --role contributor --scopes /subscriptions/YOUR_SUBSCRIPTION_ID/resourceGroups/LeiWang --sdk-auth
  ```

#### **3. Container Registry Access**
**Issue**: ACR credentials are incorrect
- **Check**: `ACR_USERNAME` and `ACR_PASSWORD` in GitHub secrets
- **Fix**: Get credentials from Azure Portal → Container Registry → Access keys

### 🛠️ **Quick Fixes to Try:**

#### **Fix 1: Update Web App Name** (Already Done)
The app name was changed to `abs-rules-extractor-lw2024` for uniqueness.

#### **Fix 2: Check GitHub Secrets**
1. Go to your GitHub repo → Settings → Secrets and variables → Actions
2. Verify these secrets exist and are correct:
   - `AZURE_CREDENTIALS`
   - `ACR_USERNAME` 
   - `ACR_PASSWORD`

#### **Fix 3: Manual Test**
Try deploying manually to test your Azure setup:
```bash
# Test Azure login
az login

# Test container registry access  
az acr login --name redtextextractor

# Test web app exists
az webapp show --name ABSRuleRed --resource-group LeiWang
```

### 📊 **Current Configuration:**
- **Web App Name**: `ABSRuleRed`
- **URL**: https://ABSRuleRed.azurewebsites.net
- **Resource Group**: `LeiWang`
- **Container Registry**: `redtextextractor.azurecr.io`
- **Image**: `abs-rules-extractor`

### 🔄 **To Retry Deployment:**
1. Fix any issues above
2. Go to GitHub repo → Actions → Re-run failed workflow
   OR
3. Make a small commit to trigger new deployment:
   ```bash
   git commit --allow-empty -m "Trigger deployment retry"
   git push origin main
   ```

### 📞 **If Still Stuck:**
Check the detailed GitHub Actions logs for the exact error message at the "Deploy to Azure Web App" step.
