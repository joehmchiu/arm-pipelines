#!/bin/sh

env=${1:-pipeline}
prefix=${2:-transformer}
prefix="$prefix-$env"

rg="$prefix-identity-app-rg"
loc=westus
echo "1. Create resource group - $rg."
az group create -n $rg -l $loc

plan=$prefix-identity-app-service-plan
deploy=AppServicePlanDeployment

echo "2. Create a service plan - $plan."

az deployment group create \
  --name $deploy \
  --resource-group $rg \
  --template-file app-service-plan.json \
  --parameters serverfarms_khq_identity_app_service_plan_name=$plan

app="$prefix-identity-app"
planid=$(az appservice plan show -n $plan -g $rg | jq .id | sed 's/"//g')
deploy=ExampleDeployment

echo "3. Deploy the app server - $app by the created plan ID: $planid."

az deployment group create \
  --name $deploy \
  --resource-group $rg \
  --template-file identity-app-server.json \
  --parameters sites_khq_identity_app_name=$app serverfarms_khq_identity_app_service_plan_name=$planid

echo "4. App server deployed."

# vnet=identity-inte-vnet
# subnet=PublicSubnet1
# vrg=transformer-dev2-identity-app-rg
# 
# echo "5. Integrating with DB VNet $vnet."
# vnetid=$(az network vnet list -g $vrg | jq '.[].id' | sed 's/"//g')
# subnetid=$(az network vnet subnet list -g $vrg --vnet-name $vnet | jq '.[] | select (.name=="'$subnet'") | .id' | sed 's/"//g')
# echo "az webapp vnet-integration add -g $rg -n $app --vnet $vnetid --subnet $subnetid"
# az webapp vnet-integration add -g $rg -n $app --vnet $vnetid --subnet $subnetid
# #  --template-uri "https://raw.githubusercontent.com/joehmchiu/arm-pipelines/master/webapp-linux-managed-mysql/azuredeploy.json" 
# 
# echo "6. VNet $vnet integrated."


