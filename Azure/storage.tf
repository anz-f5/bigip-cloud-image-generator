resource "azurerm_storage_account" "storage-account" {
  name                     = var.storageAcct
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    for k, v in merge({
      Name = "${var.prefix}-stotageAcct"
      },
    var.default_vm_tags) : k => v
  }
}

resource "azurerm_storage_container" "storage-container" {
  name                  = "${var.prefix}-container"
  storage_account_name  = azurerm_storage_account.storage-account.name
  container_access_type = "private"
}
