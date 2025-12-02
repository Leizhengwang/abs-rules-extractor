# How to Check Backend After Deployment

## Quick Access Links

**Production URL:** https://absrulered2.azurewebsites.net

**Azure Portal:** https://portal.azure.com → App Services → ABSRuleRed2

**GitHub Actions:** https://github.com/Leizhengwang/abs-rules-extractor/actions

---

## 1. Check if App is Running

### Method 1: Simple Browser Test
```bash
# Open in browser
https://absrulered2.azurewebsites.net
```

### Method 2: Command Line Check
```bash
# Check if app responds
curl -I https://absrulered2.azurewebsites.net

# Expected output:
# HTTP/2 200
# content-type: text/html; charset=utf-8
# ...
```

### Method 3: Health Check Endpoint
```bash
# If you add /health endpoint to app.py
curl https://absrulered2.azurewebsites.net/health

# Expected: {"status": "healthy", ...}
```

---

## 2. Check App Logs (Real-time)

### Method 1: Stream Logs via Azure CLI
```bash
# Stream live logs
az webapp log tail \
  --name ABSRuleRed2 \
  --resource-group LeiWang

# This shows real-time logs from your Flask app
```

### Method 2: Azure Portal Logs
1. Go to https://portal.azure.com
2. Navigate to **App Services** → **ABSRuleRed2**
3. In left menu, go to **Monitoring** → **Log stream**
4. See real-time logs

### Method 3: Download Historical Logs
```bash
# Download all logs as ZIP
az webapp log download \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --log-file webapp-logs.zip

# Extract and view
unzip webapp-logs.zip
cat LogFiles/*/default_docker.log
```

---

## 3. Check Container Status

### Check Running Container
```bash
# Get container details
az webapp show \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "{state:state,hostName:defaultHostName,containerImage:siteConfig.linuxFxVersion}" \
  -o json
```

### Check Container Image
```bash
# See which Docker image is deployed
az webapp config show \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "linuxFxVersion" \
  -o tsv

# Expected: DOCKER|redtextextractor.azurecr.io/abs-rules-extractor:latest
```

### Check Container Settings
```bash
# View all app settings
az webapp config appsettings list \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  -o table
```

---

## 4. Check Application Performance

### Method 1: Response Time Test
```bash
# Test response time
time curl -s https://absrulered2.azurewebsites.net > /dev/null

# Or detailed timing
curl -w "\nDNS: %{time_namelookup}s\nConnect: %{time_connect}s\nTTFB: %{time_starttransfer}s\nTotal: %{time_total}s\n" \
  -o /dev/null -s https://absrulered2.azurewebsites.net
```

### Method 2: Load Test
```bash
# Simple load test (10 requests)
for i in {1..10}; do
  curl -w "Request $i: %{http_code} - %{time_total}s\n" \
    -o /dev/null -s https://absrulered2.azurewebsites.net
  sleep 1
done
```

---

## 5. Check Backend Metrics

### CPU and Memory Usage
```bash
# Get CPU usage (last 1 hour)
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWang/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "CpuPercentage" \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --interval PT1M \
  --aggregation Average \
  -o table

# Get memory usage
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWang/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "MemoryPercentage" \
  --interval PT5M \
  --aggregation Average \
  -o table
```

### Request Statistics
```bash
# Get request count (last 1 hour)
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWang/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "Requests" \
  --interval PT5M \
  --aggregation Total \
  -o table

# Get HTTP errors
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWang/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "Http5xx" \
  --interval PT5M \
  --aggregation Total \
  -o table
```

---

## 6. Check Docker Container Registry

### Verify Image in ACR
```bash
# List images in ACR
az acr repository list \
  --name redtextextractor \
  -o table

# Show image tags
az acr repository show-tags \
  --name redtextextractor \
  --repository abs-rules-extractor \
  -o table

# Expected output:
# Result
# --------
# latest
# <git-sha>
```

### Check Image Details
```bash
# Get image manifest
az acr repository show \
  --name redtextextractor \
  --repository abs-rules-extractor \
  --query "{name:name,tags:tags,created:createdTime}" \
  -o json
```

---

## 7. Verify App Configuration

### Check Environment Variables
```bash
# List all environment variables
az webapp config appsettings list \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "[].{Name:name, Value:value}" \
  -o table

# Should include:
# - WEBSITES_PORT=8000
# - DOCKER_REGISTRY_SERVER_URL
# - DOCKER_REGISTRY_SERVER_USERNAME
```

### Check Container Settings
```bash
# Get detailed container config
az webapp config show \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "{linuxFxVersion:linuxFxVersion,alwaysOn:alwaysOn,httpLoggingEnabled:httpLoggingEnabled}" \
  -o json
```

---

## 8. Test Backend Functionality

### Test File Upload Endpoint
```bash
# Test with a sample PDF (if you have one)
curl -X POST \
  -F "file=@sample.pdf" \
  https://absrulered2.azurewebsites.net/upload

# Expected: File upload response or extracted text
```

### Test All Routes
```bash
# Test home page
curl https://absrulered2.azurewebsites.net/

# Test health endpoint (if exists)
curl https://absrulered2.azurewebsites.net/health

# Test static files
curl -I https://absrulered2.azurewebsites.net/static/style.css
```

---

## 9. Debug Common Issues

### Issue 1: App Shows "Application Error"
```bash
# Check app state
az webapp show \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --query "{state:state,availabilityState:availabilityState}" \
  -o json

# Check logs
az webapp log tail -n ABSRuleRed2 -g LeiWang

# Restart app
az webapp restart -n ABSRuleRed2 -g LeiWang
```

### Issue 2: Container Not Pulling
```bash
# Check container logs
az webapp log tail -n ABSRuleRed2 -g LeiWang | grep -i docker

# Verify ACR credentials
az webapp config appsettings list \
  -n ABSRuleRed2 \
  -g LeiWang \
  --query "[?contains(name, 'DOCKER')]"

# Test ACR login manually
az acr login --name redtextextractor
```

### Issue 3: Slow Response
```bash
# Check if app is in free tier (cold start)
az appservice plan show \
  --name LeiWangNew \
  --resource-group LeiWang \
  --query "sku.name" \
  -o tsv

# F1 (Free) tier has cold start delays
# First request may take 30+ seconds
```

### Issue 4: Port Not Configured
```bash
# Verify WEBSITES_PORT is set
az webapp config appsettings list \
  -n ABSRuleRed2 \
  -g LeiWang \
  --query "[?name=='WEBSITES_PORT'].value" \
  -o tsv

# Should return: 8000

# If not set, configure it
az webapp config appsettings set \
  -n ABSRuleRed2 \
  -g LeiWang \
  --settings WEBSITES_PORT=8000
```

---

## 10. Monitor via Azure Portal

### Real-time Monitoring Dashboard

1. **Go to Azure Portal:** https://portal.azure.com
2. **Navigate to:** App Services → ABSRuleRed2
3. **Check these sections:**

#### Overview Page
- **Status:** Should be "Running"
- **URL:** Click to test
- **Metrics:** Quick view of requests, errors

#### Monitoring Section
- **Metrics:** CPU, Memory, Response time graphs
- **Log stream:** Real-time logs
- **Diagnose and solve problems:** Automated diagnostics

#### Deployment Section
- **Deployment Center:** Shows connected GitHub repo
- **Deployment slots:** For staging/production (not available on F1)

#### Settings Section
- **Configuration:** Environment variables
- **Scale up/out:** Change tier or add instances

---

## 11. Advanced Diagnostics

### Enable Diagnostic Logging
```bash
# Enable all logging
az webapp log config \
  --name ABSRuleRed2 \
  --resource-group LeiWang \
  --application-logging filesystem \
  --detailed-error-messages true \
  --failed-request-tracing true \
  --web-server-logging filesystem

# Now logs will have more detail
```

### SSH into Container (if needed)
```bash
# F1 tier doesn't support SSH, but you can enable it on higher tiers

# For debugging, check startup logs
az webapp log tail -n ABSRuleRed2 -g LeiWang | grep -i "starting\|error\|warning"
```

---

## 12. Quick Health Check Script

Create a script to check everything:

```bash
#!/bin/bash

# health-check.sh - Quick backend health check

echo "🏥 ABS Rules Red Text Extractor - Health Check"
echo "================================================"
echo ""

# 1. Check app status
echo "1️⃣  Checking app status..."
STATUS=$(az webapp show -n ABSRuleRed2 -g LeiWang --query "state" -o tsv)
echo "   Status: $STATUS"
echo ""

# 2. Test HTTP response
echo "2️⃣  Testing HTTP endpoint..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://absrulered2.azurewebsites.net)
echo "   HTTP Code: $HTTP_CODE"
if [ "$HTTP_CODE" = "200" ]; then
  echo "   ✅ App is responding"
else
  echo "   ❌ App returned $HTTP_CODE"
fi
echo ""

# 3. Check container image
echo "3️⃣  Checking container image..."
IMAGE=$(az webapp config show -n ABSRuleRed2 -g LeiWang --query "linuxFxVersion" -o tsv)
echo "   Image: $IMAGE"
echo ""

# 4. Check CPU/Memory
echo "4️⃣  Checking resource usage..."
CPU=$(az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWang/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "CpuPercentage" \
  --start-time $(date -u -d '5 minutes ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --interval PT1M \
  --aggregation Average \
  --query "value[0].timeseries[0].data[-1].average" \
  -o tsv 2>/dev/null || echo "N/A")
echo "   CPU: ${CPU}%"
echo ""

# 5. Check recent logs for errors
echo "5️⃣  Checking for recent errors..."
echo "   (Streaming last 50 lines of logs...)"
az webapp log download -n ABSRuleRed2 -g LeiWang --log-file temp-logs.zip 2>/dev/null
if [ -f temp-logs.zip ]; then
  unzip -q temp-logs.zip
  tail -50 LogFiles/*/default_docker.log 2>/dev/null | grep -i "error\|warning\|exception" || echo "   ✅ No errors found"
  rm -rf temp-logs.zip LogFiles
else
  echo "   ⚠️  Could not download logs"
fi
echo ""

echo "================================================"
echo "✅ Health check complete!"
```

Save and run:
```bash
chmod +x health-check.sh
./health-check.sh
```

---

## Summary - Quick Commands

```bash
# 1. Check if app is running
curl -I https://absrulered2.azurewebsites.net

# 2. View live logs
az webapp log tail -n ABSRuleRed2 -g LeiWang

# 3. Check app status
az webapp show -n ABSRuleRed2 -g LeiWang --query "{state:state,url:defaultHostName}" -o json

# 4. Restart app (if needed)
az webapp restart -n ABSRuleRed2 -g LeiWang

# 5. Check container image
az webapp config show -n ABSRuleRed2 -g LeiWang --query "linuxFxVersion" -o tsv

# 6. View app settings
az webapp config appsettings list -n ABSRuleRed2 -g LeiWang -o table

# 7. Download logs
az webapp log download -n ABSRuleRed2 -g LeiWang --log-file logs.zip
```

---

## Access Points

| What | URL/Command |
|------|-------------|
| **Production App** | https://absrulered2.azurewebsites.net |
| **Azure Portal** | https://portal.azure.com → ABSRuleRed2 |
| **GitHub Actions** | https://github.com/Leizhengwang/abs-rules-extractor/actions |
| **Live Logs** | `az webapp log tail -n ABSRuleRed2 -g LeiWang` |
| **ACR Images** | `az acr repository list -n redtextextractor` |

---

**Next:** Once deployed, bookmark the production URL and set up monitoring alerts!
