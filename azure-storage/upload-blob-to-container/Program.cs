using Azure;
using Azure.Core;
using Azure.Identity;
using Azure.ResourceManager;
using Azure.ResourceManager.Resources;
using Azure.ResourceManager.Storage;
using Azure.ResourceManager.Storage.Models;
using Azure.Storage;
using Azure.Storage.Blobs;
using Azure.Storage.Blobs.Models;

public class Program
{
    static AzureLocation location = AzureLocation.WestEurope;

    static void Main(string[] args)
    {
        static async Task MainAsync()
        {
            var client = new ArmClient(new DefaultAzureCredential());
            SubscriptionResource subscription = await client.GetDefaultSubscriptionAsync();

            // create resource gorup
            var resourceGroupName = $"upload-blob-to-container-{Guid.NewGuid().ToString()}";

            Console.WriteLine($"Creating a resource group with name: {resourceGroupName}");
            ResourceGroupResource resourceGroup = await CreateResourceGroup(subscription, resourceGroupName, location);

            // create storage account
            string storageAccountName = "uploadblobstorageaccount";
            Console.WriteLine($"Creating storage account with name: {storageAccountName}");
            await CreateStorageAccount(storageAccountName, resourceGroup);

            // create container
            var containerName = "mystoragecontainer";
            Console.WriteLine($"Creating container with name: {containerName}");
            var container = await CreateContainer(storageAccountName, containerName);

            // create blob file
            var filename = "test_blob.txt";
            Console.WriteLine("Creating blob file to upload");
            await CreateFile(filename);

            // Upload blob
            Console.WriteLine("Uploading blob");
            Console.WriteLine("Enter accountKey:");
            string accountKey = Console.ReadLine() ?? string.Empty;
            if (string.IsNullOrEmpty(accountKey))
            {
                Console.WriteLine("accountKey is null or empty");
                return;
            }

            await UploadBlob(container, filename, accountKey);

            // Delete resource group
            // await DeleteResourceGroup(subscription, resourceGroupName);
        }

        static async Task<ResourceGroupResource> CreateResourceGroup(SubscriptionResource subscription, string resourceGroupName, AzureLocation location)
        {
            ResourceGroupCollection resourceGroupCollection = subscription.GetResourceGroups();
            ResourceGroupData resourceGroupData = new(location);
            ResourceGroupResource resourceGroup =
                (await resourceGroupCollection.CreateOrUpdateAsync(WaitUntil.Completed, resourceGroupName, resourceGroupData)).Value;

            return resourceGroup;
        }

        static async Task DeleteResourceGroup(SubscriptionResource subscription, string resourceGroupName)
        {
            ResourceGroupCollection resourceGroupCollection = subscription.GetResourceGroups();
            ResourceGroupResource resourceGroup = await resourceGroupCollection.GetAsync(resourceGroupName);
            await resourceGroup.DeleteAsync(WaitUntil.Completed);
        }


        static async Task<StorageAccountResource> CreateStorageAccount(string storageAccountName, ResourceGroupResource resourceGroup)
        {
            StorageAccountCreateOrUpdateContent parameters = GetStorageAccountCreateOrUpdateContent();
            parameters.AllowBlobPublicAccess = true;
            StorageAccountCollection storageAccountCollection = resourceGroup.GetStorageAccounts();
            StorageAccountResource storageAccount =
                (await storageAccountCollection.CreateOrUpdateAsync(WaitUntil.Completed, storageAccountName, parameters)).Value;

            return storageAccount;
        }

        static StorageAccountCreateOrUpdateContent GetStorageAccountCreateOrUpdateContent()
        {
            StorageSku sku = new StorageSku(StorageSkuName.StandardGrs);
            StorageKind kind = StorageKind.StorageV2;

            return new(sku, kind, location);
        }

        static async Task<BlobContainerClient> CreateContainer(string accountName, string containerName)
        {
            BlobServiceClient client = new(
                new Uri($"https://{accountName}.blob.core.windows.net"),
                new DefaultAzureCredential());

            var container = client.GetBlobContainerClient(containerName);
            await container.CreateIfNotExistsAsync(PublicAccessType.Blob);
            return container;
        }

        static async Task CreateFile(string filename)
        {
            await File.WriteAllTextAsync(filename, "test upload blod");
        }

        static async Task UploadBlob(BlobContainerClient container, string localFilePath, string accountKey)
        {
            string filename = Path.GetFileName(localFilePath);
            var credentials = new StorageSharedKeyCredential(container.AccountName, accountKey);
            var blobUri = new Uri($"https://{container.AccountName}.blob.core.windows.net/{container.Name}/{filename}");
            BlobClient blobClient = new(blobUri, credentials);
            await blobClient.UploadAsync(localFilePath);
        }

        MainAsync().Wait();
    }
}