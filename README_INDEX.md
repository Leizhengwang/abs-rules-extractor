# 📚 Documentation Index - ABS Rules Red Text Extractor

**Last Updated:** December 2, 2025

---

## 🌐 Production Application

### **Live Application:**
```
https://absrulered2.azurewebsites.net
```

**Status:** ✅ Running  
**Current Cost:** $20/month (ACR only, web app is free)

---

## 📖 Documentation Guide

### **🚀 Getting Started**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[CURRENT_STATUS.md](CURRENT_STATUS.md)** | 📊 Complete current status overview | **START HERE** - Quick reference for everything |
| **[FINAL_PRODUCT.md](FINAL_PRODUCT.md)** | 🎉 Complete product overview & architecture | Understand what was built and how it works |
| **[HOW_TO_RUN_APP.md](HOW_TO_RUN_APP.md)** | 🚀 How to deploy/redeploy the app | When you need to deploy or restart from scratch |

---

### **🔧 Operations & Maintenance**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[STOP_RESTART_GUIDE.md](STOP_RESTART_GUIDE.md)** | ⏯️ Stop, start, restart commands | Daily operations - when app needs restart |
| **[CHECK_BACKEND_GUIDE.md](CHECK_BACKEND_GUIDE.md)** | 🔍 Backend monitoring & debugging | Troubleshooting - check logs, metrics, status |
| **[HEALTH_MONITORING_GUIDE.md](HEALTH_MONITORING_GUIDE.md)** | 🏥 Advanced monitoring setup | Set up Application Insights, alerts, dashboards |

---

### **💰 Cost Management**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[ACR_SETUP_COMPLETE.md](ACR_SETUP_COMPLETE.md)** | 📦 Container registry info ($20/month) | Understanding ACR costs and setup |
| **[COST_OPTIMIZATION.md](COST_OPTIMIZATION.md)** | 💡 How to reduce costs to $0/month | Want to save money - switch to free registry |
| **[F1_FREE_TIER_ANALYSIS.md](F1_FREE_TIER_ANALYSIS.md)** | 📊 Free tier limitations & benefits | Understanding F1 tier constraints |

---

### **📈 Scaling & Performance**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[AUTO_SCALING_GUIDE.md](AUTO_SCALING_GUIDE.md)** | 🔄 Auto-scaling configuration | Need to handle more traffic - upgrade tier |
| **[DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md)** | ✅ Recent deployment fixes & status | Understanding recent changes and fixes |

---

### **🛠️ Technical Documentation**

| Document | Purpose | When to Use |
|----------|---------|-------------|
| **[web_app/README.md](web_app/README.md)** | 📱 Application documentation | Understanding the Flask app code |
| **[web_app/AZURE_CICD_DEPLOYMENT.md](web_app/AZURE_CICD_DEPLOYMENT.md)** | 🔄 CI/CD deep dive | Detailed GitHub Actions workflow explanation |
| **[web_app/AZURE_CREDENTIALS_SETUP.md](web_app/AZURE_CREDENTIALS_SETUP.md)** | 🔐 Setting up Azure credentials | Initial Azure setup for GitHub Actions |
| **[web_app/GITHUB_SECRETS_GUIDE.md](web_app/GITHUB_SECRETS_GUIDE.md)** | 🔒 GitHub Secrets configuration | Managing secrets for CI/CD |

---

## 🎯 Common Tasks Quick Reference

### **Task: Check if App is Running**
1. Visit: https://absrulered2.azurewebsites.net
2. Or run: `curl -I https://absrulered2.azurewebsites.net`
3. See: [CHECK_BACKEND_GUIDE.md](CHECK_BACKEND_GUIDE.md)

---

### **Task: Restart the App**
```bash
az webapp restart --name ABSRuleRed2 --resource-group LeiWang
```
See: [STOP_RESTART_GUIDE.md](STOP_RESTART_GUIDE.md)

---

### **Task: View Live Logs**
```bash
az webapp log tail --name ABSRuleRed2 --resource-group LeiWang
```
Press `Ctrl+C` to exit.  
See: [CHECK_BACKEND_GUIDE.md](CHECK_BACKEND_GUIDE.md)

---

### **Task: Deploy New Version**
```bash
git add .
git commit -m "Your changes"
git push origin main
```
Wait 10-15 minutes for automatic deployment.  
See: [HOW_TO_RUN_APP.md](HOW_TO_RUN_APP.md)

---

### **Task: Reduce Monthly Cost to $0**
Follow the guide to switch to GitHub Container Registry:  
See: [COST_OPTIMIZATION.md](COST_OPTIMIZATION.md)

---

### **Task: Handle More Traffic**
Upgrade to Standard S1 tier for auto-scaling:  
See: [AUTO_SCALING_GUIDE.md](AUTO_SCALING_GUIDE.md)

---

### **Task: Set Up Advanced Monitoring**
Enable Application Insights:  
See: [HEALTH_MONITORING_GUIDE.md](HEALTH_MONITORING_GUIDE.md)

---

## 🔧 Helper Scripts

### **Interactive Control Menu**
```bash
./control-app.sh
```
Provides menu for: Start, Stop, Restart, Status, Health Check, Logs

### **Quick Health Check**
```bash
./check-backend.sh
```
Runs comprehensive health check of all components

---

## 📁 File Structure

```
subsection_extraction_app2/
├── 📘 Documentation (Root Level)
│   ├── CURRENT_STATUS.md          ⭐ Start here - complete overview
│   ├── FINAL_PRODUCT.md           🎉 What was built
│   ├── STOP_RESTART_GUIDE.md      ⏯️ Start/stop commands
│   ├── CHECK_BACKEND_GUIDE.md     🔍 Monitoring & debugging
│   ├── ACR_SETUP_COMPLETE.md      📦 Container registry info
│   ├── COST_OPTIMIZATION.md       💰 How to save money
│   ├── AUTO_SCALING_GUIDE.md      📈 Scaling configuration
│   ├── F1_FREE_TIER_ANALYSIS.md   📊 Free tier details
│   ├── HEALTH_MONITORING_GUIDE.md 🏥 Advanced monitoring
│   ├── HOW_TO_RUN_APP.md          🚀 Deployment guide
│   ├── DEPLOYMENT_STATUS.md       ✅ Recent fixes
│   └── README_INDEX.md            📚 This file
│
├── 🔧 Scripts
│   ├── control-app.sh             Interactive app control
│   └── check-backend.sh           Quick health check
│
├── ⚙️ CI/CD
│   └── .github/workflows/
│       └── azure-deploy.yml       GitHub Actions workflow
│
└── 📱 Application
    └── web_app/
        ├── app.py                 Flask application
        ├── Dockerfile             Container config
        ├── requirements.txt       Python dependencies
        ├── README.md              App documentation
        ├── AZURE_CICD_DEPLOYMENT.md  CI/CD details
        ├── AZURE_CREDENTIALS_SETUP.md Azure setup
        └── GITHUB_SECRETS_GUIDE.md    Secrets config
```

---

## 🎓 Learning Path

### **New to the Project?**
1. Read: [CURRENT_STATUS.md](CURRENT_STATUS.md) - Get overview
2. Read: [FINAL_PRODUCT.md](FINAL_PRODUCT.md) - Understand architecture
3. Try: Visit https://absrulered2.azurewebsites.net - Use the app
4. Explore: [web_app/README.md](web_app/README.md) - Understand code

### **Need to Operate the App?**
1. Use: `./control-app.sh` - Interactive control
2. Read: [STOP_RESTART_GUIDE.md](STOP_RESTART_GUIDE.md) - Basic operations
3. Read: [CHECK_BACKEND_GUIDE.md](CHECK_BACKEND_GUIDE.md) - Monitoring

### **Want to Deploy Changes?**
1. Read: [HOW_TO_RUN_APP.md](HOW_TO_RUN_APP.md) - Deployment process
2. Read: [web_app/AZURE_CICD_DEPLOYMENT.md](web_app/AZURE_CICD_DEPLOYMENT.md) - CI/CD details
3. Make changes and push to `main` branch

### **Need to Optimize?**
1. Cost: [COST_OPTIMIZATION.md](COST_OPTIMIZATION.md) - Save money
2. Performance: [AUTO_SCALING_GUIDE.md](AUTO_SCALING_GUIDE.md) - Scale up
3. Monitoring: [HEALTH_MONITORING_GUIDE.md](HEALTH_MONITORING_GUIDE.md) - Add insights

---

## 🔗 Important Links

### **Application**
- **Production:** https://absrulered2.azurewebsites.net
- **Azure Portal:** https://portal.azure.com → ABSRuleRed2
- **GitHub Repo:** https://github.com/Leizhengwang/abs-rules-extractor

### **Monitoring**
- **GitHub Actions:** https://github.com/Leizhengwang/abs-rules-extractor/actions
- **Azure App Service:** https://portal.azure.com → Resource Groups → LeiWang → ABSRuleRed2

### **Documentation**
- **Azure Docs:** https://docs.microsoft.com/azure/app-service
- **Flask Docs:** https://flask.palletsprojects.com
- **Docker Docs:** https://docs.docker.com

---

## ⚡ Quick Commands Cheat Sheet

```bash
# Check app status
az webapp show --name ABSRuleRed2 --resource-group LeiWang --query "{state:state,url:defaultHostName}" -o json

# Restart app
az webapp restart --name ABSRuleRed2 --resource-group LeiWang

# Stop app
az webapp stop --name ABSRuleRed2 --resource-group LeiWang

# Start app
az webapp start --name ABSRuleRed2 --resource-group LeiWang

# View logs (Ctrl+C to exit)
az webapp log tail --name ABSRuleRed2 --resource-group LeiWang

# Test app
curl -I https://absrulered2.azurewebsites.net

# Check container image
az webapp config show --name ABSRuleRed2 --resource-group LeiWang --query "linuxFxVersion" -o tsv

# List ACR images
az acr repository list --name redtextextractor

# Deploy new version
git add . && git commit -m "changes" && git push origin main
```

---

## 📊 Current Configuration Summary

| Setting | Value |
|---------|-------|
| **App Name** | ABSRuleRed2 |
| **URL** | https://absrulered2.azurewebsites.net |
| **Resource Group** | LeiWang |
| **App Service Plan** | LeiWangNew (F1 Free) |
| **Location** | Central US |
| **Container Registry** | redtextextractor.azurecr.io |
| **Runtime** | Python 3.9 in Docker |
| **Port** | 8000 |
| **Status** | ✅ Running |
| **Cost** | $20/month |

---

## 🆘 Getting Help

### **If Something Goes Wrong:**

1. **Check Status:**
   - Run: `./check-backend.sh`
   - Or read: [CHECK_BACKEND_GUIDE.md](CHECK_BACKEND_GUIDE.md)

2. **View Logs:**
   ```bash
   az webapp log tail --name ABSRuleRed2 --resource-group LeiWang
   ```

3. **Restart App:**
   ```bash
   az webapp restart --name ABSRuleRed2 --resource-group LeiWang
   ```

4. **Check GitHub Actions:**
   - https://github.com/Leizhengwang/abs-rules-extractor/actions

5. **Review Recent Changes:**
   - Read: [DEPLOYMENT_STATUS.md](DEPLOYMENT_STATUS.md)

---

## ✅ System Health Checklist

Use this to verify everything is working:

- [ ] App accessible at https://absrulered2.azurewebsites.net
- [ ] Returns HTTP 200 status code
- [ ] Can upload and process PDF files
- [ ] GitHub Actions workflow runs successfully
- [ ] Docker image exists in ACR
- [ ] Azure Web App status is "Running"
- [ ] Logs show no critical errors
- [ ] Response time < 500ms

---

## 🎉 Summary

You have a **production-ready, fully automated** web application with:

✅ **Live URL:** https://absrulered2.azurewebsites.net  
✅ **Auto-deployment** via GitHub Actions  
✅ **Comprehensive documentation** for all scenarios  
✅ **Cost-effective** at $20/month (can be $0)  
✅ **Helper scripts** for easy management  
✅ **Health monitoring** and logging  

**Everything you need is documented and automated!** 🚀

---

*Last Updated: December 2, 2025*
