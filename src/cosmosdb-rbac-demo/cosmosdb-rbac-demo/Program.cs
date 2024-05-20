using Azure.Identity;
using Microsoft.Azure.Cosmos;

namespace cosmosdb_rbac_demo
{
    internal class Program
    {
        static void Main(string[] args)
        {
            // Don't do this - use AppSettings (I'm just being lazy for demo purposes)
            var accountEndpoint = "https://dsrbuildcosmos2024.documents.azure.com:443/";

            var managedIdentity = new DefaultAzureCredential();
            CosmosClient client = new CosmosClient(accountEndpoint, managedIdentity);

            // Read the record with id = 1 from the people container in the humanresourcesapp database
            var database = client.GetDatabase("humanresourcesapp");
            var container = database.GetContainer("people");
            var response = container.ReadItemAsync<dynamic>("1", new PartitionKey("1")).Result;
            var item = response.Resource;

            // Display the person record with a nice heading
            System.Console.WriteLine("Person record:");
            System.Console.WriteLine(item);

            // Now try to read the record with id = 1 from the performancereviews container in the humanresourcesapp database
            container = database.GetContainer("performancereviews");
            response = container.ReadItemAsync<dynamic>("1", new PartitionKey("1")).Result;
            item = response.Resource;

            // Display the performance review record with a nice heading
            System.Console.WriteLine(
                "This line will not be executed because the code will throw an exception when trying to read the record from the performancereviews container.");
            System.Console.WriteLine(item);
        }
    }
}
