# Author: GitHub Examples
# Title: Azure Search
# Description: This example provisions an Azure Search Service.

This Terraform Configuration was based on [this](https://github.com/Azure/azure-quickstart-templates/tree/bf842409eeeeb7c4523add3922b204793eb4d85f/101-azure-search-create) Azure Quickstart Template. Changes to the ARM template that may have occurred since the creation of this example may not be reflected in this Terraform Configuration.

If you are unclear as to what parameters are allowed you can check the [Azure Search Management REST API docs on MSDN](https://msdn.microsoft.com/en-us/library/azure/dn832687.aspx).

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_search_service" "example" {
  name                = "${var.prefix}-search"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  sku                 = "standard"
  replica_count       = "1"
  partition_count     = "1"
}
