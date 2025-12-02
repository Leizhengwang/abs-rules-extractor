# Stop and Restart Azure Web App Guide

## Quick Commands

### Restart App (Most Common)
```bash
az webapp restart --name ABSRuleRed2 --resource-group LeiWang
```

### Stop App
```bash
az webapp stop --name ABSRuleRed2 --resource-group LeiWang
```

### Start App
```bash
az webapp start --name ABSRuleRed2 --resource-group LeiWang
```

### Check App Status
```bash
az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "{state:state,url:defaultHostName}" -o json
```

---

## Interactive Control Script

Run the interactive menu:
```bash
./control-app.sh
```

This provides a menu with options to:
1. ▶️  Start App
2. ⏸️  Stop App  
3. 🔄 Restart App
4. 📊 Check Status
5. 🏥 Health Check
6. 📋 View Logs

---

## When to Use Each Command

### 🔄 **Restart** (Most Common)
**Use when:**
- App is running but behaving incorrectly
- After deploying new code
- After changing app settings
- App is slow or unresponsive
- Container needs to reload

**Command:**
```bash
az webapp restart -n ABSRuleRed2 -g LeiWang
```

**What it does:**
- Stops the container
- Starts it again immediately
- Pulls latest image from registry
- Reloads all settings
- Takes 10-30 seconds

---

### ⏸️  **Stop**
**Use when:**
- Need to save costs (stops billing for compute)
- Performing maintenance
- Troubleshooting issues
- Need to make multiple config changes

**Command:**
```bash
az webapp stop -n ABSRuleRed2 -g LeiWang
```

**What it does:**
- Stops the container completely
- App becomes inaccessible
- Doesn't delete data or settings
- Can start again anytime

**Note:** On F1 (Free) tier, stopping doesn't save money since it's already free!

---

### ▶️  **Start**
**Use when:**
- App was previously stopped
- After performing maintenance
- Ready to serve traffic again

**Command:**
```bash
az webapp start -n ABSRuleRed2 -g LeiWang
```

**What it does:**
- Starts the stopped container
- Pulls image from registry
- Makes app accessible again
- Takes 10-30 seconds (longer on first start)

---

## Detailed Examples

### Example 1: Basic Restart
```bash
# Restart the app
az webapp restart -n ABSRuleRed2 -g LeiWang

# Wait 15 seconds
sleep 15

# Test if it's working
curl -I https://absrulered2.azurewebsites.net
```

### Example 2: Stop and Start
```bash
# Stop the app
az webapp stop -n ABSRuleRed2 -g LeiWang
echo "App stopped. Performing maintenance..."

# Do maintenance work here
# ...

# Start the app
az webapp start -n ABSRuleRed2 -g LeiWang
echo "App started. Testing..."

# Test
curl https://absrulered2.azurewebsites.net
```

### Example 3: Restart with Verification
```bash
#!/bin/bash

echo "🔄 Restarting app..."
az webapp restart -n ABSRuleRed2 -g LeiWang

echo "⏳ Waiting 20 seconds for app to start..."
sleep 20

echo "🏥 Running health check..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://absrulered2.azurewebsites.net)

if [ "$HTTP_CODE" = "200" ]; then
    echo "✅ App restarted successfully and is healthy!"
else
    echo "❌ App returned HTTP $HTTP_CODE"
    echo "📋 Checking logs..."
    az webapp log tail -n ABSRuleRed2 -g LeiWang
fi
```

---

## Via Azure Portal (GUI Method)

### Restart via Portal
1. Go to https://portal.azure.com
2. Navigate to **App Services** → **ABSRuleRed2**
3. Click **Restart** button at the top
4. Confirm the restart
5. Wait for "Restarting..." status to complete

### Stop via Portal
1. Go to Azure Portal → App Services → ABSRuleRed2
2. Click **Stop** button at the top
3. Confirm
4. Status will show "Stopped"

### Start via Portal
1. Go to Azure Portal → App Services → ABSRuleRed2
2. Click **Start** button at the top
3. Confirm
4. Wait for status to show "Running"

---

## Restart After Changes

### After Deploying New Code
```bash
# Deploy happens automatically via GitHub Actions
# But if you need to manually restart:

az webapp restart -n ABSRuleRed2 -g LeiWang
```

### After Changing App Settings
```bash
# Change a setting
az webapp config appsettings set \
  -n ABSRuleRed2 \
  -g LeiWang \
  --settings NEW_SETTING=value

# Restart to apply
az webapp restart -n ABSRuleRed2 -g LeiWang
```

### After Updating Container Image
```bash
# Update the container image
az webapp config container set \
  -n ABSRuleRed2 \
  -g LeiWang \
  --docker-custom-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest

# Restart to pull new image
az webapp restart -n ABSRuleRed2 -g LeiWang
```

---

## Monitoring During Restart

### Watch Logs During Restart
```bash
# Start streaming logs in one terminal
az webapp log tail -n ABSRuleRed2 -g LeiWang

# In another terminal, restart
az webapp restart -n ABSRuleRed2 -g LeiWang

# Watch the logs to see:
# - Container stopping
# - Container starting
# - Application initialization
# - First requests
```

### Check Status After Restart
```bash
# Restart
az webapp restart -n ABSRuleRed2 -g LeiWang

# Wait a bit
sleep 10

# Check status
az webapp show \
  -n ABSRuleRed2 \
  -g LeiWang \
  --query "{state:state,availabilityState:availabilityState}" \
  -o json

# Should show:
# {
#   "state": "Running",
#   "availabilityState": "Normal"
# }
```

---

## Troubleshooting

### App Won't Restart
```bash
# Check if there's an issue
az webapp show -n ABSRuleRed2 -g LeiWang --query "state" -o tsv

# Try stopping, then starting
az webapp stop -n ABSRuleRed2 -g LeiWang
sleep 5
az webapp start -n ABSRuleRed2 -g LeiWang

# Check logs for errors
az webapp log tail -n ABSRuleRed2 -g LeiWang
```

### App Stuck in "Starting" State
```bash
# Check container logs
az webapp log tail -n ABSRuleRed2 -g LeiWang | grep -i error

# Verify container image exists
az acr repository show \
  -n redtextextractor \
  --repository abs-rules-extractor

# Try recreating the container config
az webapp config container set \
  -n ABSRuleRed2 \
  -g LeiWang \
  --docker-custom-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest
```

### App Returns 503 After Restart
```bash
# Common on F1 tier - cold start delay
# Wait longer
sleep 30

# Try again
curl -I https://absrulered2.azurewebsites.net

# If still failing, check port setting
az webapp config appsettings list \
  -n ABSRuleRed2 \
  -g LeiWang \
  --query "[?name=='WEBSITES_PORT']"

# Should be 8000
```

---

## Scheduled Restart (Advanced)

### Using Azure Automation (Optional)
```bash
# Create a scheduled restart using Azure Automation
# This is advanced and requires Azure Automation account

# Manual cron alternative: use GitHub Actions
# Add to .github/workflows/scheduled-restart.yml:

# name: Scheduled Restart
# on:
#   schedule:
#     - cron: '0 2 * * 0'  # Every Sunday at 2 AM
# jobs:
#   restart:
#     runs-on: ubuntu-latest
#     steps:
#       - uses: azure/login@v1
#         with:
#           creds: ${{ secrets.AZURE_CREDENTIALS }}
#       - run: az webapp restart -n ABSRuleRed2 -g LeiWang
```

---

## Summary - Quick Reference

| Action | Command | When to Use |
|--------|---------|-------------|
| **Restart** | `az webapp restart -n ABSRuleRed2 -g LeiWang` | App issues, new deployment, slow performance |
| **Stop** | `az webapp stop -n ABSRuleRed2 -g LeiWang` | Maintenance, troubleshooting |
| **Start** | `az webapp start -n ABSRuleRed2 -g LeiWang` | After stopping |
| **Status** | `az webapp show -n ABSRuleRed2 -g LeiWang` | Check current state |
| **Logs** | `az webapp log tail -n ABSRuleRed2 -g LeiWang` | Debug issues |

---

## Best Practices

1. **Always wait 10-20 seconds** after restart before testing
2. **Check logs** if restart doesn't fix the issue
3. **Restart during low-traffic times** if possible
4. **Monitor metrics** after restart to ensure everything is normal
5. **Don't restart repeatedly** - if it fails twice, investigate the root cause

---

## Need Help?

- **View logs:** `az webapp log tail -n ABSRuleRed2 -g LeiWang`
- **Check status:** `./check-backend.sh`
- **Full control:** `./control-app.sh`
- **Azure Portal:** https://portal.azure.com → ABSRuleRed2

---

**Created:** December 2, 2025
**App:** ABSRuleRed2
**Resource Group:** LeiWang
**URL:** https://absrulered2.azurewebsites.net
