# Author: GitHub Examples
# Title: Virtual Machines : Spark And Cassandra On Centos
# Description: # Spark & Cassandra on CentOS 7.x

This Terraform template was based on [this](https://github.com/Azure/azure-quickstart-templates/tree/master/spark-and-cassandra-on-centos) Azure Quickstart Template. Changes to the ARM template that may have occurred since the creation of this example may not be reflected here.

This project configures a Spark cluster (1 master and n-slave nodes) and a single node Cassandra on Azure using CentOS 7.x.  The base image starts with CentOS 7.3, and it is updated to the latest version as part of the provisioning steps.

Please note that [Azure Resource Manager][3] is used to provision the environment.

### Software ###

| Category | Software | Version | Notes |
| --- | --- | --- | --- |
| Operating System | CentOS | 7.x | Based on CentOS 7.1 but it will be auto upgraded to the lastest point release |
| Java | OpenJDK | 1.8.0 | Installed on all servers |
| Spark | Spark | 1.6.0 with Hadoop 2.6 | The installation contains libraries needed for Hadoop 2.6 |
| Cassandra | Cassandra | 3.2 | Installed through DataStax's YUM repository |


### Defaults ###

| Component | Setting | Default | Notes |
| --- | --- | --- | --- |
| Spark - Master | VM Size | Standard D1 V2 | |
| Spark - Master | Storage | Standard LRS | |
| Spark - Master | Internal IP | 10.0.0.5 | |
| Spark - Master | Service User Account | spark | Password-less access |
| | | |
| Spark - Slave | VM Size | Standard D3 V2 | |
| Spark - Slave | Storage | Standard LRS | |
| Spark - Slave | Internal IP Range | 10.0.1.5 - 10.0.1.255 | |
| Spark - Slave | # of Nodes | 2 | Maximum of 200 |
| Spark - Slave | Availability | 2 fault domains, 5 update domains | |
| Spark - Slave | Service User Account | spark | Password-less access |
| | | |
| Cassandra | VM Size | Standard D3 V2 | |
| Cassandra | Storage | Standard LRS | |
| Cassandra | Internal IP | 10.2.0.5 | |
| Cassandra | Service User Account | cassandra | Password-less access |

## Prerequisites

1.  Ensure you have an Azure subscription.  
2.  Ensure you have enough available vCPU cores on your subscription.  Otherwise, you will receive an error during the process.  The number of cores can be increased through a support ticket in Azure Portal.

## main.tf
The `main.tf` file contains the actual resources that will be deployed. It also contains the Azure Resource Group definition and any defined variables.

## outputs.tf
This data is outputted when `terraform apply` is called, and can be queried using the `terraform output` command.

## provider.tf
Azure requires that an application is added to Azure Active Directory to generate the `client_id`, `client_secret`, and `tenant_id` needed by Terraform (`subscription_id` can be recovered from your Azure account details). Please go [here](https://www.terraform.io/docs/providers/azurerm/) for full instructions on how to create this to populate your `provider.tf` file.

## terraform.tfvars
If a `terraform.tfvars` or any `.auto.tfvars` files are present in the current directory, Terraform automatically loads them to populate variables. We don't recommend saving usernames and password to version control, but you can create a local secret variables file and use the `-var-file` flag or the `.auto.tfvars` extension to load it.

If you are committing this template to source control, please insure that you add this file to your `.gitignore` file.

## variables.tf
The `variables.tf` file contains all of the input parameters that the user can specify when deploying this Terraform template.

## Post-Deployment

1. All servers will have a public IP and SSH port enabled by default. These can be disabled or modified in the template or by using Azure Portal.
2. All servers are configured with the same username and password. You may SSH into each server and ensure connectivity.
3. Spark WebUI is running on **port 8080**.  Access it using MASTER_WEB_UI_PUBLIC_IP:8080 on your browser.  Public IP is available in the outputs as well as through Azure Portal.
4. Delete the Resource Group that was created to stage the provisioning scripts.


# provider "azurerm" {
#   subscription_id = "${var.subscription_id}"
#   client_id       = "${var.client_id}"
#   client_secret   = "${var.client_secret}"
#   tenant_id       = "${var.tenant_id}"
# }

resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# **********************  NETWORK SECURITY GROUPS ********************** #
resource "azurerm_network_security_group" "master" {
  name                = "${var.nsg_spark_master_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http_webui_spark"
    description                = "Allow Web UI Access to Spark"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "http_rest_spark"
    description                = "Allow REST API Access to Spark"
    priority                   = 102
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "6066"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "slave" {
  name                = "${var.nsg_spark_slave_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "cassandra" {
  name                = "${var.nsg_cassandra_name}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "ssh"
    description                = "Allow SSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }
}

# **********************  VNET / SUBNETS ********************** #
resource "azurerm_virtual_network" "spark" {
  name                = "vnet-spark"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"
  address_space       = ["${var.vnet_spark_prefix}"]
}

resource "azurerm_subnet" "subnet1" {
  name                      = "${var.vnet_spark_subnet1_name}"
  virtual_network_name      = "${azurerm_virtual_network.spark.name}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  address_prefix            = "${var.vnet_spark_subnet1_prefix}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"
  depends_on                = ["azurerm_virtual_network.spark"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "${var.vnet_spark_subnet2_name}"
  virtual_network_name = "${azurerm_virtual_network.spark.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.vnet_spark_subnet2_prefix}"
}

resource "azurerm_subnet" "subnet3" {
  name                 = "${var.vnet_spark_subnet3_name}"
  virtual_network_name = "${azurerm_virtual_network.spark.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.vnet_spark_subnet3_prefix}"
}

# **********************  PUBLIC IP ADDRESSES ********************** #
resource "azurerm_public_ip" "master" {
  name                         = "${var.public_ip_master_name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
}

resource "azurerm_public_ip" "slave" {
  name                         = "${var.public_ip_slave_name_prefix}${count.index}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
  count                        = "${var.vm_number_of_slaves}"
}

resource "azurerm_public_ip" "cassandra" {
  name                         = "${var.public_ip_cassandra_name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method = "Static"
}

# **********************  NETWORK INTERFACE ********************** #
resource "azurerm_network_interface" "master" {
  name                      = "${var.nic_master_name}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.master.id}"
  depends_on                = ["azurerm_virtual_network.spark", "azurerm_public_ip.master", "azurerm_network_security_group.master"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet1.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.nic_master_node_ip}"
    public_ip_address_id          = "${azurerm_public_ip.master.id}"
  }
}

resource "azurerm_network_interface" "slave" {
  name                      = "${var.nic_slave_name_prefix}${count.index}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.slave.id}"
  count                     = "${var.vm_number_of_slaves}"
  depends_on                = ["azurerm_virtual_network.spark", "azurerm_public_ip.slave", "azurerm_network_security_group.slave"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet2.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.nic_slave_node_ip_prefix}${5 + count.index}"
    public_ip_address_id          = "${element(azurerm_public_ip.slave.*.id, count.index)}"
  }
}

resource "azurerm_network_interface" "cassandra" {
  name                      = "${var.nic_cassandra_name}"
  location                  = "${azurerm_resource_group.rg.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.cassandra.id}"
  depends_on                = ["azurerm_virtual_network.spark", "azurerm_public_ip.cassandra", "azurerm_network_security_group.cassandra"]

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "${azurerm_subnet.subnet3.id}"
    private_ip_address_allocation = "Static"
    private_ip_address            = "${var.nic_cassandra_node_ip}"
    public_ip_address_id          = "${azurerm_public_ip.cassandra.id}"
  }
}

# **********************  AVAILABILITY SET ********************** #
resource "azurerm_availability_set" "slave" {
  name                         = "${var.availability_slave_name}"
  location                     = "${azurerm_resource_group.rg.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  platform_update_domain_count = 5
  platform_fault_domain_count  = 2
}

# **********************  STORAGE ACCOUNTS ********************** #
resource "azurerm_storage_account" "master" {
  name                     = "master${var.unique_prefix}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "${var.storage_master_account_tier}"
  account_replication_type = "${var.storage_master_replication_type}"
}

resource "azurerm_storage_container" "master" {
  name                  = "${var.vm_master_storage_account_container_name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.master.name}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.master"]
}

resource "azurerm_storage_account" "slave" {
  name                     = "slave${var.unique_prefix}${count.index}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  count                    = "${var.vm_number_of_slaves}"
  account_tier             = "${var.storage_slave_account_tier}"
  account_replication_type = "${var.storage_slave_replication_type}"
}

resource "azurerm_storage_container" "slave" {
  name                  = "${var.vm_slave_storage_account_container_name}${count.index}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${element(azurerm_storage_account.slave.*.name, count.index)}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.slave"]
}

resource "azurerm_storage_account" "cassandra" {
  name                     = "cassandra${var.unique_prefix}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  location                 = "${azurerm_resource_group.rg.location}"
  account_tier             = "${var.storage_cassandra_account_tier}"
  account_replication_type = "${var.storage_cassandra_replication_type}"
}

resource "azurerm_storage_container" "cassandra" {
  name                  = "${var.vm_cassandra_storage_account_container_name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  storage_account_name  = "${azurerm_storage_account.cassandra.name}"
  container_access_type = "private"
  depends_on            = ["azurerm_storage_account.cassandra"]
}

# ********************** MASTER VIRTUAL MACHINE ********************** #
resource "azurerm_virtual_machine" "master" {
  name                  = "${var.vm_master_name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  vm_size               = "${var.vm_master_vm_size}"
  network_interface_ids = ["${azurerm_network_interface.master.id}"]
  depends_on            = ["azurerm_storage_account.master", "azurerm_network_interface.master", "azurerm_storage_container.master"]

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_version}"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_master_os_disk_name}"
    vhd_uri       = "http://${azurerm_storage_account.master.name}.blob.core.windows.net/${azurerm_storage_container.master.name}/${var.vm_master_os_disk_name}.vhd"
    create_option = "FromImage"
    caching       = "ReadWrite"
  }

  os_profile {
    computer_name  = "${var.vm_master_name}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = "${azurerm_public_ip.master.ip_address}"
    user     = "${var.vm_admin_username}"
    password = "${var.vm_admin_password}"
  }

  provisioner "remote-exec" {
    inline = [
      "wget ${var.artifacts_location}${var.script_spark_provisioner_script_file_name}",
      "echo ${var.vm_admin_password} | sudo -S sh ./${var.script_spark_provisioner_script_file_name} -runas=master -master=${var.nic_master_node_ip}",
    ]
  }
}

# ********************** SLAVE VIRTUAL MACHINES ********************** #
resource "azurerm_virtual_machine" "slave" {
  name                  = "${var.vm_slave_name_prefix}${count.index}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  vm_size               = "${var.vm_slave_vm_size}"
  network_interface_ids = ["${element(azurerm_network_interface.slave.*.id, count.index)}"]
  count                 = "${var.vm_number_of_slaves}"
  availability_set_id   = "${azurerm_availability_set.slave.id}"
  depends_on            = ["azurerm_storage_account.slave", "azurerm_network_interface.slave", "azurerm_storage_container.slave"]

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_version}"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_slave_os_disk_name_prefix}${count.index}"
    vhd_uri       = "http://${element(azurerm_storage_account.slave.*.name, count.index)}.blob.core.windows.net/${element(azurerm_storage_container.slave.*.name, count.index)}/${var.vm_slave_os_disk_name_prefix}.vhd"
    create_option = "FromImage"
    caching       = "ReadWrite"
  }

  os_profile {
    computer_name  = "${var.vm_slave_name_prefix}${count.index}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = "${element(azurerm_public_ip.slave.*.ip_address, count.index)}"
    user     = "${var.vm_admin_username}"
    password = "${var.vm_admin_password}"
  }

  provisioner "remote-exec" {
    inline = [
      "wget ${var.artifacts_location}${var.script_spark_provisioner_script_file_name}",
      "echo ${var.vm_admin_password} | sudo -S sh ./${var.script_spark_provisioner_script_file_name} -runas=slave -master=${var.nic_master_node_ip}",
    ]
  }
}

# ********************** CASSANDRA VIRTUAL MACHINE ********************** #
resource "azurerm_virtual_machine" "cassandra" {
  name                  = "${var.vm_cassandra_name}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  location              = "${azurerm_resource_group.rg.location}"
  vm_size               = "${var.vm_cassandra_vm_size}"
  network_interface_ids = ["${azurerm_network_interface.cassandra.id}"]
  depends_on            = ["azurerm_storage_account.cassandra", "azurerm_network_interface.cassandra", "azurerm_storage_container.cassandra"]

  storage_image_reference {
    publisher = "${var.os_image_publisher}"
    offer     = "${var.os_image_offer}"
    sku       = "${var.os_version}"
    version   = "latest"
  }

  storage_os_disk {
    name          = "${var.vm_cassandra_os_disk_name}"
    vhd_uri       = "http://${azurerm_storage_account.cassandra.name}.blob.core.windows.net/${azurerm_storage_container.cassandra.name}/${var.vm_cassandra_os_disk_name}.vhd"
    create_option = "FromImage"
    caching       = "ReadWrite"
  }

  os_profile {
    computer_name  = "${var.vm_cassandra_name}"
    admin_username = "${var.vm_admin_username}"
    admin_password = "${var.vm_admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  connection {
    type     = "ssh"
    host     = "${azurerm_public_ip.cassandra.ip_address}"
    user     = "${var.vm_admin_username}"
    password = "${var.vm_admin_password}"
  }

  provisioner "remote-exec" {
    inline = [
      "wget ${var.artifacts_location}${var.script_cassandra_provisioner_script_file_name}",
      "echo ${var.vm_admin_password} | sudo -S sh ./${var.script_cassandra_provisioner_script_file_name}",
    ]
  }
}
