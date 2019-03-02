# Author: Aneal Roney
# Title: Databricks Workspace
# Description: This creates an azure databricks workspace in the target resource group. * NOTE: This does not create databricks clusters. *

resource "azurerm_databricks_workspace" "test" {
  name                = "databricks-test"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${var.location}"
  sku                 = "standard"
}
#resource "azurerm_storage_account" "testsa" {
#  name                     = "storageaccountname"
#  resource_group_name      = "${azurerm_resource_group.test.name}"
#  location                 = "${var.location}"
#  account_tier             = "Standard"
#  account_replication_type = "LRS" 
#}
