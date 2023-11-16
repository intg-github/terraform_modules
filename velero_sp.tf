data "azuread_client_config" "current" {}

resource "azuread_application" "velero_sp" {
  count        = var.enable_velero_sp ? 1 : 0
  display_name = "velero-${var.resource_group_name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "velero_sp" {
  count          = var.enable_velero_sp ? 1 : 0
  application_id = azuread_application.velero_sp[0].application_id
  owners         = [data.azuread_client_config.current.object_id]
}

data "azurerm_subscription" "primary" {
}

resource "azurerm_role_definition" "velero_sp" {
  count       = var.enable_velero_sp ? 1 : 0
  name        = "velero-${var.resource_group_name}"
  scope       = data.azurerm_subscription.primary.id
  description = "This is a custom role used by velero."

  permissions {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/snapshots/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Storage/storageAccounts/listKeys/action",
    ]
  }
}

resource "azurerm_role_assignment" "velero_sp" {
  count              = var.enable_velero_sp ? 1 : 0
  principal_id       = azuread_service_principal.velero_sp[0].object_id
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.velero_sp[0].role_definition_resource_id
}

resource "azurerm_role_assignment" "velero_sp_storage" {
  count                = var.enable_velero_sp ? 1 : 0
  principal_id         = azuread_service_principal.velero_sp[0].object_id
  scope                = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Storage Blob Data Contributor"
}

resource "time_rotating" "rotate_sp" {
  rotation_hours = 7300
}

resource "azuread_application_password" "velero_sp" {
  count                 = var.enable_velero_sp ? 1 : 0
  application_object_id = azuread_application.velero_sp[0].object_id
  rotate_when_changed = {
    rotation = time_rotating.rotate_sp.id
  }
  end_date_relative = "8760h"
  display_name      = "velero-${var.resource_group_name}-client"
}
