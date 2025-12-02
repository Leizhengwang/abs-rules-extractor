# 🚀 How to Run/Restart Your Azure Web App

## 🎯 Current Situation

Your web app **ABSRuleRed2** has been deleted from Azure.

**Good news:** Your GitHub Actions workflow can automatically recreate it!

---

## 🔄 Ways to Run/Restart the App

### **Method 1: Automatic Deployment via GitHub (RECOMMENDED)**

This will automatically recreate and deploy your app:

```bash
cd /Users/leizhengwang/Desktop/subsection_extraction_app2

# Make a small change (or use --allow-empty)
git commit --allow-empty -m "Redeploy app"

# Push to GitHub
git push origin main
```

**What happens:**
1. ✅ GitHub Actions workflow runs automatically
2. ✅ Creates the Azure Web App (if it doesn't exist)
3. ✅ Builds Docker image
4. ✅ Deploys to Azure
5. ✅ App is live in ~10-15 minutes

**Time:** 10-15 minutes (fully automated)

---

### **Method 2: Manual Trigger via GitHub Actions**

Go to your GitHub repository and trigger the workflow manually:

1. Go to: https://github.com/YOUR-USERNAME/abs-rules-extractor/actions
2. Click on "Deploy to Azure" workflow
3. Click "Run workflow" dropdown
4. Click the green "Run workflow" button

**Time:** 10-15 minutes (fully automated)

---

### **Method 3: Recreate App Manually with Azure CLI**

```bash
# Step 1: Create the web app
az webapp create \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --plan LeiWangNew \
  --deployment-container-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest

# Step 2: Configure port
az webapp config appsettings set \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --settings WEBSITES_PORT=8000

# Step 3: Restart the app
az webapp restart \
  --name ABSRuleRed2 \
  --resource-group LeiWang

# Step 4: Get the URL
az webapp show \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "defaultHostName" -o tsv
```

**Time:** 2-3 minutes (manual)

---

### **Method 4: If App Already Exists - Just Restart It**

```bash
# Check if app exists
az webapp list --resource-group LeiWang --query "[].name" -o table

# If it exists, restart it
az webapp restart --name ABSRuleRed2 --resource-group LeiWang

# Check status
az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "{name:name,state:state,url:defaultHostName}" -o json
```

**Time:** 30 seconds

---

### **Method 5: Start a Stopped App**

```bash
# Start the app if it's stopped
az webapp start --name ABSRuleRed2 --resource-group LeiWang
```

**Time:** 10 seconds

---

## 🎯 QUICKEST WAY TO RUN YOUR APP NOW

Since your app is deleted, here's the fastest way:

### **Option A: Use GitHub Actions (Recommended)**

```bash
cd /Users/leizhengwang/Desktop/subsection_extraction_app2
git commit --allow-empty -m "Recreate and deploy app"
git push origin main
```

Then wait 10-15 minutes and your app will be live!

### **Option B: Manual Recreation (Fastest - 2 minutes)**

Run these commands:

```bash
# Create the app
az webapp create \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --plan LeiWangNew \
  --deployment-container-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest

# Configure and restart
az webapp config appsettings set \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --settings WEBSITES_PORT=8000

az webapp restart --name ABSRuleRed2 --resource-group LeiWang

# Get your URL
echo "Your app will be available at:"
az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "defaultHostName" -o tsv
```

---

## 📊 Common Scenarios

### **Scenario 1: App is Running but Not Responding**
```bash
# Restart the app
az webapp restart --name ABSRuleRed2 --resource-group LeiWang

# Check logs
az webapp log tail --name ABSRuleRed2 --resource-group LeiWang
```

### **Scenario 2: App is Stopped (F1 Free Tier)**
```bash
# The app auto-stops after 20 min on F1 tier
# First visitor will wake it up (10 sec delay)
# Or manually start it:
az webapp start --name ABSRuleRed2 --resource-group LeiWang
```

### **Scenario 3: App Doesn't Exist (Like Now)**
```bash
# Option 1: Push to GitHub (automatic recreation)
git commit --allow-empty -m "Deploy app"
git push origin main

# Option 2: Create manually (see Method 3 above)
```

### **Scenario 4: Need to Deploy New Code**
```bash
# Just push to GitHub - fully automated!
git add .
git commit -m "Update app"
git push origin main
```

---

## 🔍 How to Check App Status

```bash
# Check if app exists
az webapp list --resource-group LeiWang --output table

# Check app state
az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "{name:name,state:state,url:defaultHostName}" -o json

# Check logs
az webapp log tail --name ABSRuleRed2 --resource-group LeiWang

# Test if app is accessible
curl -I https://$(az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "defaultHostName" -o tsv)
```

---

## 💡 Understanding F1 Free Tier Behavior

Since you're on F1 (Free) tier, understand this:

### **App Lifecycle:**
```
1. App is created → Running
2. No traffic for 20 minutes → App sleeps
3. First request arrives → App wakes up (10-15 sec delay)
4. App stays awake → Handles requests fast
5. No traffic for 20 minutes → App sleeps again
```

### **This is Normal on F1:**
- ✅ App "sleeps" after inactivity
- ✅ First request wakes it up
- ✅ Free tier = some delays acceptable

### **To Keep App Always Awake (Costs Money):**
```bash
# Upgrade to B1 ($13/month)
az appservice plan update --name LeiWangNew --resource-group LeiWang --sku B1

# Enable "Always On"
az webapp config set --name ABSRuleRed2 --resource-group LeiWang --always-on true
```

---

## 🎯 WHAT TO DO RIGHT NOW

### **Quick Start (Choose One):**

**Method A: Automatic (10-15 min, fully automated)**
```bash
cd /Users/leizhengwang/Desktop/subsection_extraction_app2
git commit --allow-empty -m "Redeploy app"
git push origin main
```

**Method B: Manual (2-3 min, quick)**
```bash
az webapp create \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --plan LeiWangNew \
  --deployment-container-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest

az webapp config appsettings set \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --settings WEBSITES_PORT=8000

az webapp restart --name ABSRuleRed2 --resource-group LeiWang
```

---

## 📞 Get Help

If the app doesn't start, check:
1. App Service Plan exists and is Free: `az appservice plan show --name LeiWangNew --resource-group LeiWang`
2. Container image exists: `az acr repository show --name redtextextractor --repository abs-rules-extractor`
3. Logs for errors: `az webapp log tail --name ABSRuleRed2 --resource-group LeiWang`

---

**Want me to recreate the app for you right now?** Just say "yes"!
