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
appServicePlan="deployment-slots-app-service-plan-$randomIdentifier"
webapp="deployment-slots-webapp-$randomIdentifier"
webappName="my-webapp"
webappPublish="my-webapp-publish"
dotnetVersion="dotnet:6" # Change this to your default target framework version 

# Create new .net webapp
echo "Creating $webappName"
dotnet new webapp -o my-webapp --force

# Moving to webapp directory
echo "Moving to webapp directory"
cd $webappName/

# Create resource group
echo "Creating resource group $resourceGroup in $location"
az group create -l $location -n $resourceGroup

# Create a webapp and deploy code from a local workspace to the app
az webapp up -g $resourceGroup -p $appServicePlan -n $webapp -l $location -r $dotnetVersion --sku S1

# Website in production slot
site="http://$webapp.azurewebsites.net"
echo $site
curl "$site"

# Creating staging slot
echo "Creating staging slot"
az webapp deployment slot create -g $resourceGroup -n $webapp -s staging

# Update Index.html content file
echo "Updating Index.html file"
sed -i -e 's/Welcome/Welcome in staging slot/g' Pages/Index.cshtml

# Dotnet publish
echo "Dotnet publish new changes"
dotnet publish -o $webappPublish

# Create zip
echo "Creating zip"
zip $webappPublish.zip $webappPublish/

# Upload changes to staging slot
echo "Upload changes to staging slot"
az webapp deployment source config-zip -g $resourceGroup -n $webapp --src $webappPublish.zip -s staging

# Swap slots
# echo "Swaping slot production & staging"
# az webapp deployment slot swap  -g $resourceGroup -n $webapp --slot staging \
#     --target-slot production

# </FullScript>

# echo "Deleting $webappName"
#rm -rf $webappName/

# echo "Deleting all resources"
# az group delete -n $resourceGroup -y