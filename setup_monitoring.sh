#!/bin/bash

# =============================================================================
# Azure Health Monitoring & Alerts Setup Script
# =============================================================================
# This script sets up comprehensive health monitoring and alerting for the
# ABS Rules Red Text Extractor Azure Web App.
#
# Prerequisites:
# - Azure CLI installed and logged in
# - Appropriate permissions to create monitoring resources
#
# Usage:
#   ./setup_monitoring.sh
#
# =============================================================================

set -e  # Exit on error

# Configuration
RESOURCE_GROUP="LeiWangNewAppRG"
WEBAPP_NAME="ABSRuleRed2"
APP_SERVICE_PLAN="LeiWangNew"
LOCATION="westus"
APP_INSIGHTS_NAME="${WEBAPP_NAME}-insights"
LOG_ANALYTICS_NAME="${WEBAPP_NAME}-logs"
ACTION_GROUP_NAME="${WEBAPP_NAME}-alerts"
ALERT_EMAIL="${ALERT_EMAIL:-your-email@example.com}"  # Override with environment variable

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# Helper Functions
# =============================================================================

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_azure_login() {
    log_info "Checking Azure login status..."
    if ! az account show &> /dev/null; then
        log_error "Not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    log_success "Azure login verified"
}

# =============================================================================
# Step 1: Create Application Insights
# =============================================================================

setup_application_insights() {
    log_info "Setting up Application Insights..."
    
    # Check if Application Insights already exists
    if az monitor app-insights component show --app "$APP_INSIGHTS_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
        log_warning "Application Insights '$APP_INSIGHTS_NAME' already exists"
    else
        log_info "Creating Application Insights resource..."
        az monitor app-insights component create \
            --app "$APP_INSIGHTS_NAME" \
            --location "$LOCATION" \
            --resource-group "$RESOURCE_GROUP" \
            --application-type web \
            --retention-time 30
        log_success "Application Insights created"
    fi
    
    # Get instrumentation key
    INSTRUMENTATION_KEY=$(az monitor app-insights component show \
        --app "$APP_INSIGHTS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query instrumentationKey \
        --output tsv)
    
    log_info "Instrumentation Key: ${INSTRUMENTATION_KEY:0:20}..."
    
    # Configure Web App to use Application Insights
    log_info "Linking Application Insights to Web App..."
    az webapp config appsettings set \
        --name "$WEBAPP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --settings \
            APPINSIGHTS_INSTRUMENTATIONKEY="$INSTRUMENTATION_KEY" \
            APPLICATIONINSIGHTS_CONNECTION_STRING="InstrumentationKey=$INSTRUMENTATION_KEY" \
            ApplicationInsightsAgent_EXTENSION_VERSION="~3" \
            XDT_MicrosoftApplicationInsights_Mode="recommended"
    
    log_success "Application Insights configured"
}

# =============================================================================
# Step 2: Create Log Analytics Workspace
# =============================================================================

setup_log_analytics() {
    log_info "Setting up Log Analytics workspace..."
    
    # Check if Log Analytics workspace already exists
    if az monitor log-analytics workspace show --workspace-name "$LOG_ANALYTICS_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
        log_warning "Log Analytics workspace '$LOG_ANALYTICS_NAME' already exists"
    else
        log_info "Creating Log Analytics workspace..."
        az monitor log-analytics workspace create \
            --workspace-name "$LOG_ANALYTICS_NAME" \
            --resource-group "$RESOURCE_GROUP" \
            --location "$LOCATION" \
            --retention-time 30
        log_success "Log Analytics workspace created"
    fi
    
    # Get workspace ID
    WORKSPACE_ID=$(az monitor log-analytics workspace show \
        --workspace-name "$LOG_ANALYTICS_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --query customerId \
        --output tsv)
    
    log_info "Workspace ID: ${WORKSPACE_ID:0:20}..."
    
    # Configure diagnostic settings for Web App
    log_info "Configuring diagnostic settings..."
    
    WEBAPP_RESOURCE_ID="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$WEBAPP_NAME"
    
    az monitor diagnostic-settings create \
        --name "${WEBAPP_NAME}-diagnostics" \
        --resource "$WEBAPP_RESOURCE_ID" \
        --workspace "$WORKSPACE_ID" \
        --logs '[
            {"category": "AppServiceHTTPLogs", "enabled": true},
            {"category": "AppServiceConsoleLogs", "enabled": true},
            {"category": "AppServiceAppLogs", "enabled": true},
            {"category": "AppServicePlatformLogs", "enabled": true}
        ]' \
        --metrics '[{"category": "AllMetrics", "enabled": true}]' || log_warning "Diagnostic settings may already exist"
    
    log_success "Log Analytics configured"
}

# =============================================================================
# Step 3: Enable Health Check
# =============================================================================

setup_health_check() {
    log_info "Configuring health check..."
    
    az webapp config set \
        --name "$WEBAPP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --health-check-path "/health"
    
    log_success "Health check enabled at /health endpoint"
}

# =============================================================================
# Step 4: Create Action Group for Alerts
# =============================================================================

setup_action_group() {
    log_info "Setting up action group for alerts..."
    
    # Prompt for email if not set
    if [ "$ALERT_EMAIL" = "your-email@example.com" ]; then
        log_warning "No alert email configured. Set ALERT_EMAIL environment variable."
        read -p "Enter email address for alerts (or press Enter to skip): " USER_EMAIL
        if [ -n "$USER_EMAIL" ]; then
            ALERT_EMAIL="$USER_EMAIL"
        fi
    fi
    
    if [ "$ALERT_EMAIL" != "your-email@example.com" ]; then
        # Check if action group already exists
        if az monitor action-group show --name "$ACTION_GROUP_NAME" --resource-group "$RESOURCE_GROUP" &> /dev/null; then
            log_warning "Action group '$ACTION_GROUP_NAME' already exists"
        else
            log_info "Creating action group with email: $ALERT_EMAIL"
            az monitor action-group create \
                --name "$ACTION_GROUP_NAME" \
                --resource-group "$RESOURCE_GROUP" \
                --short-name "absalerts" \
                --email-receiver name=admin email-address="$ALERT_EMAIL"
            log_success "Action group created"
        fi
    else
        log_warning "Skipping action group creation (no email configured)"
    fi
}

# =============================================================================
# Step 5: Create Metric Alerts
# =============================================================================

setup_metric_alerts() {
    log_info "Setting up metric alerts..."
    
    if [ "$ALERT_EMAIL" = "your-email@example.com" ]; then
        log_warning "Skipping alert creation (no action group configured)"
        return
    fi
    
    WEBAPP_RESOURCE_ID="/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.Web/sites/$WEBAPP_NAME"
    
    # Alert 1: High CPU
    log_info "Creating CPU alert..."
    az monitor metrics alert create \
        --name "${WEBAPP_NAME}-high-cpu" \
        --resource-group "$RESOURCE_GROUP" \
        --scopes "$WEBAPP_RESOURCE_ID" \
        --condition "avg Percentage CPU > 80" \
        --window-size 10m \
        --evaluation-frequency 5m \
        --action "$ACTION_GROUP_NAME" \
        --description "CPU usage is high (>80%)" \
        --severity 2 || log_warning "CPU alert may already exist"
    
    # Alert 2: High Memory
    log_info "Creating memory alert..."
    az monitor metrics alert create \
        --name "${WEBAPP_NAME}-high-memory" \
        --resource-group "$RESOURCE_GROUP" \
        --scopes "$WEBAPP_RESOURCE_ID" \
        --condition "avg Memory Percentage > 85" \
        --window-size 10m \
        --evaluation-frequency 5m \
        --action "$ACTION_GROUP_NAME" \
        --description "Memory usage is high (>85%)" \
        --severity 2 || log_warning "Memory alert may already exist"
    
    # Alert 3: HTTP Server Errors
    log_info "Creating HTTP error alert..."
    az monitor metrics alert create \
        --name "${WEBAPP_NAME}-http-errors" \
        --resource-group "$RESOURCE_GROUP" \
        --scopes "$WEBAPP_RESOURCE_ID" \
        --condition "total Http5xx > 10" \
        --window-size 5m \
        --evaluation-frequency 1m \
        --action "$ACTION_GROUP_NAME" \
        --description "High number of HTTP 5xx errors" \
        --severity 1 || log_warning "HTTP error alert may already exist"
    
    # Alert 4: Response Time
    log_info "Creating response time alert..."
    az monitor metrics alert create \
        --name "${WEBAPP_NAME}-slow-response" \
        --resource-group "$RESOURCE_GROUP" \
        --scopes "$WEBAPP_RESOURCE_ID" \
        --condition "avg ResponseTime > 5000" \
        --window-size 15m \
        --evaluation-frequency 5m \
        --action "$ACTION_GROUP_NAME" \
        --description "Response time is slow (>5 seconds)" \
        --severity 2 || log_warning "Response time alert may already exist"
    
    log_success "Metric alerts created"
}

# =============================================================================
# Step 6: Enable Application Logging
# =============================================================================

setup_logging() {
    log_info "Configuring application logging..."
    
    az webapp log config \
        --name "$WEBAPP_NAME" \
        --resource-group "$RESOURCE_GROUP" \
        --application-logging filesystem \
        --detailed-error-messages true \
        --failed-request-tracing true \
        --web-server-logging filesystem \
        --level information
    
    log_success "Application logging configured"
}

# =============================================================================
# Step 7: Test Health Endpoints
# =============================================================================

test_health_endpoints() {
    log_info "Testing health endpoints..."
    
    APP_URL=$(az webapp show --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostName" -o tsv)
    
    log_info "App URL: https://$APP_URL"
    
    # Test basic health
    log_info "Testing /health endpoint..."
    if curl -s -f "https://$APP_URL/health" > /dev/null 2>&1; then
        log_success "/health endpoint is working"
        curl -s "https://$APP_URL/health" | head -n 20
    else
        log_warning "/health endpoint not yet available (app may still be starting)"
    fi
    
    # Test detailed health
    log_info "Testing /health/detailed endpoint..."
    if curl -s -f "https://$APP_URL/health/detailed" > /dev/null 2>&1; then
        log_success "/health/detailed endpoint is working"
        curl -s "https://$APP_URL/health/detailed" | head -n 30
    else
        log_warning "/health/detailed endpoint not yet available"
    fi
}

# =============================================================================
# Step 8: Display Summary
# =============================================================================

display_summary() {
    log_success "Monitoring setup completed!"
    echo ""
    echo "=========================================="
    echo "MONITORING SETUP SUMMARY"
    echo "=========================================="
    echo ""
    echo "📊 Application Insights:"
    echo "   Name: $APP_INSIGHTS_NAME"
    echo "   Portal: https://portal.azure.com/#resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/microsoft.insights/components/$APP_INSIGHTS_NAME"
    echo ""
    echo "📝 Log Analytics:"
    echo "   Name: $LOG_ANALYTICS_NAME"
    echo "   Portal: https://portal.azure.com/#resource/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$RESOURCE_GROUP/providers/Microsoft.OperationalInsights/workspaces/$LOG_ANALYTICS_NAME"
    echo ""
    echo "🔔 Alerts:"
    echo "   Action Group: $ACTION_GROUP_NAME"
    if [ "$ALERT_EMAIL" != "your-email@example.com" ]; then
        echo "   Email: $ALERT_EMAIL"
    fi
    echo "   Alerts Portal: https://portal.azure.com/#blade/Microsoft_Azure_Monitoring/AzureMonitoringBrowseBlade/alertsV2"
    echo ""
    echo "🏥 Health Endpoints:"
    APP_URL=$(az webapp show --name "$WEBAPP_NAME" --resource-group "$RESOURCE_GROUP" --query "defaultHostName" -o tsv)
    echo "   Basic:    https://$APP_URL/health"
    echo "   Detailed: https://$APP_URL/health/detailed"
    echo "   Liveness: https://$APP_URL/health/liveness"
    echo "   Readiness: https://$APP_URL/health/readiness"
    echo "   Metrics:  https://$APP_URL/metrics"
    echo ""
    echo "📚 Next Steps:"
    echo "   1. Review alerts in Azure Portal"
    echo "   2. Check Application Insights dashboards"
    echo "   3. Test health endpoints"
    echo "   4. Configure additional custom metrics if needed"
    echo ""
    echo "=========================================="
}

# =============================================================================
# Main Execution
# =============================================================================

main() {
    echo ""
    echo "=========================================="
    echo "Azure Health Monitoring Setup"
    echo "=========================================="
    echo ""
    
    check_azure_login
    setup_application_insights
    setup_log_analytics
    setup_health_check
    setup_action_group
    setup_metric_alerts
    setup_logging
    
    # Wait a bit for app to restart
    log_info "Waiting 30 seconds for app to restart..."
    sleep 30
    
    test_health_endpoints
    display_summary
}

# Run main function
main
