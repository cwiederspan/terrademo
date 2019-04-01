# Author: GitHub Examples
# Title: Provisioner over SSH to a Linux Virtual Machine
# Description: This example provisions a Virtual Machine running Ubuntu 16.04-LTS with a Public IP Address and [runs a `remote-exec` provisioner](https://www.terraform.io/docs/provisioners/remote-exec.html) over SSH.

Notes:

- The files involved in this example are split out to make it easier to read, however all of the resources could be combined into a single file if needed.

resource "azurerm_virtual_machine" "example" {
  name                  = "${local.virtual_machine_name}"
  location              = "${azurerm_resource_group.example.location}"
  resource_group_name   = "${azurerm_resource_group.example.name}"
  network_interface_ids = ["${azurerm_network_interface.example.id}"]
  vm_size               = "Standard_F2"

  # This means the OS Disk will be deleted when Terraform destroys the Virtual Machine
  # NOTE: This may not be optimal in all cases.
  delete_os_disk_on_termination = true

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "${var.prefix}-osdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "${local.virtual_machine_name}"
    admin_username = "${local.admin_username}"
    admin_password = "${local.admin_password}"
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  provisioner "remote-exec" {
    connection {
      user     = "${local.admin_username}"
      password = "${local.admin_password}"
    }

    inline = [
      "ls -la",
    ]
  }
}
