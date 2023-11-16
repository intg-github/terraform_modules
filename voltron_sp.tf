resource "azuread_application" "voltron_sp" {
  count        = var.enable_voltron_sp ? 1 : 0
  display_name = "voltron-${var.resource_group_name}"
  owners       = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "voltron_sp" {
  count          = var.enable_voltron_sp ? 1 : 0
  application_id = azuread_application.voltron_sp[0].application_id
  owners         = [data.azuread_client_config.current.object_id]
}

resource "azurerm_role_definition" "voltron_sp" {
  count       = var.enable_voltron_sp ? 1 : 0
  name        = "voltron-${var.resource_group_name}"
  scope       = data.azurerm_subscription.primary.id
  description = "This is a custom role used by voltron."
}

resource "azurerm_role_assignment" "voltron_sp" {
  count                = var.enable_voltron_sp ? 1 : 0
  principal_id         = azuread_service_principal.voltron_sp[0].object_id
  scope                = data.azurerm_subscription.primary.id
  role_definition_name = "Contributor"
}

resource "azuread_application_password" "voltron_sp" {
  count                 = var.enable_voltron_sp ? 1 : 0
  application_object_id = azuread_application.voltron_sp[0].object_id
  rotate_when_changed = {
    rotation = time_rotating.rotate_sp.id
  }
  end_date_relative = "8760h"
  display_name      = "voltron-${var.resource_group_name}-client"
}
