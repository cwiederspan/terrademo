# Author: GitHub Examples
# Title: Logic App
# Description: This example provisions a Logic App within Azure which sends a `HTTP DELETE` every hour to a given URI.

### Variables

* `prefix` - (Required) The prefix used for all resources in this example.

* `location` - (Required) The Azure Region in which the Logic App should be created.

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_logic_app_workflow" "example" {
  name                = "${var.prefix}-logicapp"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
}

resource "azurerm_logic_app_trigger_recurrence" "hourly" {
  name         = "run-every-hour"
  logic_app_id = "${azurerm_logic_app_workflow.example.id}"
  frequency    = "Hour"
  interval     = 1
}

resource "azurerm_logic_app_action_http" "main" {
  name         = "clear-stale-objects"
  logic_app_id = "${azurerm_logic_app_workflow.example.id}"
  method       = "DELETE"
  uri          = "http://example.com/clear-stable-objects"
}
