output "kube_config" {
  value     = azurerm_kubernetes_cluster.kube_cluster.kube_config_raw
  sensitive = true
}

output "resource_group" {
  value = var.resource_group_name
}

output "cluster_name" {
  value = azurerm_kubernetes_cluster.kube_cluster.name
}

output "aks_resource_group" {
  value = azurerm_kubernetes_cluster.kube_cluster.node_resource_group
}

output "env" {
  value = var.env
}

output "subscription_id" {
  value = var.subscription_id
}

output "bucket_name" {
  value = "velero-${var.resource_group_name}"
}

output "storage_account_name" {
  value = try(azurerm_storage_account.velero_storage[0].name, "")
}

output "loki_bucket_name" {
  value = "loki-${var.resource_group_name}"
}

output "loki_storage_account" {
  value = try(azurerm_storage_account.loki_storage[0].name, "")
}

output "loki_storage_account_key" {
  value     = try(azurerm_storage_account.loki_storage[0].primary_access_key, "")
  sensitive = true
}

output "ingress_public_ip" {
  value = azurerm_public_ip.nginx_ingress.ip_address
}
