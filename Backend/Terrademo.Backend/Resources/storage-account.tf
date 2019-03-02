# Author: Aneal Roney
# Title: Blob Storage Account
# Description: This creates a blob storage account in the target resource group.

resource "azurerm_storage_account" "testsa" {
  name                     = "storagetf${random_integer.ri.result}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS" 
}
