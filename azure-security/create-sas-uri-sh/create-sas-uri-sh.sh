#!/bin/bash

#<FullScript>
# Steps : 
#-Create a key vault
#-Add secret
#-Read secret
#
# Global variables
let "randomIdentifier=$RANDOM*$RANDOM"
location="westeurope"
resourceGroup="create-shared-access-signature-$randomIdentifier"
storageAccount="createsasuristg"
containerName="files"
end=`date -u -d "30 minutes" '+%Y-%m-%dT%H:%MZ'`

echo "Creating resource group : $resourceGroup"
az group create -l $location -g $resourceGroup

echo "Creating storage account : $storageAccount"
az storage account create -g $resourceGroup -n $storageAccount -l $location

echo "Creating container"
accountKey="$(az storage account keys list -g $resourceGroup -n $storageAccount --query [0].value)"
az storage container create -n $containerName --account-key $accountKey --account-name $storageAccount

echo "Creating blob to upload"
echo test upload file > file1.txt

echo "Upload file"
az storage blob upload -n file1.txt -f file1.txt -c $containerName --account-key $accountKey --account-name $storageAccount

echo "Generate sas uri"
az storage blob generate-sas --https-only -n file1.txt -c $containerName --account-key $accountKey --account-name $storageAccount --permissions r --expiry $end --full-uri

#</FullScript>
# echo "Deleting all resources"
# az group delete -n $resourceGroup -y