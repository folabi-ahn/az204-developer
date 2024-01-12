#!/bin/bash

#<FullScript>
# Steps : 
#-Deploy a simple .NET Core web application to a new web app in Azure App Service.
#-Make changes to your web application, and deploy these to a staging slot.
#-Perform a slot swap, so that your changes are promoted to production.
#
# Global variables
let "randomIdentifier=$RANDOM*$RANDOM"
location="westeurope"
resourceGroup="deployment-slots-rg-$randomIdentifier"

# Create resource group
echo "Creating resource group $resourceGroup in $location"
az group create -l $location -n $resourceGroup


# </FullScript>

# echo "Deleting all resources"
# az group delete --name $resourceGroup -y