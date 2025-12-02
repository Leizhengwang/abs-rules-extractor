# Auto-Scaling Configuration for Azure Web App

## Overview
This guide covers auto-scaling configuration for the ABS Rules Red Text Extractor web application on Azure App Service.

## Current Limitations with F1 (Free) Tier

⚠️ **IMPORTANT**: The F1 (Free) tier does **NOT** support auto-scaling. Auto-scaling is only available on:
- **Basic (B1, B2, B3)** - Manual scaling only (scale out to multiple instances)
- **Standard (S1, S2, S3)** - Auto-scaling based on metrics
- **Premium (P1v2, P2v2, P3v2, P1v3, P2v3, P3v3)** - Advanced auto-scaling with more features

## Cost vs Features Comparison

| Tier | Monthly Cost | Auto-Scaling | Max Instances | Use Case |
|------|--------------|--------------|---------------|----------|
| F1 (Free) | $0 | ❌ No | 1 (shared) | Development/Testing |
| B1 (Basic) | ~$13 | ⚠️ Manual only | 3 | Small production apps |
| S1 (Standard) | ~$70 | ✅ Yes | 10 | Production with auto-scaling |
| P1v3 (Premium) | ~$100+ | ✅ Advanced | 30 | High-performance production |

## Auto-Scaling Options

### Option 1: Upgrade to Standard (S1) Tier - RECOMMENDED for Auto-Scaling

```bash
# Upgrade App Service Plan to Standard S1
az appservice plan update \
  --name LeiWangNew \
  --resource-group LeiWangNewAppRG \
  --sku S1

# Cost: ~$70/month
# Features:
# - Auto-scaling based on CPU, memory, HTTP queue
# - Up to 10 instances
# - Custom domains with SSL
# - Staging slots
# - Daily backups
```

### Option 2: Use Basic (B1) Tier - Manual Scaling Only

```bash
# Upgrade to Basic B1 (already on F1, so this is an upgrade)
az appservice plan update \
  --name LeiWangNew \
  --resource-group LeiWangNewAppRG \
  --sku B1

# Cost: ~$13/month
# Features:
# - Manual scale out to 3 instances
# - Custom domains with SSL
# - NO automatic scaling
```

### Option 3: Stay on F1 - No Scaling

- Current tier: F1 (Free)
- Cost: $0
- Scaling: None available
- Best for: Development, testing, demos

## Configuring Auto-Scaling (Standard Tier Only)

### 1. Via Azure Portal

1. Go to Azure Portal → App Services → ABSRuleRed2
2. Navigate to **Scale out (App Service plan)**
3. Select **Custom autoscale**
4. Configure rules based on:
   - CPU percentage
   - Memory percentage
   - HTTP queue length
   - Custom metrics

### 2. Via Azure CLI

```bash
# Create autoscale setting
az monitor autoscale create \
  --resource-group LeiWangNewAppRG \
  --resource ABSRuleRed2 \
  --resource-type Microsoft.Web/serverfarms \
  --name ABSRuleRed2-autoscale \
  --min-count 1 \
  --max-count 5 \
  --count 1

# Add CPU-based scale-out rule (scale out when CPU > 70%)
az monitor autoscale rule create \
  --resource-group LeiWangNewAppRG \
  --autoscale-name ABSRuleRed2-autoscale \
  --condition "Percentage CPU > 70 avg 5m" \
  --scale out 1

# Add CPU-based scale-in rule (scale in when CPU < 30%)
az monitor autoscale rule create \
  --resource-group LeiWangNewAppRG \
  --autoscale-name ABSRuleRed2-autoscale \
  --condition "Percentage CPU < 30 avg 5m" \
  --scale in 1

# Add memory-based scale-out rule (scale out when Memory > 75%)
az monitor autoscale rule create \
  --resource-group LeiWangNewAppRG \
  --autoscale-name ABSRuleRed2-autoscale \
  --condition "Memory Percentage > 75 avg 5m" \
  --scale out 1

# Add HTTP queue-based scale-out rule (scale out when queue > 100)
az monitor autoscale rule create \
  --resource-group LeiWangNewAppRG \
  --autoscale-name ABSRuleRed2-autoscale \
  --condition "Http Queue Length > 100 avg 1m" \
  --scale out 2
```

### 3. Via ARM Template (Infrastructure as Code)

```json
{
  "type": "Microsoft.Insights/autoscaleSettings",
  "apiVersion": "2015-04-01",
  "name": "ABSRuleRed2-autoscale",
  "location": "[resourceGroup().location]",
  "properties": {
    "profiles": [
      {
        "name": "Default autoscale profile",
        "capacity": {
          "minimum": "1",
          "maximum": "5",
          "default": "1"
        },
        "rules": [
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "metricResourceUri": "[resourceId('Microsoft.Web/serverfarms', 'LeiWangNew')]",
              "timeGrain": "PT1M",
              "statistic": "Average",
              "timeWindow": "PT5M",
              "timeAggregation": "Average",
              "operator": "GreaterThan",
              "threshold": 70
            },
            "scaleAction": {
              "direction": "Increase",
              "type": "ChangeCount",
              "value": "1",
              "cooldown": "PT5M"
            }
          },
          {
            "metricTrigger": {
              "metricName": "CpuPercentage",
              "metricResourceUri": "[resourceId('Microsoft.Web/serverfarms', 'LeiWangNew')]",
              "timeGrain": "PT1M",
              "statistic": "Average",
              "timeWindow": "PT5M",
              "timeAggregation": "Average",
              "operator": "LessThan",
              "threshold": 30
            },
            "scaleAction": {
              "direction": "Decrease",
              "type": "ChangeCount",
              "value": "1",
              "cooldown": "PT5M"
            }
          }
        ]
      }
    ],
    "enabled": true,
    "targetResourceUri": "[resourceId('Microsoft.Web/serverfarms', 'LeiWangNew')]"
  }
}
```

## Recommended Auto-Scaling Rules for This Application

Based on the PDF processing nature of your application:

### Rule Set 1: CPU-Based Scaling (Primary)
- **Scale Out**: CPU > 70% for 5 minutes → Add 1 instance
- **Scale In**: CPU < 30% for 10 minutes → Remove 1 instance
- **Min Instances**: 1
- **Max Instances**: 5
- **Cooldown**: 5 minutes

### Rule Set 2: Memory-Based Scaling (Secondary)
- **Scale Out**: Memory > 80% for 3 minutes → Add 1 instance
- **Scale In**: Memory < 40% for 10 minutes → Remove 1 instance

### Rule Set 3: Request Queue-Based Scaling (Burst Protection)
- **Scale Out**: HTTP Queue > 50 for 1 minute → Add 2 instances (aggressive)
- **Purpose**: Handle sudden traffic spikes

### Rule Set 4: Time-Based Scaling (Optional)
If you know your peak usage times:
```bash
# Scale to 3 instances during business hours (8 AM - 6 PM)
az monitor autoscale profile create \
  --name business-hours \
  --autoscale-name ABSRuleRed2-autoscale \
  --resource-group LeiWangNewAppRG \
  --count 3 \
  --timezone "Pacific Standard Time" \
  --start "08:00" \
  --end "18:00" \
  --recurrence week mon tue wed thu fri
```

## Monitoring Auto-Scaling Events

```bash
# View autoscale activity log
az monitor activity-log list \
  --resource-group LeiWangNewAppRG \
  --caller Microsoft.Insights/AutoscaleSettings \
  --start-time 2024-01-01 \
  --query "[?contains(resourceId, 'autoscale')]" \
  --output table

# View current instance count
az appservice plan show \
  --name LeiWangNew \
  --resource-group LeiWangNewAppRG \
  --query "sku.capacity" \
  --output tsv

# View autoscale settings
az monitor autoscale show \
  --name ABSRuleRed2-autoscale \
  --resource-group LeiWangNewAppRG
```

## Cost Optimization Strategies

### Strategy 1: Use Auto-Scaling on Standard Tier
- **Monthly Cost**: ~$70 base + additional instance hours
- **Savings**: Scale down during off-peak hours
- **Best For**: Production apps with variable traffic

### Strategy 2: Use Manual Scaling on Basic Tier
- **Monthly Cost**: ~$13 (fixed)
- **Savings**: Lower base cost
- **Limitation**: Must manually scale
- **Best For**: Predictable, low-to-medium traffic

### Strategy 3: Serverless Alternative - Azure Container Apps
Consider migrating to Azure Container Apps for true serverless scaling:
- **Pay only for usage** (per-second billing)
- **Scale to zero** when not in use
- **Auto-scaling included** by default
- **Cost**: ~$0.000024/vCPU-second + $0.000004/GB-second

```bash
# Create Container App Environment (one-time)
az containerapp env create \
  --name abs-red-extractor-env \
  --resource-group LeiWangNewAppRG \
  --location westus

# Deploy Container App
az containerapp create \
  --name abs-red-extractor \
  --resource-group LeiWangNewAppRG \
  --environment abs-red-extractor-env \
  --image ghcr.io/yourusername/abs-red-extractor:latest \
  --target-port 5000 \
  --ingress external \
  --min-replicas 0 \
  --max-replicas 10 \
  --cpu 1.0 \
  --memory 2.0Gi
```

## Recommendations

### For Development/Testing
- **Use**: F1 (Free) tier
- **Cost**: $0
- **Scaling**: None needed

### For Small Production (< 100 users/day)
- **Use**: B1 (Basic) tier with manual scaling
- **Cost**: ~$13/month
- **Scaling**: Manually scale to 2-3 instances during peak hours

### For Medium Production (100-1000 users/day)
- **Use**: S1 (Standard) tier with auto-scaling
- **Cost**: ~$70-100/month (varies with usage)
- **Scaling**: Auto-scale 1-5 instances based on CPU/memory

### For High-Traffic Production (> 1000 users/day)
- **Use**: Azure Container Apps or Premium tier
- **Cost**: Variable (Container Apps) or ~$100+/month (Premium)
- **Scaling**: Aggressive auto-scaling or scale-to-zero

## Implementation Checklist

- [ ] Decide on tier based on traffic expectations and budget
- [ ] Upgrade App Service Plan if needed (currently on F1)
- [ ] Configure auto-scaling rules (if Standard or higher)
- [ ] Test auto-scaling by generating load
- [ ] Set up monitoring and alerts (see HEALTH_MONITORING_GUIDE.md)
- [ ] Monitor costs in Azure Cost Management
- [ ] Adjust rules based on real-world usage patterns

## Quick Commands

```bash
# Check current tier
az appservice plan show -n LeiWangNew -g LeiWangNewAppRG --query "sku.name"

# Upgrade to Standard S1 (enables auto-scaling)
az appservice plan update -n LeiWangNew -g LeiWangNewAppRG --sku S1

# Downgrade to Basic B1 (manual scaling only)
az appservice plan update -n LeiWangNew -g LeiWangNewAppRG --sku B1

# Stay on Free F1 (no scaling)
# (already there, no action needed)

# View current instance count
az appservice plan show -n LeiWangNew -g LeiWangNewAppRG --query "sku.capacity"
```

## Next Steps

See [HEALTH_MONITORING_GUIDE.md](HEALTH_MONITORING_GUIDE.md) for comprehensive health monitoring and alerting setup.
