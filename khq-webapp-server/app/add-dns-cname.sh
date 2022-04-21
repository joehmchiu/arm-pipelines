#!/bin/sh

env=${1:-pipeline}
prefix=$2
[ -z $3 ] && { echo "Error: DNS CNAME not found"; exit 2; }
cname=$3

zone=$env.az.karbonhq.com
zrg=$(az network dns zone list | jq '.[] | select(.name=="'$zone'") | .resourceGroup' | sed 's/"//g')
echo "4. Create DNS CNAME $cname.$zone."
az network dns record-set cname create -n $cname -g $zrg -z $zone

crset="$env-khq-agw.australiaeast.cloudapp.azure.com"
# hardcode - will be improved in the next version
crset="transformer-$env-identity-app.azurewebsites.net"
echo "5. Setup DNS CNAME Record Set $crset."
echo "az network dns record-set cname set-record -g $zrg -z $zone -n $cname -c $crset"
az network dns record-set cname set-record -g $zrg -z $zone -n $cname -c $crset

echo "6. CNAME record set $crset created."

