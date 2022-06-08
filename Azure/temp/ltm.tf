resource "azurerm_network_interface" "ltm-mgmt-nic" {
  name                = "${var.prefix}-ltm-mgmt-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "mgmt"
    subnet_id                     = azurerm_subnet.subnets[0].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips["ltm-mgmt"]
    public_ip_address_id          = azurerm_public_ip.pips[0].id
  }
}

resource "azurerm_network_interface" "ltm-ext-nic" {
  name                = "${var.prefix}-ltm-ext-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "self-ip"
    subnet_id                     = azurerm_subnet.subnets[1].id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.ips["ltm-ext"]
    public_ip_address_id          = azurerm_public_ip.pips[1].id
  }
}

data "template_file" "vm-onboard" {
  template = file("${path.module}/onboard.tpl")

  vars = {
    admin_user     = var.username
    admin_password = var.password
    DO_URL         = var.DO-URL
    AS3_URL        = var.AS3-URL
    TS_URL         = var.TS-URL
    CF_URL         = var.CF-URL
    libs_dir       = var.libs-dir
    onboard_log    = var.onboard-log
    mgmt_gw        = var.mgmt-gw
  }
}

data "azurerm_image" "search" {
  name                = "F5-BIGIP-16.1.2.2-0.0.28-BYOL-all-1slot-B2QYMTXAH"
  resource_group_name = "cz-image-generator-rg"
}

resource "azurerm_linux_virtual_machine" "ltm-vm" {
  name                = "${var.prefix}-ltm-vm"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [
  azurerm_network_interface.ltm-mgmt-nic.id, azurerm_network_interface.ltm-ext-nic.id]
  size                            = var.ltm-instance-type
  admin_username                  = var.username
  disable_password_authentication = true
  computer_name                   = "${var.prefix}-ltm-vm"
  custom_data                     = base64encode(data.template_file.vm-onboard.rendered)
  source_image_id                 = data.azurerm_image.search.id

  os_disk {
    name                 = "${var.prefix}-ltm-vm-osdisk"
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  tags = {
    for k, v in merge({
      Name = "${var.prefix}-bigip-vm"
      },
    var.default_vm_tags) : k => v
  }

}

resource "azurerm_network_interface_security_group_association" "ltm-mgmt-ass" {
  network_interface_id      = azurerm_network_interface.ltm-mgmt-nic.id
  network_security_group_id = azurerm_network_security_group.default-nsg.id
}

resource "azurerm_network_interface_security_group_association" "ltm-ext-ass" {
  network_interface_id      = azurerm_network_interface.ltm-ext-nic.id
  network_security_group_id = azurerm_network_security_group.default-nsg.id
}
