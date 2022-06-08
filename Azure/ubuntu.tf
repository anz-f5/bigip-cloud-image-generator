resource "azurerm_network_interface" "ubuntu-ext-nic" {
  name                = "${var.prefix}-ubuntu-ext-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "ubuntu-ext"
    subnet_id                     = azurerm_subnet.subnets[1].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips["ubuntu-ext"]
    public_ip_address_id          = azurerm_public_ip.pips[2].id
  }
}

resource "azurerm_network_interface_security_group_association" "ubuntu-ext-nic-ass" {
  network_interface_id      = azurerm_network_interface.ubuntu-ext-nic.id
  network_security_group_id = azurerm_network_security_group.default-nsg.id
}

resource "azurerm_linux_virtual_machine" "ubuntu-vm" {
  name                            = "${var.prefix}-ubuntu-vm"
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  network_interface_ids           = [azurerm_network_interface.ubuntu-ext-nic.id]
  size                            = var.ubuntu-instance-type
  admin_username                  = "ubuntu"
  disable_password_authentication = true
  computer_name                   = "${var.prefix}-ubuntu-vm"

  os_disk {
    name                 = "${var.prefix}-ubuntu-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = "200"
  }

  admin_ssh_key {
    username   = "ubuntu"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_dev_test_global_vm_shutdown_schedule" "pm7" {
  virtual_machine_id = azurerm_linux_virtual_machine.ubuntu-vm.id
  location           = azurerm_resource_group.main.location
  enabled            = true

  daily_recurrence_time = "1900"
  timezone              = "AUS Eastern Standard Time"

  notification_settings {
    enabled = false
  }
}

