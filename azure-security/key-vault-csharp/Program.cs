
using System;
using Azure.Identity;
using Azure.Security.KeyVault.Secrets;

string kvUri = "https://kv-folabi-ahn.vault.azure.net/";

// authenticate and create client
// make sure that you have access to manage secrets in the vault access policies
var client = new SecretClient(new Uri(kvUri), new DefaultAzureCredential());

// add secret
var secretName = "password";
var secretValue = "p@ssword1234";
await client.SetSecretAsync(secretName, secretValue);

// read secret
var secret = await client.GetSecretAsync(secretName);
Console.WriteLine(secret.Value.Value);