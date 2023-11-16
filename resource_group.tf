# Create a resource group to hold storage
resource "azurerm_resource_group" "rg" {
  count    = var.enable_azure_external_deploy ? 1 : 0
  name     = local.name_prefix
  location = var.location

  lifecycle {
    prevent_destroy = true
  }

  tags = var.tags
}
