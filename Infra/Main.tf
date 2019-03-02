variable "resource_group_name" { }

variable "container_registry_name" { }

variable "app_service_plan_name" { }

variable "backend_app_name" { }

variable "location" { }

resource "azurerm_resource_group" "group" {
  name     = "${var.resource_group_name}"
  location = "${var.location}"
}

resource "azurerm_container_registry" "acr" {
  name                = "${var.container_registry_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  admin_enabled       = true
  sku                 = "Basic"
}

resource "azurerm_app_service_plan" "plan" {
  name                = "${var.app_service_plan_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "app" {
  name                = "${var.backend_app_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  app_service_plan_id = "${azurerm_app_service_plan.plan.id}"
  # kind                = "app,linux,container"
  
  site_config {
    always_on         = true
    linux_fx_version  = "DOCKER|${azurerm_container_registry.acr.name}.azurecr.io/backend/resources:latest"
    # default_documents = [ "Index.html" ]
  }
  
  app_settings {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    DOCKER_REGISTRY_SERVER_URL          = "https://${azurerm_container_registry.acr.name}.azurecr.io"
    DOCKER_CUSTOM_IMAGE_NAME            = "https://${azurerm_container_registry.acr.name}.azurecr.io/backend/resources:latest"
    DOCKER_REGISTRY_SERVER_USERNAME     = "${azurerm_container_registry.acr.name}"
    DOCKER_REGISTRY_SERVER_PASSWORD     = "${azurerm_container_registry.acr.admin_password}"
  }
}