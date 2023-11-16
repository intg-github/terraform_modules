resource "azurerm_log_analytics_workspace" "aks_logs" {
  count               = var.enable_master_logs ? 1 : 0
  name                = "${local.name_prefix}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  # This is the minimun accepted value for the entire workspace.
  retention_in_days = 30
  # Pay as you go.
  sku  = "PerGB2018"
  tags = var.tags
}

resource "azurerm_monitor_diagnostic_setting" "aks_logs" {
  count                      = var.enable_master_logs ? 1 : 0
  name                       = "${local.name_prefix}-settings"
  target_resource_id         = azurerm_kubernetes_cluster.kube_cluster.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs[0].id

  dynamic "log" {
    for_each = var.list_of_logs_category

    content {
      category = log.key
      enabled  = log.value["enabled"]

      retention_policy {
        enabled = log.value["enabled"]
        days    = log.value["enabled"] != false ? var.master_logs_retention : 0
      }
    }
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}
