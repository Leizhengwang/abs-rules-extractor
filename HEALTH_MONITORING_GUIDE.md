# Health Monitoring & Alerting Guide

## Overview
Comprehensive health monitoring setup for the ABS Rules Red Text Extractor Azure Web App, including Application Insights, metrics, alerts, and dashboards.

## Table of Contents
1. [Application Insights Setup](#application-insights-setup)
2. [Built-in Health Checks](#built-in-health-checks)
3. [Custom Health Endpoints](#custom-health-endpoints)
4. [Metrics & Monitoring](#metrics--monitoring)
5. [Alerts Configuration](#alerts-configuration)
6. [Logging & Diagnostics](#logging--diagnostics)
7. [Dashboard Setup](#dashboard-setup)
8. [Cost Considerations](#cost-considerations)

---

## Application Insights Setup

### Option 1: Enable via Azure Portal (Easiest)

1. Go to Azure Portal → App Services → ABSRuleRed2
2. Navigate to **Application Insights** in the left menu
3. Click **Turn on Application Insights**
4. Select **Create new resource** or use existing
5. Choose settings:
   - **Name**: ABSRuleRed2-insights
   - **Location**: Same as web app (West US)
   - **Log Analytics Workspace**: Create new or use existing
6. Click **Apply**

**Cost**: ~$2-5/month for low traffic (first 5 GB free, then $2.30/GB)

### Option 2: Enable via Azure CLI

```bash
# Create Application Insights resource
az monitor app-insights component create \
  --app ABSRuleRed2-insights \
  --location westus \
  --resource-group LeiWangNewAppRG \
  --application-type web

# Get instrumentation key
INSTRUMENTATION_KEY=$(az monitor app-insights component show \
  --app ABSRuleRed2-insights \
  --resource-group LeiWangNewAppRG \
  --query instrumentationKey \
  --output tsv)

# Link Application Insights to Web App
az webapp config appsettings set \
  --name ABSRuleRed2 \
  --resource-group LeiWangNewAppRG \
  --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY \
             APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$INSTRUMENTATION_KEY"

# Enable Application Insights monitoring
az monitor app-insights component connect-webapp \
  --app ABSRuleRed2-insights \
  --resource-group LeiWangNewAppRG \
  --web-app ABSRuleRed2
```

### Option 3: Add to Python Code (Most Control)

Install the SDK:
```bash
# Add to web_app/requirements.txt
echo "opencensus-ext-azure" >> web_app/requirements.txt
echo "opencensus-ext-flask" >> web_app/requirements.txt
```

Update `app.py`:
```python
from opencensus.ext.azure import metrics_exporter
from opencensus.ext.azure.log_exporter import AzureLogHandler
from opencensus.ext.flask.flask_middleware import FlaskMiddleware
import logging

# Add after app = Flask(__name__)
app = Flask(__name__)

# Configure Application Insights
APPINSIGHTS_KEY = os.environ.get('APPINSIGHTS_INSTRUMENTATIONKEY', '')
if APPINSIGHTS_KEY:
    # Enable Flask middleware for automatic request tracking
    middleware = FlaskMiddleware(
        app,
        exporter=metrics_exporter.new_metrics_exporter(
            connection_string=f'InstrumentationKey={APPINSIGHTS_KEY}'
        )
    )
    
    # Configure logging to Application Insights
    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)
    logger.addHandler(AzureLogHandler(
        connection_string=f'InstrumentationKey={APPINSIGHTS_KEY}'
    ))
    
    logger.info('Application Insights enabled')
```

---

## Built-in Health Checks

Azure App Service provides built-in health checks:

### Enable Health Check via Portal
1. Go to **Health check** under Monitoring
2. Enable health check
3. Set health check path: `/health` or `/`
4. Save

### Enable Health Check via CLI

```bash
# Enable health check
az webapp config set \
  --name ABSRuleRed2 \
  --resource-group LeiWangNewAppRG \
  --health-check-path "/health"
```

**Features**:
- Automatically removes unhealthy instances from load balancer rotation
- Restarts unhealthy instances after detecting failures
- Works with Basic tier and above (NOT available on F1 Free tier)

---

## Custom Health Endpoints

Add custom health check endpoints to your Flask app:

### Update `web_app/app.py`:

```python
import psutil  # Add to requirements.txt
import time
from datetime import datetime

# Track app start time
APP_START_TIME = time.time()

@app.route('/health')
def health_check():
    """Basic health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'timestamp': datetime.utcnow().isoformat(),
        'uptime_seconds': int(time.time() - APP_START_TIME)
    }), 200

@app.route('/health/detailed')
def detailed_health_check():
    """Detailed health check with system metrics"""
    try:
        # Get system metrics
        cpu_percent = psutil.cpu_percent(interval=1)
        memory = psutil.virtual_memory()
        disk = psutil.disk_usage('/')
        
        # Check upload/output directories
        upload_dir_exists = os.path.exists(app.config['UPLOAD_FOLDER'])
        output_dir_exists = os.path.exists(app.config['OUTPUT_FOLDER'])
        
        # Determine overall health
        is_healthy = (
            cpu_percent < 90 and 
            memory.percent < 90 and 
            disk.percent < 90 and
            upload_dir_exists and 
            output_dir_exists
        )
        
        health_data = {
            'status': 'healthy' if is_healthy else 'degraded',
            'timestamp': datetime.utcnow().isoformat(),
            'uptime_seconds': int(time.time() - APP_START_TIME),
            'system': {
                'cpu_percent': cpu_percent,
                'memory_percent': memory.percent,
                'memory_available_mb': memory.available / (1024 * 1024),
                'disk_percent': disk.percent,
                'disk_free_gb': disk.free / (1024 * 1024 * 1024)
            },
            'application': {
                'upload_folder': app.config['UPLOAD_FOLDER'],
                'upload_folder_exists': upload_dir_exists,
                'output_folder': app.config['OUTPUT_FOLDER'],
                'output_folder_exists': output_dir_exists
            }
        }
        
        status_code = 200 if is_healthy else 503
        return jsonify(health_data), status_code
        
    except Exception as e:
        return jsonify({
            'status': 'unhealthy',
            'error': str(e),
            'timestamp': datetime.utcnow().isoformat()
        }), 503

@app.route('/health/liveness')
def liveness_check():
    """Kubernetes-style liveness probe"""
    # Simple check - is the app running?
    return jsonify({'status': 'alive'}), 200

@app.route('/health/readiness')
def readiness_check():
    """Kubernetes-style readiness probe"""
    try:
        # Check if app is ready to serve requests
        upload_ready = os.path.exists(app.config['UPLOAD_FOLDER'])
        output_ready = os.path.exists(app.config['OUTPUT_FOLDER'])
        
        if upload_ready and output_ready:
            return jsonify({'status': 'ready'}), 200
        else:
            return jsonify({
                'status': 'not_ready',
                'upload_folder_ready': upload_ready,
                'output_folder_ready': output_ready
            }), 503
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 503
```

### Add Dependencies to `requirements.txt`:
```bash
echo "psutil>=5.9.0" >> web_app/requirements.txt
```

---

## Metrics & Monitoring

### Key Metrics to Monitor

#### 1. **Application Performance Metrics**
- **Response Time**: Average, P50, P95, P99
- **Request Rate**: Requests per second/minute
- **Error Rate**: Failed requests percentage
- **Dependency Duration**: External service call times

#### 2. **Infrastructure Metrics**
- **CPU Percentage**: Should stay < 70% average
- **Memory Percentage**: Should stay < 80%
- **HTTP Queue Length**: Should stay < 100
- **Response Time**: Should be < 3 seconds for most requests

#### 3. **Business Metrics** (Custom)
- **PDF Processing Time**: Time to extract red text per PDF
- **PDF File Size**: Track uploaded file sizes
- **Success Rate**: Successful vs failed PDF extractions
- **User Activity**: Number of uploads per hour/day

### View Metrics via Azure Portal
1. Go to App Service → ABSRuleRed2
2. Navigate to **Metrics** under Monitoring
3. Add metrics:
   - CPU Percentage
   - Memory Percentage
   - Response Time
   - Http Server Errors
   - Requests

### View Metrics via Azure CLI

```bash
# List available metrics
az monitor metrics list-definitions \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2

# Get CPU percentage (last 1 hour)
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "CpuPercentage" \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-01T01:00:00Z \
  --interval PT1M

# Get memory percentage
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "MemoryPercentage" \
  --interval PT5M
```

### Custom Metrics with Application Insights

Add to your Flask app:

```python
from opencensus.stats import aggregation as aggregation_module
from opencensus.stats import measure as measure_module
from opencensus.stats import stats as stats_module
from opencensus.stats import view as view_module
from opencensus.tags import tag_map as tag_map_module

# Define custom metrics
stats = stats_module.stats
view_manager = stats.view_manager
stats_recorder = stats.stats_recorder

# Measure: PDF processing time
pdf_processing_time_measure = measure_module.MeasureFloat(
    "pdf_processing_time",
    "Time to process a PDF file",
    "ms"
)

# Measure: PDF file size
pdf_file_size_measure = measure_module.MeasureInt(
    "pdf_file_size",
    "Size of uploaded PDF file",
    "bytes"
)

# Create views
pdf_processing_time_view = view_module.View(
    "pdf_processing_time_distribution",
    "Distribution of PDF processing times",
    [],
    pdf_processing_time_measure,
    aggregation_module.DistributionAggregation([50, 100, 200, 500, 1000, 2000, 5000])
)

pdf_file_size_view = view_module.View(
    "pdf_file_size_distribution",
    "Distribution of PDF file sizes",
    [],
    pdf_file_size_measure,
    aggregation_module.DistributionAggregation([100000, 500000, 1000000, 5000000, 10000000])
)

# Register views
view_manager.register_view(pdf_processing_time_view)
view_manager.register_view(pdf_file_size_view)

# Track metrics in your upload handler
@app.route('/upload', methods=['POST'])
def upload_file():
    start_time = time.time()
    
    # ... existing upload code ...
    
    # Record metrics
    file_size = os.path.getsize(file_path)
    processing_time = (time.time() - start_time) * 1000  # Convert to ms
    
    mmap = stats_recorder.new_measurement_map()
    tmap = tag_map_module.TagMap()
    
    mmap.measure_float_put(pdf_processing_time_measure, processing_time)
    mmap.measure_int_put(pdf_file_size_measure, file_size)
    mmap.record(tmap)
    
    # ... rest of handler ...
```

---

## Alerts Configuration

### Alert Categories

#### 1. **Critical Alerts** (Immediate Action Required)
- App is down (HTTP 5xx errors > 10% for 5 minutes)
- Response time > 10 seconds
- CPU > 90% for 10 minutes
- Memory > 95% for 5 minutes
- Health check failures

#### 2. **Warning Alerts** (Investigate Soon)
- CPU > 70% for 15 minutes
- Memory > 80% for 15 minutes
- Error rate > 5%
- Response time > 5 seconds
- Disk space > 80%

#### 3. **Informational Alerts**
- Daily summary of app usage
- Weekly cost report
- Auto-scaling events

### Create Alerts via Azure Portal

1. Go to **Alerts** under Monitoring
2. Click **+ Create** → **Alert rule**
3. Select **Scope**: ABSRuleRed2
4. Select **Condition**: Choose metric and threshold
5. Add **Action group**: Email, SMS, webhook
6. Set **Alert rule name** and severity
7. Click **Create**

### Create Alerts via Azure CLI

```bash
# Create action group for email notifications
az monitor action-group create \
  --name abs-red-extractor-alerts \
  --resource-group LeiWangNewAppRG \
  --short-name absalerts \
  --email-receiver \
    name=admin \
    email-address=your-email@example.com

# Alert 1: High CPU (Critical)
az monitor metrics alert create \
  --name high-cpu-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --condition "avg Percentage CPU > 90" \
  --window-size 10m \
  --evaluation-frequency 5m \
  --action abs-red-extractor-alerts \
  --description "CPU usage is critically high" \
  --severity 1

# Alert 2: High Memory (Critical)
az monitor metrics alert create \
  --name high-memory-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --condition "avg Memory Percentage > 95" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action abs-red-extractor-alerts \
  --description "Memory usage is critically high" \
  --severity 0

# Alert 3: High Error Rate (Critical)
az monitor metrics alert create \
  --name high-error-rate-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --condition "total Http5xx > 10" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action abs-red-extractor-alerts \
  --description "High number of server errors detected" \
  --severity 1

# Alert 4: Slow Response Time (Warning)
az monitor metrics alert create \
  --name slow-response-time-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --condition "avg ResponseTime > 5000" \
  --window-size 15m \
  --evaluation-frequency 5m \
  --action abs-red-extractor-alerts \
  --description "Response time is slower than expected" \
  --severity 2

# Alert 5: App Availability (Critical)
az monitor metrics alert create \
  --name app-down-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --condition "total Http2xx < 1" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action abs-red-extractor-alerts \
  --description "App appears to be down - no successful requests" \
  --severity 0
```

### Application Insights-Based Alerts

```bash
# Alert on failed requests (requires Application Insights)
az monitor metrics alert create \
  --name failed-requests-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/microsoft.insights/components/ABSRuleRed2-insights \
  --condition "total requests/failed > 5" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action abs-red-extractor-alerts \
  --description "High number of failed requests" \
  --severity 2

# Alert on exceptions
az monitor metrics alert create \
  --name exception-alert \
  --resource-group LeiWangNewAppRG \
  --scopes /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/microsoft.insights/components/ABSRuleRed2-insights \
  --condition "total exceptions/count > 10" \
  --window-size 5m \
  --evaluation-frequency 1m \
  --action abs-red-extractor-alerts \
  --description "High number of exceptions detected" \
  --severity 2
```

---

## Logging & Diagnostics

### Enable Diagnostic Logging

```bash
# Enable application logging
az webapp log config \
  --name ABSRuleRed2 \
  --resource-group LeiWangNewAppRG \
  --application-logging azureblobstorage \
  --detailed-error-messages true \
  --failed-request-tracing true \
  --web-server-logging filesystem

# Stream logs (real-time)
az webapp log tail \
  --name ABSRuleRed2 \
  --resource-group LeiWangNewAppRG

# Download logs
az webapp log download \
  --name ABSRuleRed2 \
  --resource-group LeiWangNewAppRG \
  --log-file webapp_logs.zip
```

### Log Analytics Integration

```bash
# Create Log Analytics workspace
az monitor log-analytics workspace create \
  --workspace-name ABSRuleRed2-logs \
  --resource-group LeiWangNewAppRG \
  --location westus

# Get workspace ID
WORKSPACE_ID=$(az monitor log-analytics workspace show \
  --workspace-name ABSRuleRed2-logs \
  --resource-group LeiWangNewAppRG \
  --query customerId \
  --output tsv)

# Configure diagnostic settings
az monitor diagnostic-settings create \
  --name ABSRuleRed2-diagnostics \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --workspace $WORKSPACE_ID \
  --logs '[{"category": "AppServiceHTTPLogs", "enabled": true}, {"category": "AppServiceConsoleLogs", "enabled": true}, {"category": "AppServiceAppLogs", "enabled": true}]' \
  --metrics '[{"category": "AllMetrics", "enabled": true}]'
```

### Structured Logging in Python

Update `app.py` for better logging:

```python
import logging
import json
from pythonjsonlogger import jsonlogger

# Configure structured logging
logHandler = logging.StreamHandler()
formatter = jsonlogger.JsonFormatter(
    fmt='%(asctime)s %(name)s %(levelname)s %(message)s'
)
logHandler.setFormatter(formatter)
logger = logging.getLogger()
logger.addHandler(logHandler)
logger.setLevel(logging.INFO)

# Use structured logging
@app.route('/upload', methods=['POST'])
def upload_file():
    logger.info('File upload started', extra={
        'event': 'upload_start',
        'ip': request.remote_addr,
        'user_agent': request.user_agent.string
    })
    
    # ... processing ...
    
    logger.info('File processing completed', extra={
        'event': 'upload_complete',
        'file_size': file_size,
        'processing_time_ms': processing_time,
        'status': 'success'
    })
```

Add to `requirements.txt`:
```
python-json-logger>=2.0.0
```

---

## Dashboard Setup

### Create Azure Dashboard

1. Go to Azure Portal
2. Click **Dashboard** → **+ New dashboard**
3. Add tiles:
   - **Metrics chart**: CPU percentage
   - **Metrics chart**: Memory percentage
   - **Metrics chart**: Response time
   - **Metrics chart**: Request count
   - **Resource health**: Health check status
   - **Alerts**: Active alerts
4. Save dashboard as "ABS Red Extractor Monitoring"

### Kusto Queries for Log Analytics

```kusto
// Top 10 slowest requests
AppServiceHTTPLogs
| where TimeGenerated > ago(1h)
| summarize avg(TimeTaken) by CsUriStem
| top 10 by avg_TimeTaken desc

// Error rate by hour
AppServiceHTTPLogs
| where TimeGenerated > ago(24h)
| summarize 
    TotalRequests = count(),
    ErrorCount = countif(ScStatus >= 400)
    by bin(TimeGenerated, 1h)
| extend ErrorRate = (ErrorCount * 100.0) / TotalRequests
| project TimeGenerated, TotalRequests, ErrorCount, ErrorRate

// Most common errors
AppServiceConsoleLogs
| where ResultDescription contains "error" or ResultDescription contains "exception"
| summarize Count = count() by ResultDescription
| top 20 by Count desc
```

---

## Cost Considerations

### Free Tier Monitoring (F1)
- ✅ **Included Free**:
  - Basic metrics (CPU, memory, requests)
  - Diagnostic logs
  - Health checks (limited)
  - Built-in monitoring
  
- ❌ **Not Available**:
  - Application Insights (separate resource, costs extra)
  - Auto-scaling
  - Advanced diagnostics

### Application Insights Costs

| Data Volume | Monthly Cost |
|-------------|--------------|
| 0-5 GB | FREE |
| 5-100 GB | $2.30/GB |
| 100-500 GB | $1.15/GB |
| 500+ GB | $0.58/GB |

**Expected cost for low-traffic app**: ~$2-5/month

### Log Analytics Costs

| Data Volume | Monthly Cost |
|-------------|--------------|
| 0-5 GB | FREE |
| 5+ GB | $2.76/GB |

### Cost Optimization Tips

1. **Use sampling** in Application Insights:
   ```python
   # Sample 50% of telemetry
   from opencensus.ext.azure.trace_exporter import AzureExporter
   exporter = AzureExporter(
       connection_string=connection_string,
       sampling_rate=0.5
   )
   ```

2. **Set data retention** to 30 days (default is 90):
   ```bash
   az monitor app-insights component update \
     --app ABSRuleRed2-insights \
     --resource-group LeiWangNewAppRG \
     --retention-time 30
   ```

3. **Filter logs** to exclude verbose/debug logs in production

4. **Use log aggregation** instead of individual log entries

---

## Quick Reference Commands

```bash
# Check app health
curl https://absrulered2.azurewebsites.net/health

# View real-time logs
az webapp log tail -n ABSRuleRed2 -g LeiWangNewAppRG

# View recent errors (last hour)
az webapp log download -n ABSRuleRed2 -g LeiWangNewAppRG

# Check CPU usage (last hour)
az monitor metrics list \
  --resource /subscriptions/$(az account show --query id -o tsv)/resourceGroups/LeiWangNewAppRG/providers/Microsoft.Web/sites/ABSRuleRed2 \
  --metric "CpuPercentage" \
  --start-time $(date -u -d '1 hour ago' '+%Y-%m-%dT%H:%M:%SZ') \
  --interval PT1M

# List active alerts
az monitor metrics alert list \
  --resource-group LeiWangNewAppRG

# Test health endpoint
curl -i https://absrulered2.azurewebsites.net/health/detailed
```

---

## Implementation Checklist

- [ ] Enable Application Insights
- [ ] Add custom health check endpoints to app.py
- [ ] Configure diagnostic logging
- [ ] Create critical alerts (CPU, memory, errors)
- [ ] Create warning alerts (performance degradation)
- [ ] Set up Log Analytics workspace
- [ ] Create monitoring dashboard
- [ ] Test alerts by triggering conditions
- [ ] Document monitoring procedures for team
- [ ] Set up weekly cost monitoring
- [ ] Configure log retention policies
- [ ] Add structured logging to app

---

## Next Steps

1. **Immediate**: Add health check endpoints to `app.py`
2. **Short-term**: Enable Application Insights and basic alerts
3. **Medium-term**: Set up comprehensive monitoring dashboard
4. **Long-term**: Implement custom metrics and advanced analytics

See [AUTO_SCALING_GUIDE.md](AUTO_SCALING_GUIDE.md) for auto-scaling configuration.
