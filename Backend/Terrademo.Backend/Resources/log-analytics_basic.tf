# Author: GitHub Examples
# Title: Log Analytics Workspace
# Description: This example provisions a Log Analytics Workspace.

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "${var.prefix}-laworkspace"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  sku                 = "PerGB2018"
}
