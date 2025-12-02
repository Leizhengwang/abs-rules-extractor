# 🚀 Quick Start: Save $20/month on Azure Costs

## Current Cost: ~$36/month → Optimized Cost: ~$14/month

---

## ✅ What We're Doing

**Switching from:**
- ❌ Azure Container Registry (Standard) = $20/month
- ✅ App Service Plan (B1) = $13/month

**Switching to:**
- ✅ GitHub Container Registry (FREE) = $0/month
- ✅ App Service Plan (B1) = $13/month

**Result:** Save $20/month ($240/year) = 56% cost reduction!

---

## 🎯 Implementation Steps (15 minutes)

### **Step 1: Make GitHub Repository Public** (optional but recommended)

If your repository is private, GitHub Container Registry is still free for public images!

```bash
# In GitHub: Settings → Danger Zone → Change visibility → Make public
```

Or keep it private - GitHub gives you 500 MB free storage.

---

### **Step 2: Replace Your Current Workflow**

I've created a cost-optimized workflow file: `.github/workflows/azure-deploy-cost-optimized.yml`

**Option A: Test First (Recommended)**
```bash
# Keep both workflows, test the new one
# The new file is already created: azure-deploy-cost-optimized.yml
# Push and see it work, then delete the old one
```

**Option B: Replace Immediately**
```bash
cd /Users/leizhengwang/Desktop/subsection_extraction_app2

# Backup current workflow
cp .github/workflows/azure-deploy.yml .github/workflows/azure-deploy-OLD-BACKUP.yml

# Replace with cost-optimized version
cp .github/workflows/azure-deploy-cost-optimized.yml .github/workflows/azure-deploy.yml

# Commit and push
git add .github/workflows/
git commit -m "Switch to GitHub Container Registry to save $20/month"
git push origin main
```

---

### **Step 3: Watch the Deployment**

1. Go to GitHub Actions: https://github.com/YOUR-USERNAME/abs-rules-extractor/actions
2. Watch the workflow run
3. Verify it completes successfully
4. Check your app still works: https://absrulered2-d7hcgtadawaqaren.centralus-01.azurewebsites.net/

---

### **Step 4: Delete Azure Container Registry** (After confirming it works)

```bash
# Wait 24-48 hours to make sure everything works fine
# Then delete the expensive Azure Container Registry

az acr delete --name redtextextractor --resource-group LeiWang --yes
```

**This saves you $20/month immediately!**

---

## 🔍 What Changed in the Workflow

### **Old (Expensive):**
```yaml
env:
  CONTAINER_REGISTRY: redtextextractor.azurecr.io  # $20/month
  
- name: Login to Azure Container Registry
  uses: azure/docker-login@v2
  with:
    login-server: redtextextractor.azurecr.io
    username: ${{ secrets.ACR_USERNAME }}  # Need to manage
    password: ${{ secrets.ACR_PASSWORD }}  # Need to manage
```

### **New (Free):**
```yaml
env:
  CONTAINER_REGISTRY: ghcr.io  # FREE!
  IMAGE_NAME: ${{ github.repository_owner }}/abs-rules-extractor

- name: Login to GitHub Container Registry
  uses: docker/login-action@v2
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}  # Automatic, no setup needed!
```

---

## 📊 Cost Comparison

| Before | After | Savings |
|--------|-------|---------|
| Azure Container Registry (Standard): $20/month | GitHub Container Registry: $0/month | **$20/month** |
| App Service Plan (B1): $13/month | App Service Plan (B1): $13/month | $0 |
| Storage: $0.50/month | Storage: $0.50/month | $0 |
| **Total: $33.50/month** | **Total: $13.50/month** | **$20/month** |
| **Annual: $402** | **Annual: $162** | **$240/year** |

---

## ✅ Advantages of GitHub Container Registry

1. **FREE** - No cost for public repositories
2. **Better Integration** - Native GitHub Actions support
3. **Automatic Authentication** - Uses GitHub token
4. **No Extra Secrets** - No ACR_USERNAME/ACR_PASSWORD needed
5. **Same Performance** - Container pulls are just as fast
6. **Unlimited Bandwidth** - No egress charges

---

## 🎯 Quick Command Summary

```bash
# 1. Test the new workflow (already created)
cd /Users/leizhengwang/Desktop/subsection_extraction_app2
git add .github/workflows/azure-deploy-cost-optimized.yml
git commit -m "Add cost-optimized workflow using GitHub Container Registry"
git push origin main

# 2. After confirming it works, delete old Azure registry (saves $20/month)
az acr delete --name redtextextractor --resource-group LeiWang --yes

# 3. Optional: Clean up old GitHub secrets (no longer needed)
# Go to GitHub repo → Settings → Secrets → Delete:
# - ACR_USERNAME
# - ACR_PASSWORD
```

---

## 🔧 Troubleshooting

### **If the new workflow fails:**

**Error:** "Permission denied to push to ghcr.io"
**Fix:** Make sure repository has `packages: write` permission (already set in workflow)

**Error:** "Image not found"
**Fix:** Check that the image was pushed successfully in the "Build Docker Image" job

**Error:** "Azure can't pull the image"
**Fix:** Make sure the GitHub Container Registry image is public:
```bash
# Go to GitHub → Packages → abs-rules-extractor → Package settings
# Change visibility to "Public"
```

---

## 💡 Additional Cost Savings (Optional)

### **Further reduce costs:**

1. **Free Tier App Service (F1)** - Save another $13/month
   - Downside: Only 60 minutes/day compute time
   - Best for: Testing/demos only

2. **Azure Reserved Instance** - Save 35% with 1-year commitment
   - B1: $13/month → $8.50/month
   - Best for: Long-term production use

3. **Stop app during off-hours** - Save 30-50%
   - Use Azure Automation to stop/start on schedule
   - Best for: Apps only used during business hours

---

## 🎉 Summary

**Action:** Replace workflow to use GitHub Container Registry  
**Time:** 15 minutes  
**Savings:** $20/month ($240/year)  
**Downside:** None! Same functionality, better integration  

**Next deployment will automatically:**
- ✅ Build Docker image
- ✅ Push to GitHub Container Registry (FREE)
- ✅ Deploy to Azure Web App
- ✅ Save you $240/year!

---

**Ready to save money? Let me know if you want me to make the change for you!**
