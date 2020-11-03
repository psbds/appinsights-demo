NAME="padasildemoinsights"
VM_NAME="padasildemo"
LOCATION="eastus"
VNET_RANGE_PREFIX="10.0.0.0/8"
SUBNET_RANGE_PREFIX="10.0.0.0/16"

az group create -l $LOCATION -n $NAME

az monitor log-analytics workspace create  --resource-group $NAME --workspace-name $NAME

az monitor app-insights component create --app $NAME --location $LOCATION --kind web -g $NAME --application-type web --workspace $NAME

az appservice plan create -n $NAME -g $NAME --sku S1 --location $LOCATION

az webapp create -g $NAME -p $NAME -n $NAME

INSTRUMENTATION_KEY=$(az resource show -g $NAME -n $NAME --resource-type "Microsoft.Insights/components" --query properties.InstrumentationKey | tr -d '"')

az webapp config appsettings set -g $NAME -n $NAME --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY

az webapp config appsettings set -g $NAME -n $NAME --settings APPINSIGHTS_INSTRUMENTATIONKEY=$INSTRUMENTATION_KEY \
    APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=$INSTRUMENTATION_KEY \
    ApplicationInsightsAgent_EXTENSION_VERSION=~2 \
    APPINSIGHTS_PROFILERFEATURE_VERSION=1.0.0 \
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION=1.0.0 \
    APPINSIGHTS_PORTALINFO=ASP.NETCORE \
    DiagnosticServices_EXTENSION_VERSION=~3 \
    InstrumentationEngine_EXTENSION_VERSION=~1 \
    SnapshotDebugger_EXTENSION_VERSION=~1


az network vnet create \
        --location $LOCATION \
        --resource-group $NAME \
        --name $NAME \
        --address-prefixes $VNET_RANGE_PREFIX \
        --subnet-name default \
        --subnet-prefix $SUBNET_RANGE_PREFIX

az vm create \
    --location $LOCATION \
    --resource-group $NAME \
    --name $VM_NAME \
    --vnet-name $NAME \
    --subnet default \
    --image win2016datacenter \
    --admin-username azureuser \
    --admin-password @zureus3r0001 \
    --workspace $NAME

az vm open-port --port 3389 --resource-group $NAME --name $VM_NAME
