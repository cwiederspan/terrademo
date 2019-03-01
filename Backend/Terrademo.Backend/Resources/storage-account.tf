resource "azurerm_storage_account" "testsa" {
  name                     = "storagetf${random_integer.ri.result}"
  resource_group_name      = "${azurerm_resource_group.test.name}"
  location                 = "${var.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS" 
}
