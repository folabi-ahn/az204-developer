#!/bin/bash

#<FullScript>
# Steps : 
#-Create storage container
#-Create blob
#-Upload blob to storage container
#
# Global variables
let "randomIdentifier=$RANDOM*$RANDOM"
location="westeurope"
resourceGroup="upload-blob-to-container-rg$randomIdentifier"
storageAccountName="uploadblobstorageaccount"
storageContainer="mystoragecontainer"
blobName="text.txt"

# Creating resource group
echo "Creating resource group : $resourceGroup in $location"
az group create -l $location -n $resourceGroup

# Creating storage account
echo "Creating storage account"
az storage account create -n $storageAccountName -g $resourceGroup --allow-blob-public-access

# Prompt user to type storage account key
echo -n Account Key:
read -s accountKey

# Creating container
echo "Creating storage container"
az storage container create --account-name $storageAccountName -n $storageContainer --public-access blob --account-key $accountKey

# Create blob
echo "Creating blob"
echo test blob > $blobName

# Upload blob to container
echo "Uploading blob to container"
az storage blob upload --account-name $storageAccountName -c $storageContainer -f $blobName -n $blobName --account-key $accountKey

# Check if blob is well uploaded
az storage blob exists --account-name $storageAccountName -c $storageContainer -n $blobName --account-key $accountKey

# </FullScript>
# echo "Deleting all resources"
# az group delete -n $resourceGroup -y