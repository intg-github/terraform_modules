locals {
  name_prefix = "${var.prefix}${var.enable_azure_external_deploy == true ? "-external" : ""}-${var.env}-${var.location}-${var.name != "" ? var.name : "kube"}"

}
data "azurerm_subnet" "subnet_id" {
  name                 = var.subnet_name
  virtual_network_name = "${var.vnet_name}-network"
  resource_group_name  = var.resource_group_name
}

data "azurerm_kubernetes_service_versions" "current" {
  location = var.location
}

resource "azurerm_kubernetes_cluster" "kube_cluster" {
  name                    = local.name_prefix
  resource_group_name     = var.resource_group_name
  location                = var.location
  kubernetes_version      = coalesce(var.k8s_version, data.azurerm_kubernetes_service_versions.current.latest_version)
  dns_prefix              = "${var.prefix}-${var.env}-${var.name != "" ? var.name : "kube"}-${var.location}"
  node_os_channel_upgrade = var.node_os_channel_upgrade

  default_node_pool {
    name                        = lower(var.default_node_pool_name)
    node_count                  = var.default_node_count
    orchestrator_version        = var.default_node_pool_version
    max_count                   = var.default_max_count
    min_count                   = var.default_min_count
    enable_auto_scaling         = var.default_enable_autoscaler
    vm_size                     = var.default_node_size
    max_pods                    = var.default_max_pod
    os_disk_size_gb             = var.default_node_disk_size
    vnet_subnet_id              = data.azurerm_subnet.subnet_id.id
    temporary_name_for_rotation = var.temporary_name_for_rotation

    upgrade_settings {
      max_surge = var.default_max_surge
    }

  }

  lifecycle {
    ignore_changes = [
      default_node_pool[0].node_count
    ]
  }

  linux_profile {
    admin_username = var.linux_admin_username

    ssh_key {
      key_data = file("${path.module}/ssh_key.pub")
    }
  }

  identity {
    type = "SystemAssigned"
  }
  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
    outbound_type  = var.enable_managed_firewall == true ? "userDefinedRouting" : "loadBalancer"
  }

  dynamic "oms_agent" {
    for_each = var.enable_master_logs ? [1] : []
    content {
      log_analytics_workspace_id = azurerm_log_analytics_workspace.aks_logs[0].id
    }
  }

  dynamic "api_server_access_profile" {
    for_each = var.enable_kube_api_whitelisting ? [1] : []
    content {
      authorized_ip_ranges = var.list_of_ips_whitelist
    }
  }

  tags = var.tags

  timeouts {
    create = "60m"
    delete = "60m"
    update = "120m" # migration of node pool can take longer than 60 mins
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "second_pool" {
  kubernetes_cluster_id = azurerm_kubernetes_cluster.kube_cluster.id
  for_each              = var.node_pools
  name                  = each.key
  vm_size               = lookup(each.value, "vm_size", "Standard_D2_v2")
  vnet_subnet_id        = data.azurerm_subnet.subnet_id.id
  priority              = lookup(each.value, "node_pool_type", "Regular")
  eviction_policy       = lookup(each.value, "eviction_policy", null)
  spot_max_price        = lookup(each.value, "spot_max_price", null)
  enable_auto_scaling   = true
  max_pods              = lookup(each.value, "max_pods", "30")
  os_disk_size_gb       = lookup(each.value, "node_disk_size", "128")
  orchestrator_version  = lookup(each.value, "node_pool_version", var.k8s_version)
  max_count             = lookup(each.value, "max_count", "1")
  min_count             = lookup(each.value, "min_count", "1")
  node_taints           = lookup(each.value, "taints", null)
  node_labels           = lookup(each.value, "node_labels", null)

  dynamic "upgrade_settings" {
    for_each = lookup(each.value, "node_pool_type", "Regular") != "Spot" ? [1] : []
    content {
      max_surge = lookup(each.value, "max_surge", "33%")
    }
  }

  # Needs to confirm that subscription support this
  #enable_host_encryption = true
  lifecycle {
    ignore_changes = [
      node_count
    ]
  }

  timeouts {
    create = "60m"
    delete = "60m"
    update = "120m"
  }

  tags = var.tags

}

resource "azurerm_role_assignment" "kube_network" {
  count                = var.enable_aad ? 1 : 0
  principal_id         = azurerm_kubernetes_cluster.kube_cluster.identity[0].principal_id
  scope                = "${data.azurerm_subscription.primary.id}/resourceGroups/${var.resource_group_name}"
  role_definition_name = "Network Contributor"
}
