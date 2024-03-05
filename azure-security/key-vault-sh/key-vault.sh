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
resourceGroup="key-vault-$randomIdentifier"
keyvaultName="my-key-vault-$randomIdentifier"
secretName="password"
secretValue="p@ssword1234"

echo "Creating resource group : $resourceGroup"
az group create -l $location -g $resourceGroup

echo "Creating keyvault : $keyvaultName"
az keyvault create -l $location -g $resourceGroup -n $keyvaultName

echo "Add secret in keyvault"
az keyvault secret set --vault-name $keyvaultName -n $secretName --value $secretValue

echo "Show secret"
az keyvault secret show --vault-name $keyvaultName -n $secretName

#</FullScript>
# echo "Deleting all resources"
# az group delete -n $resourceGroup -y