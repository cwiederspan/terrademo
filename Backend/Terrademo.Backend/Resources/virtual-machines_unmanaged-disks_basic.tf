# Author: GitHub Examples
# Title: Virtual Machine with Unmanaged Disks
# Description: This example provisions a Virtual Machine with Unmanaged Disks, with one OS Disk and one Data Disk.

Notes:

- The files involved in this example are split out to make it easier to read, however all of the resources could be combined into a single file if needed.

### Variables

* `prefix` - (Required) The Prefix used for all resources in this example.
* `location` - (Required) The Azure Region in which the resources in this example should exist.
* `tags` - (Optional) Any tags which should be assigned to the resources in this example.

locals {
  storage_account_base_uri = "${azurerm_storage_account.example.primary_blob_endpoint}${azurerm_storage_container.example.name}"
}

resource "azurerm_virtual_machine" "example" {
  name                  = "${var.prefix}-vm"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_F2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  # This means the Data Disk Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_data_disks_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name          = "osdisk"
    vhd_uri       = "${local.storage_account_base_uri}/osdisk.vhd"
    caching       = "ReadWrite"
    create_option = "FromImage"
  }

  # Optional data disks
  storage_data_disk {
    name          = "datadisk1"
    vhd_uri       = "${local.storage_account_base_uri}/datadisk1.vhd"
    disk_size_gb  = "1023"
    create_option = "Empty"
    lun           = 0
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "testadmin"
    admin_password = "Password1234!"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }
}
