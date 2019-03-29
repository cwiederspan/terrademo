variable "gateway_name" { }

variable "storage_name" { }

variable "gateway_instance_count" {
  default = 1
}

variable "public_ip_name" { }

variable "vnet_name" { }


# *** Start App Gateway *** #

resource "azurerm_storage_account" "storage" {
  name                     = "${var.storage_name}"
  resource_group_name      = "${azurerm_resource_group.group.name}"
  location                 = "${azurerm_resource_group.group.location}"
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
  
  provisioner "local-exec" {
    command = "az storage blob service-properties update --account-name ${azurerm_storage_account.storage.name} --static-website"
  }
}

resource "azurerm_storage_container" "container" {
  name                  = "certchallenge"
  resource_group_name   = "${azurerm_resource_group.group.name}"
  storage_account_name  = "${azurerm_storage_account.storage.name}"
  container_access_type = "blob"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.vnet_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  address_space       = ["10.10.0.0/16"]
}

resource "azurerm_subnet" "subnet" {
  name                 = "gateway-subnet"
  resource_group_name  = "${azurerm_resource_group.group.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.10.1.0/24"
}

resource "azurerm_public_ip" "ip" {
  name                = "${var.public_ip_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"
  domain_name_label   = "${var.gateway_name}"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# since these variables are re-used - a locals block makes this more maintainable
locals {

  backend_address_pool_name_www  = "${var.gateway_name}-bepool-www"
  backend_address_pool_name_api  = "${var.gateway_name}-bepool-api"
  backend_address_pool_name_util = "${var.gateway_name}-bepool-util"
  frontend_port_name             = "${var.gateway_name}-feport"
  frontend_ip_configuration_name = "${var.gateway_name}-feip"
  http_setting_name              = "${var.gateway_name}-http"
  listener_name                  = "${var.gateway_name}-lstn"
  probe_name                     = "${var.gateway_name}-probe"
  request_routing_rule_name      = "${var.gateway_name}-router"
  gateway_ip_config_name         = "${var.gateway_name}-ipconfig"
  url_path_map_name              = "${var.gateway_name}-urlpath"
  url_path_map_rule_name_api     = "${var.gateway_name}-urlrule-api"
  url_path_map_rule_name_util    = "${var.gateway_name}-urlrule-util"
}

resource "azurerm_application_gateway" "gateway" {
  name                = "${var.gateway_name}"
  resource_group_name = "${azurerm_resource_group.group.name}"
  location            = "${azurerm_resource_group.group.location}"

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = "${var.gateway_instance_count}"
  }

  gateway_ip_configuration {
    name      = "${local.gateway_ip_config_name}"
    subnet_id = "${azurerm_subnet.subnet.id}"
  }

  frontend_port {
    name = "${local.frontend_port_name}"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "${local.frontend_ip_configuration_name}"
    public_ip_address_id = "${azurerm_public_ip.ip.id}"
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name_www}"
    fqdns = ["${azurerm_app_service.frontend.default_site_hostname}"]
  }

  backend_address_pool {
    name  = "${local.backend_address_pool_name_api}"
    fqdns = ["${azurerm_app_service.backend.default_site_hostname}"]
  }

  # backend_address_pool {
  #   name  = "${local.backend_address_pool_name_util}"
  #   # fqdns = ["${var.storage_name}.blob.core.windows.net/${azurerm_storage_container.container.name}"]
  #   fqdns = ["${var.storage_name}.z5.web.core.windows.net"]   # Hard-coded for now, until azurerm can handle setting up static site in storage
  # }

  backend_http_settings {
    name                  = "${local.http_setting_name}"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "http"
    request_timeout       = 1
    probe_name            = "${local.probe_name}"
    pick_host_name_from_backend_address = "true"
  }

  http_listener {
    name                           = "${local.listener_name}"
    frontend_ip_configuration_name = "${local.frontend_ip_configuration_name}"
    frontend_port_name             = "${local.frontend_port_name}"
    protocol                       = "http"
  }

  probe {
    name                = "${local.probe_name}"
    protocol            = "http"
    path                = "/"
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = "true"
  }

  request_routing_rule {
    name                           = "${local.request_routing_rule_name}"
    rule_type                      = "PathBasedRouting"
    http_listener_name             = "${local.listener_name}"
    # backend_address_pool_name    = "${local.backend_address_pool_name}"   # Don't Use
    # backend_http_settings_name   = "${local.http_setting_name}"           # Don't Use
    url_path_map_name              = "${local.url_path_map_name}"
  }

  url_path_map {
    name                               = "${local.url_path_map_name}"
    default_backend_address_pool_name  = "${local.backend_address_pool_name_www}"
    default_backend_http_settings_name = "${local.http_setting_name}"
    
    path_rule {
      name                       = "${local.url_path_map_rule_name_api}"
      backend_address_pool_name  = "${local.backend_address_pool_name_api}"
      backend_http_settings_name = "${local.http_setting_name}"
      paths = [
        "/api/*",
      ]
    }
    
    # path_rule {
    #   name                       = "${local.url_path_map_rule_name_util}"
    #   backend_address_pool_name  = "${local.backend_address_pool_name_util}"
    #   backend_http_settings_name = "${local.http_setting_name}"
    #   paths = [
    #     "/.well-known/acme-challenge/*",
    #   ]
    # }
  }
}