resource "vault_auth_backend" "kube_auth" {
  type = "kubernetes"

  path = azurerm_kubernetes_cluster.kube_cluster.name

  tune {
    max_lease_ttl     = "0"
    default_lease_ttl = "0"
    token_type        = "default-service"
  }
}

resource "vault_kubernetes_auth_backend_config" "kube_auth" {
  count                  = var.register_kube_with_vault ? 1 : 0
  backend                = vault_auth_backend.kube_auth.path
  kubernetes_host        = "https://${azurerm_kubernetes_cluster.kube_cluster.fqdn}:443"
  kubernetes_ca_cert     = base64decode(azurerm_kubernetes_cluster.kube_cluster.kube_config.0.cluster_ca_certificate)
  token_reviewer_jwt     = var.sa_token
  disable_iss_validation = true
}

resource "vault_kubernetes_auth_backend_role" "backend_role" {
  backend                          = vault_auth_backend.kube_auth.path
  for_each                         = var.list_of_roles
  role_name                        = each.key
  bound_service_account_names      = each.value.service_account
  bound_service_account_namespaces = each.value.namespace
  token_policies                   = [each.key]
  token_ttl                        = 86400
}

resource "vault_generic_secret" "velero_sp" {
  count     = var.enable_velero_sp ? 1 : 0
  path      = "secret/${var.env}/${azurerm_kubernetes_cluster.kube_cluster.name}-velero"
  data_json = <<EOF
{  
  "AZURE_SUBSCRIPTION_ID":"${var.subscription_id}",
  "AZURE_TENANT_ID": "${var.tenant_id}",
  "AZURE_RESOURCE_GROUP": "${azurerm_kubernetes_cluster.kube_cluster.node_resource_group}",
  "AZURE_CLIENT_ID": "${azuread_application.velero_sp[0].application_id}",  
  "AZURE_CLIENT_SECRET": "${azuread_application_password.velero_sp[0].value}"
}
EOF
}
