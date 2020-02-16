# Author: GitHub Examples
# Title: Linux App Service running multiple containers from a Kubernetes Manifest
# Description: This example provisions a Linux App Service which runs multiple Docker Containers from a Kubernetes Manifest.

### Notes

* The Container is launched on the first HTTP Request, which can take a while.
* If you're not using App Service Slots and Deployments are handled outside of Terraform - [it's possible to ignore changes to specific fields in the configuration using `ignore_changes` within Terraform's `lifecycle` block](https://www.terraform.io/docs/configuration/resources.html#lifecycle), for example:

```hcl
resource "azurerm_app_service" "test" {
  # ...
  site_config = {
    # ...
    linux_fx_version = "KUBE|${base64encode(file("kubernetes.yml"))}"
  }

  lifecycle {
    ignore_changes = [
      "site_config.0.linux_fx_version", # deployments are made outside of Terraform
    ]
  }
}
```

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-resources"
  location = "${var.location}"
}

resource "azurerm_app_service_plan" "main" {
  name                = "${var.prefix}-asp"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "main" {
  name                = "${var.prefix}-appservice"
  location            = "${azurerm_resource_group.main.location}"
  resource_group_name = "${azurerm_resource_group.main.name}"
  app_service_plan_id = "${azurerm_app_service_plan.main.id}"

  site_config {
    app_command_line = ""
    linux_fx_version = "KUBE|${base64encode(file("kubernetes.yml"))}"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}
