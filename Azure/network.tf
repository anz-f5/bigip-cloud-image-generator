resource "azurerm_virtual_network" "core" {
  name                = "${var.prefix}-core"
  address_space       = [var.cidr]
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
}

resource "azurerm_subnet" "subnets" {
  count                = length(var.subnets)
  name                 = keys(var.subnets)[count.index]
  virtual_network_name = azurerm_virtual_network.core.name
  resource_group_name  = azurerm_resource_group.main.name
  address_prefixes     = [values(var.subnets)[count.index]]
}

resource "azurerm_public_ip" "pips" {
  count               = length(var.pips)
  name                = "${var.prefix}-${var.pips[count.index]}"
  location            = azurerm_resource_group.main.location
  sku                 = "Standard"
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
}




