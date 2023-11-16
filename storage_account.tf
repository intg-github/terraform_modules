resource "random_string" "random" {
  count   = var.enable_velero_storage ? 1 : 0
  length  = 8
  upper   = false
  lower   = false
  special = false
  numeric = true
}

resource "azurerm_storage_account" "velero_storage" {
  count                           = var.enable_velero_storage ? 1 : 0
  name                            = "velero${random_string.random[0].result}"
  resource_group_name             = var.resource_group_name
  allow_nested_items_to_be_public = false
  location                        = var.location
  #account_kind             = BlobStorage
  account_tier             = "Standard"
  account_replication_type = "GRS"
}

resource "azurerm_storage_container" "velero_container" {
  count                 = var.enable_velero_storage ? 1 : 0
  name                  = "velero-${var.resource_group_name}"
  storage_account_name  = azurerm_storage_account.velero_storage[0].name
  container_access_type = "private"
}

resource "azurerm_storage_account" "loki_storage" {
  count                           = var.enable_loki_storage ? 1 : 0
  name                            = "loki${random_string.random[0].result}"
  allow_nested_items_to_be_public = false
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
}

resource "azurerm_storage_container" "loki_container" {
  count                 = var.enable_loki_storage ? 1 : 0
  name                  = "loki-${var.resource_group_name}"
  storage_account_name  = azurerm_storage_account.loki_storage[0].name
  container_access_type = "private"
}
