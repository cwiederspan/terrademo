# Author: Aneal Roney
# Title: Azure SQL DB
# Description: This creates an azure sql db and associated azure sql server.  This database is blank with NO sample data.

resource "azurerm_sql_server" "test" {
  name                         = "${var.sqlsrvname}${random_integer.ri.result}"
  resource_group_name          = "${azurerm_resource_group.test.name}"
  location                     = "${azurerm_resource_group.test.location}"   #"West US"
  version                      = "12.0"
  administrator_login          = "${var.sqlsrvuser}"
  administrator_login_password = "${var.sqlsrvpw}"
}
resource "azurerm_sql_database" "test" {
  name                = "${var.sqldbname}${random_integer.ri.result}"
  resource_group_name = "${azurerm_resource_group.test.name}"
  location            = "${azurerm_resource_group.test.location}"
  server_name         = "${azurerm_sql_server.test.name}"
}
  resource "azurerm_sql_firewall_rule" "test" {
  name                = "FirewallRule1"
  resource_group_name = "${azurerm_resource_group.test.name}"
  server_name         = "${azurerm_sql_server.test.name}"
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}