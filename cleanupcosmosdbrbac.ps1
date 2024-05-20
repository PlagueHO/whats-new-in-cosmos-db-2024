# Connect-AzAccount

# Set subscription
Set-AzContext -Subscription 'dascottr_demo'

# Create a custom role on the Account (roles are created on the Cosmos DB account)
$resourceGroupName = "dsr-buildcosmos2024-rg"
$accountName = "dsrbuildcosmos2024"

$customPersonRoleName = 'Person Basic Reader'
$customMetadataRoleName = 'Account Metadata Reader'

# Check the role has been created
$roleDefinitions = Get-AzCosmosDBSqlRoleDefinition -AccountName $accountName `
    -ResourceGroupName $resourceGroupName

# Get the role definition ids
$customMetadataRoleDefinitionId = $roleDefinitions | Where-Object { $_.RoleName -eq $customMetadataRoleName } | Select-Object -ExpandProperty Id
$customPersonRoleDefinitionId = $roleDefinitions | Where-Object { $_.RoleName -eq $customPersonRoleName } | Select-Object -ExpandProperty Id

# Remove all the role assignments from the account
$roleAssignments = Get-AzCosmosDBSqlRoleAssignment -AccountName $accountName `
    -ResourceGroupName $resourceGroupName

foreach ($roleAssignment in $roleAssignments) {
    Remove-AzCosmosDBSqlRoleAssignment -AccountName $accountName `
        -ResourceGroupName $resourceGroupName `
        -Id $roleAssignment.Id
}

# Remove the account metadata rader role definition
if ($customMetadataRoleDefinitionId) {
    Remove-AzCosmosDBSqlRoleDefinition -AccountName $accountName `
        -ResourceGroupName $resourceGroupName `
        -Id $customMetadataRoleDefinitionId
}

# Remove the person basic reader role definition
if ($customPersonRoleDefinitionId) {
    Remove-AzCosmosDBSqlRoleDefinition -AccountName $accountName `
        -ResourceGroupName $resourceGroupName `
        -Id $customPersonRoleDefinitionId
}
