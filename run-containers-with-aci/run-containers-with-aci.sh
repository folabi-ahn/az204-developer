#!/bin/bash

#<FullScript>
# Steps : 
#-Create an Instance of Azure Container Registry (ACR)
#-Build and Push a Container Image to ACR
#-Deploy an Image to Azure Container Instances (ACI)
#
# Global variables
let "randomIdentifier=$RANDOM*$RANDOM"
location="westeurope"
resourceGroup="run-containers-with-aci-rg$randomIdentifier"
acr="runcontainerswithaciacr"
acrHost="$acr.azurecr.io"

# Create resource group
echo "Creating resource group $resourceGroup  in $location"
az group create -l $location -n $resourceGroup

# Create ACR
echo "Creating ACR : $acr"
az acr create -g $resourceGroup -n $acr --sku Basic

# Set user as admin
# echo "Setting user as admin"
az acr update -n $acr --admin-enabled true

# Create docker file with microsoft hello-world image
echo "Create docker file"
cd clouddrive
echo FROM mcr.microsoft.com/hello-world > Dockerfile

# Build image
echo "Build image and push"
az acr build -r $acr -t sample/hello-world:v1 -f Dockerfile .

# Create container instance
# You will be prompted to enter the username and password of Acr.  You can find this by going in Azure Portal, 
# find your Acr and go to access keys
echo "Creating container instance"
az container create -g $resourceGroup --name sample-hello-world --image $acrHost/sample/hello-world:v1

# </FullScript>
# echo "Deleting all resources"
# az group delete -n $resourceGroup -y
