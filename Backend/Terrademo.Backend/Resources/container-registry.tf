# Author: GitHub Examples
# Title: Azure Container Registry
# Description: This example provisions an Azure Container Registry

## Creates

1. A Resource Group
2. An [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/)

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_container_registry" "example" {
  name                = "${var.prefix}-registry"
  resource_group_name = "${azurerm_resource_group.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  sku                 = "Standard"
}
