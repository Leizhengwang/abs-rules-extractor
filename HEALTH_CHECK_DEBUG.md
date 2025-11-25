# 🚨 Health Check Failure Diagnostic Guide

## **Current Issue: Health Check Failed**

Your GitHub Actions deployment is failing at the health check step. This means:
- ✅ Docker image built successfully
- ✅ Image pushed to Azure Container Registry  
- ✅ Azure Web App deployment command completed
- ❌ **The web app is not responding at https://ABSRuleRed.azurewebsites.net/**

## **🔍 Troubleshooting Steps:**

### **1. Check Azure Web App Status**
```bash
az webapp show --name ABSRuleRed --resource-group LeiWang --query "{state:state,hostNames:defaultHostName}"
```

### **2. Check Azure Web App Logs**
```bash
az webapp log download --name ABSRuleRed --resource-group LeiWang
```

### **3. Verify Container Configuration**
```bash
az webapp config container show --name ABSRuleRed --resource-group LeiWang
```

## **🐛 Common Causes & Solutions:**

### **A. Azure Web App Doesn't Exist**
**Problem**: The web app `ABSRuleRed` doesn't exist in Azure Portal
**Solution**: Create the Azure Web App first
```bash
az webapp create \
  --name ABSRuleRed \
  --resource-group LeiWang \
  --plan YOUR_APP_SERVICE_PLAN \
  --deployment-container-image-name redtextextractor.azurecr.io/abs-rules-extractor:latest
```

### **B. Container Not Starting** 
**Problem**: Docker container fails to start
**Solution**: Check if your Flask app runs properly
```bash
# Test locally
cd web_app
python app.py
```

### **C. Wrong Port Configuration**
**Problem**: Azure expects app on port 80, but Flask runs on 5000
**Solution**: Update Dockerfile to expose port 80
```dockerfile
EXPOSE 80
CMD ["python", "app.py", "--host", "0.0.0.0", "--port", "80"]
```

### **D. Container Registry Access Issues**
**Problem**: Azure can't pull the Docker image
**Solution**: Check ACR credentials and permissions

### **E. App Takes Too Long to Start**
**Problem**: App needs more than 60 seconds to start
**Solution**: Increase wait time in health check

## **🔧 Immediate Fixes to Try:**

### **Fix 1: Update Health Check Timing**
The current health check waits 60 seconds then tries 10 times with 30-second intervals.
Let's increase the initial wait time:

### **Fix 2: Add Better Health Check Endpoint**
Instead of checking the main page, create a simple health endpoint:

### **Fix 3: Check Container Logs**
Add a step to show container logs before health check:

### **Fix 4: Verify Azure Web App Exists**
Add a step to verify the web app exists before deploying:

## **📊 Quick Diagnostic Commands:**

Run these in Azure CLI to diagnose:

```bash
# 1. Check if web app exists
az webapp list --resource-group LeiWang --query "[].{name:name,state:state}" -o table

# 2. Check web app state
az webapp show --name ABSRuleRed --resource-group LeiWang --query "{state:state,availabilityState:availabilityState}"

# 3. Check container logs
az webapp log tail --name ABSRuleRed --resource-group LeiWang

# 4. Test the URL manually
curl -I https://ABSRuleRed.azurewebsites.net/

# 5. Check container registry
az acr repository list --name redtextextractor
```

## **🎯 Next Steps:**
1. **Check Azure Portal**: Verify `ABSRuleRed` web app exists in `LeiWang` resource group
2. **Review Logs**: Look at container logs in Azure Portal
3. **Test Locally**: Ensure your Flask app works locally on port 80
4. **Fix Port Issue**: Most likely cause is port configuration
5. **Update Workflow**: Apply one of the fixes above

Would you like me to implement any of these fixes to the workflow?
