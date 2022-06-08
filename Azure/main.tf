provider "azurerm" {
  features {}
  client_id                   = var.azure_client_id
  client_certificate_path     = var.client_certificate_path
  client_certificate_password = var.client_certificate_password
  subscription_id             = var.azure_subscription_id
  tenant_id                   = var.azure_tenant_id
}

resource "azurerm_resource_group" "main" {
  name     = format("%s-rg", var.prefix)
  location = var.location
}
