# Author: GitHub Examples
# Title: CDN Profile / Endpoint
# Description: This example provisions a CDN Profile and a CDN Endpoint.

## Please Note

The endpoint will not immediately be available for use, as it takes time for the registration to propagate through the CDN. For Azure CDN from Akamai profiles, propagation will usually complete within one minute. For Azure CDN from Verizon profiles, propagation will usually complete within 90 minutes, but in some cases can take longer.

Users who try to use the CDN domain name before the endpoint configuration has propagated to the POPs will receive HTTP 404 response codes. If it has been several hours since you created your endpoint and you're still receiving 404 responses, please see [Troubleshooting CDN endpoints returning 404 statuses](https://docs.microsoft.com/en-us/azure/cdn/cdn-troubleshoot-endpoint).

resource "azurerm_resource_group" "example" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_storage_account" "stor" {
  name                     = "${var.prefix}stor"
  location                 = "${azurerm_resource_group.example.location}"
  resource_group_name      = "${azurerm_resource_group.example.name}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_cdn_profile" "example" {
  name                = "${var.prefix}-cdn"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"
  sku                 = "Standard_Akamai"
}

resource "azurerm_cdn_endpoint" "example" {
  name                = "${var.prefix}-cdn"
  profile_name        = "${azurerm_cdn_profile.example.name}"
  location            = "${azurerm_resource_group.example.location}"
  resource_group_name = "${azurerm_resource_group.example.name}"

  origin {
    name       = "${var.prefix}origin1"
    host_name  = "www.example.com"
    http_port  = 80
    https_port = 443
  }
}
