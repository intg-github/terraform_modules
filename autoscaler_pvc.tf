resource "azuread_application" "autoscaler_pvc" {
  count        = var.enable_autoscaler_sp ? 1 : 0
  display_name = "autoscaler-${var.resource_group_name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "autoscaler_pvc" {
  count          = var.enable_autoscaler_sp ? 1 : 0
  application_id = azuread_application.autoscaler_pvc[0].application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_definition" "autoscaler_pvc" {
  count       = var.enable_autoscaler_sp ? 1 : 0
  name        = "autoscaler-${var.resource_group_name}"
  scope       = data.azurerm_subscription.primary.id
  description = "This is a custom role used by autoscaler."

  permissions {
    actions = [
      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/endGetAccess/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",
    ]
  }
}

resource "azurerm_role_assignment" "autoscaler_pvc" {
  count              = var.enable_autoscaler_sp ? 1 : 0
  principal_id       = azuread_service_principal.autoscaler_pvc[0].object_id
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = azurerm_role_definition.autoscaler_pvc[0].role_definition_resource_id
}

resource "azuread_application_password" "autoscaler_pvc" {
  count                 = var.enable_autoscaler_sp ? 1 : 0
  application_object_id = azuread_application.autoscaler_pvc[0].object_id
  rotate_when_changed = {
    rotation = time_rotating.rotate_sp.id
  }
  end_date_relative = "8760h"
  display_name      = "autoscaler-${var.resource_group_name}-client"
}
