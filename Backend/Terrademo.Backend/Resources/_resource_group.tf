# Author: Aneal Roney
# Title: Resource Group
# Description: This is the required resource group that must be included with every creation.

variable "sqlsrvname" { }
variable "sqlsrvuser" { }
variable "sqlsrvpw" { }
variable "sqldbname" { }

resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_resource_group" "test" {
  name     = "${var.rgroup}-${random_integer.ri.result}"
  location = "${var.location}"   # "West US"
}