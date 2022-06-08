resource "azurerm_network_security_group" "default-nsg" {
  name                = "${var.prefix}-default-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow_me"
    description                = "Allow me"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefixes    = [var.my-ip]
    destination_address_prefix = "*"
  }
}
