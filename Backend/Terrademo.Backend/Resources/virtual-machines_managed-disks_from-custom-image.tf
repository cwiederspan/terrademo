# Author: GitHub Examples
# Title: Virtual Machine with Managed Disks from a Custom Image
# Description: This example provisions a Virtual Machine with Managed Disks from a Custom Image that already exists.

Notes:

- The files involved in this example are split out to make it easier to read, however all of the resources could be combined into a single file if needed.
- This example assumes the Custom Image specified exists - if it doesn't this example will fail.

### Variables

* `prefix` - (Required) The Prefix used for all resources in this example.
* `location` - (Required) The Azure Region in which the resources in this example should exist.
* `tags` - (Optional) Any tags which should be assigned to the resources in this example.

* `custom_image_resource_group_name` - (Required) The name of the Resource Group in which the Custom Image exists.
* `custom_image_name` - (Required) The name of the Custom Image to provision this Virtual Machine from.

# we assume that this Custom Image already exists
data "azurerm_image" "custom" {
  name                = "${var.custom_image_name}"
  resource_group_name = "${var.custom_image_resource_group_name}"
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

  storage_image_reference {
    id = "${data.azurerm_image.custom.id}"
  }

  storage_os_disk {
    name              = "osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
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
