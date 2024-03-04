using Microsoft.Azure.Cosmos;

public class Program
{
    public static void Main(string[] args)
    {
        MainAsync(args).GetAwaiter().GetResult();
    }


    public static async Task MainAsync(string[] args)
    {
        // Set endpoint uri here
        var endpoint = "#endpoint#";
        // Set account primary key here
        var primaryMasterKey = "#primaryMasterKey#";

        // create cosmosdb client 
        using CosmosClient client = new(
            accountEndpoint: endpoint,
            authKeyOrResourceToken: primaryMasterKey
        );

        // create database
        Database database = await client.CreateDatabaseIfNotExistsAsync(id: "e-com");

        // create container
        Container container = await database.CreateContainerIfNotExistsAsync(id: "products", partitionKeyPath: "/category",
            throughput: 400);

        // create item
        Product item = new(
            id: "1",
            category: "food",
            name: "tomato",
            price: 0.65M,
            quantity: 100
        );
        Product createdItem = await container.UpsertItemAsync(item: item,
            partitionKey: new PartitionKey("food"));

        // read created item
        var tomatoItem = (await container.ReadItemAsync<Product>(id: "1", new PartitionKey("food"))).Resource;
        Console.WriteLine(tomatoItem);
    }
}

public record Product
(
    string id,
    string category,
    string name,
    decimal price,
    int quantity
);