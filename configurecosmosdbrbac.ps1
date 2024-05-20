# Connect-AzAccount

# Set subscription
Set-AzContext -Subscription 'dascottr_demo'

# Create a custom role on the Account (roles are created on the Cosmos DB account)
$resourceGroupName = "dsr-buildcosmos2024-rg"
$accountName = "dsrbuildcosmos2024"

# Database name
$databaseName = 'humanresourcesapp'

<#
    For Service Principals make sure to use the Object ID as found in
    the Enterprise applications section of the Azure Active Directory portal blade.
#>
$principalId = "4af0c502-25ab-4e72-bc41-175d26f90be2" # This is for the VM that will be running code to connect to Cosmos DB
# $principalId = "332ae06d-8527-4059-908d-08d1c8de7b38" # This my demo princpal

# The name of the custom RBAC role we'll assign to the service principal of our app/VM
$customPersonRoleName = 'Person Basic Reader'
$customMetadataRoleName = 'Account Metadata Reader'

# See the build in RBAC roles (reader and contributor)
Get-AzCosmosDBSqlRoleDefinition `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName

# Create a new role to read account metadata
New-AzCosmosDBSqlRoleDefinition `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName `
    -RoleName $customMetadataRoleName `
    -Type CustomRole `
    -DataAction @( `
        'Microsoft.DocumentDB/databaseAccounts/readMetadata') `
    -AssignableScope "/"

# Create a new role that can also read container items
New-AzCosmosDBSqlRoleDefinition `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName `
    -RoleName $customPersonRoleName `
    -Type CustomRole `
    -DataAction @( `
        'Microsoft.DocumentDB/databaseAccounts/readMetadata',
        'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read') `
    -AssignableScope "/"

# Check the role has been created
$roleDefinitions = Get-AzCosmosDBSqlRoleDefinition `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName

# Show on screen
$roleDefintions

# Get the role definition ids
$customMetadataRoleDefinitionId = $roleDefinitions | Where-Object { $_.RoleName -eq $customMetadataRoleName } | Select-Object -ExpandProperty Id
$customPersonRoleDefinitionId = $roleDefinitions | Where-Object { $_.RoleName -eq $customPersonRoleName } | Select-Object -ExpandProperty Id

# Add a role to the account scope - this is required because SDKs need to be able to read account metadata
New-AzCosmosDBSqlRoleAssignment `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName `
    -RoleDefinitionId $customMetadataRoleDefinitionId `
    -Scope "/" `
    -PrincipalId $principalId

# # Add a role to the people container scope
# $peopleContainerScope = "/dbs/$databaseName/colls/people"

# New-AzCosmosDBSqlRoleAssignment `
#     -AccountName $accountName `
#     -ResourceGroupName $resourceGroupName `
#     -RoleDefinitionId $customPersonRoleDefinitionId `
#     -Scope $peopleContainerScope `
#     -PrincipalId $principalId

# Add a role to the be able to read all containers in all databases (see scope and built-in role def)!
New-AzCosmosDBSqlRoleAssignment `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName `
    -RoleDefinitionId '00000000-0000-0000-0000-000000000001' `
    -Scope "/" `
    -PrincipalId $principalId

# Display the role assignments
Get-AzCosmosDBSqlRoleAssignment `
    -AccountName $accountName `
    -ResourceGroupName $resourceGroupName
