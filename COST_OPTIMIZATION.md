# 💰 Cost Optimization Guide for Azure Deployment

## 📊 Current Cost Analysis

### **Your Current Setup:**
| Resource | Tier | Monthly Cost | Annual Cost |
|----------|------|--------------|-------------|
| **App Service Plan** | B1 (Basic) | ~$13.14/month | ~$157.68/year |
| **Container Registry** | Standard | ~$20.00/month | ~$240.00/year |
| **Storage (minimal)** | Pay-as-you-go | ~$0.50/month | ~$6.00/year |
| **Bandwidth** | First 100GB free | ~$0-2/month | ~$0-24/year |
| **TOTAL** | | **~$33-36/month** | **~$400-428/year** |

---

## 🎯 Cost Reduction Strategies

### **Option 1: Basic Optimization (Save ~$15/month)**
**Recommended for production use with moderate traffic**

#### 1. Downgrade Container Registry: Standard → Basic
```bash
az acr update --name redtextextractor --sku Basic
```
**Savings:** ~$15/month (~$180/year)

**What you keep:**
- ✅ All container registry features you need
- ✅ 10 GB storage (plenty for your app)
- ✅ Webhooks for CI/CD
- ✅ Same performance

**What you lose:**
- ❌ Geo-replication (you don't need this)
- ❌ Advanced security features (basic is fine for your case)

**New Monthly Cost:** ~$18-21/month (~$216-252/year)

---

### **Option 2: Maximum Savings (Save ~$28/month)**
**Best for development/testing or low-traffic apps**

#### 1. Use Azure Container Instances instead of App Service
**NOT RECOMMENDED** - Loses always-on capability

#### 2. Switch to FREE tier App Service (F1)
```bash
# Create a new FREE plan
az appservice plan create \
  --name LeiWangFree \
  --resource-group LeiWang \
  --sku F1 \
  --is-linux

# Move your app to the free plan
az webapp update \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --set plan=/subscriptions/YOUR-SUB-ID/resourceGroups/LeiWang/providers/Microsoft.Web/serverfarms/LeiWangFree
```

**Savings:** ~$13/month (~$156/year)

**Limitations:**
- ⚠️ 60 minutes/day compute time (app sleeps after)
- ⚠️ No custom domains
- ⚠️ No auto-scaling
- ⚠️ App sleeps after 20 min inactivity
- ⚠️ Slower startup (cold start)

**Best for:** Personal projects, demos, testing

**New Monthly Cost:** ~$20-23/month (~$240-276/year)

---

### **Option 3: GitHub Container Registry (Save ~$20/month)**
**Use GitHub's free container registry instead of Azure**

#### Benefits:
- ✅ **FREE** for public repositories
- ✅ 500 MB storage free for private repos
- ✅ Integrates perfectly with GitHub Actions

#### How to switch:

**Step 1: Update workflow to use GitHub Container Registry**
```yaml
env:
  CONTAINER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository_owner }}/abs-rules-extractor
  AZURE_WEBAPP_NAME: ABSRuleRed2
  RESOURCE_GROUP: LeiWang
  APP_SERVICE_PLAN: LeiWangNew

jobs:
  build-docker:
    steps:
    - name: Login to GitHub Container Registry
      uses: docker/login-action@v2
      with:
        registry: ghcr.io
        username: ${{ github.actor }}
        password: ${{ secrets.GITHUB_TOKEN }}
    
    - name: Build and push Docker image
      run: |
        docker build \
          -t ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:latest \
          -t ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:${{ github.sha }} \
          web_app
        docker push ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:latest
        docker push ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:${{ github.sha }}
```

**Step 2: Configure Azure to pull from GitHub**
```bash
# No authentication needed for public repos
az webapp config container set \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --container-image-name ghcr.io/YOUR-USERNAME/abs-rules-extractor:latest
```

**Savings:** ~$20/month (~$240/year)

**New Monthly Cost:** ~$13-16/month (~$156-192/year)

---

## 🏆 RECOMMENDED: Best Balance (Save ~$20/month)

### **Combination: GitHub Registry + Basic App Service**

**What to do:**
1. ✅ Switch to GitHub Container Registry (FREE)
2. ✅ Keep B1 App Service Plan (~$13/month)
3. ✅ Remove Azure Container Registry

**Total Cost:** **~$13-16/month (~$156-192/year)**

**You keep:**
- ✅ Always-on web app
- ✅ Good performance
- ✅ Custom domains
- ✅ Auto-scaling capability
- ✅ Professional setup

---

## 🚀 Step-by-Step: Implement Cost Savings

### **Phase 1: Switch to GitHub Container Registry**

1. **Update the workflow file:**
```yaml
# In .github/workflows/azure-deploy.yml
env:
  AZURE_WEBAPP_NAME: ABSRuleRed2
  RESOURCE_GROUP: LeiWang
  APP_SERVICE_PLAN: LeiWangNew
  CONTAINER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository_owner }}/abs-rules-extractor

# No need for ACR_USERNAME and ACR_PASSWORD secrets anymore
```

2. **Update GitHub Secrets:**
   - Remove: `ACR_USERNAME`, `ACR_PASSWORD`
   - Keep: `AZURE_CREDENTIALS`, `AZURE_SUBSCRIPTION_ID`, etc.

3. **Make your GitHub repository public** (or use GitHub Packages for free with public images)

4. **Push changes** - Next deployment will use GitHub Container Registry

5. **Delete Azure Container Registry** (after confirming everything works):
```bash
az acr delete --name redtextextractor --resource-group LeiWang
```

---

### **Phase 2: Optional - Use Shared App Service Plan**

If you have multiple apps, use one shared plan:
```bash
# Your current app uses: LeiWangNew (B1) = $13/month
# If you add more apps to the SAME plan = $0 extra!
```

---

## 💡 Additional Cost Savings Tips

### **1. Stop App During Off-Hours (Save ~30-50%)**
If your app doesn't need 24/7 availability:

```bash
# Stop app every night at 11 PM
az webapp stop --name ABSRuleRed2 --resource-group LeiWang

# Start app at 7 AM
az webapp start --name ABSRuleRed2 --resource-group LeiWang
```

Use Azure Automation or Logic Apps to schedule this.

**Savings:** ~$4-7/month

---

### **2. Use Azure Functions Instead (Pay-per-use)**
For truly minimal usage:

**Cost:** $0.20 per million executions + $0.016 per GB-second

**Best for:** 
- < 100 requests/day
- Sporadic usage
- Demo/testing only

**Monthly Cost:** ~$0-5/month

---

### **3. Delete Unused Resources**

Check what you're paying for:
```bash
# List all resources in your resource group
az resource list --resource-group LeiWang --output table

# Delete unused resources
az resource delete --ids /subscriptions/.../resourceId
```

---

### **4. Use Azure Reserved Instances (Save 30-40%)**
If you commit to 1 or 3 years:

**B1 Plan:**
- Pay-as-you-go: $13.14/month
- 1-year reserved: ~$8.50/month (35% savings)
- 3-year reserved: ~$6.80/month (48% savings)

Only worth it if you'll use it long-term.

---

### **5. Monitor and Set Budget Alerts**

```bash
# Create a budget alert
az consumption budget create \
  --budget-name abs-rules-budget \
  --category cost \
  --amount 20 \
  --time-grain monthly \
  --time-period start-date=2024-12-01 \
  --resource-group LeiWang
```

Get email alerts when spending exceeds $15, $18, $20.

---

## 📊 Cost Comparison Table

| Strategy | Monthly Cost | Annual Cost | Savings | Downside |
|----------|--------------|-------------|---------|----------|
| **Current** | $33-36 | $400-428 | - | None |
| **GitHub Registry + B1** | $13-16 | $156-192 | **$20/mo** | None |
| **GitHub Registry + F1 Free** | $0-3 | $0-36 | **$33/mo** | Usage limits |
| **Azure Functions** | $0-5 | $0-60 | **$28-36/mo** | Cold starts |
| **B1 + Reserved 1yr** | $8-11 | $96-132 | **$22-25/mo** | 1yr commitment |

---

## 🎯 My Recommendation for You

### **Best Option: GitHub Container Registry + Keep B1 App Service**

**Why:**
1. ✅ **Saves ~$20/month** ($240/year) - significant savings
2. ✅ **No functionality loss** - app works exactly the same
3. ✅ **Easy to implement** - just update workflow
4. ✅ **Professional setup** - still production-ready
5. ✅ **Better integration** - GitHub Registry works great with Actions

**New Cost: ~$13-16/month (~$156-192/year)**

That's **56% cheaper** than your current setup!

---

## 🔧 Implementation Commands

### **Quick Setup: Switch to GitHub Container Registry**

**Step 1: Update workflow environment variables**
```yaml
env:
  CONTAINER_REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository_owner }}/abs-rules-extractor
```

**Step 2: Update Docker login in workflow**
```yaml
- name: Login to GitHub Container Registry
  uses: docker/login-action@v2
  with:
    registry: ghcr.io
    username: ${{ github.actor }}
    password: ${{ secrets.GITHUB_TOKEN }}
```

**Step 3: Update image references**
```yaml
docker build -t ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:latest
docker push ghcr.io/${{ github.repository_owner }}/abs-rules-extractor:latest
```

**Step 4: Configure Azure Web App**
```bash
az webapp config container set \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --container-image-name ghcr.io/YOUR-USERNAME/abs-rules-extractor:latest
```

**Step 5: Delete Azure Container Registry**
```bash
# After confirming everything works
az acr delete --name redtextextractor --resource-group LeiWang --yes
```

---

## 📈 Long-term Optimization

### **Monitor Usage:**
```bash
# Check actual resource usage
az monitor metrics list \
  --resource /subscriptions/.../ABSRuleRed2 \
  --metric-names CPU,Memory \
  --start-time 2024-11-01 \
  --end-time 2024-12-01
```

### **Right-size based on actual usage:**
- If CPU < 20% → Can use Free tier
- If CPU 20-50% → B1 is perfect
- If CPU > 50% → Keep B1 or upgrade

---

## 💰 Final Cost Breakdown

### **After Optimization:**

| Resource | Tier | Monthly Cost |
|----------|------|--------------|
| App Service Plan | B1 | $13.14 |
| Container Registry | GitHub (FREE) | $0.00 |
| Storage | Minimal | $0.50 |
| Bandwidth | < 100GB | $0.00 |
| **TOTAL** | | **~$13.64/month** |

**Annual Cost:** ~$163.68/year

**Savings:** ~$264/year (62% reduction!)

---

## 🎉 Summary

**Current Cost:** ~$36/month  
**Optimized Cost:** ~$14/month  
**You Save:** ~$22/month ($264/year)

**What to do:**
1. Switch to GitHub Container Registry (20 minutes)
2. Test deployment
3. Delete Azure Container Registry
4. Enjoy 62% cost savings! 🎊

---

**Need help implementing? I can update the workflow file for you!**
