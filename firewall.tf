data "azurerm_subnet" "firewall_id" {
  count                = var.enable_managed_firewall ? 1 : 0
  name                 = "AzureFirewallSubnet"
  virtual_network_name = "${var.vnet_name}-network"
  resource_group_name  = var.resource_group_name
}

resource "azurerm_public_ip" "firewall_ip" {
  count               = var.enable_managed_firewall ? 1 : 0
  name                = local.name_prefix
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Source = "Managed by terraform"
  }
}


resource "azurerm_firewall" "firewall" {
  count               = var.enable_managed_firewall ? 1 : 0
  name                = local.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "AZFW_VNet"
  sku_tier            = "Standard"
  firewall_policy_id  = azurerm_firewall_policy.enable_dns_proxy[0].id


  ip_configuration {
    name                 = local.name_prefix
    subnet_id            = data.azurerm_subnet.firewall_id[0].id
    public_ip_address_id = azurerm_public_ip.firewall_ip[0].id
  }

  tags = {
    Source = "Managed by terraform"
  }
}



resource "azurerm_firewall_policy" "enable_dns_proxy" {
  count                    = var.enable_managed_firewall ? 1 : 0
  name                     = "EnableDns"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  threat_intelligence_mode = "Off"
  dns {
    proxy_enabled = true
  }
}

#resource "azurerm_firewall_network_rule_collection" "azure_services" {
#  name                = "AzureServices"
#  azure_firewall_name = azurerm_firewall.firewall.name
#  resource_group_name = var.resource_group_name
#  priority            = 100
#  action              = "Allow"
#
#  rule {
#    name = "aksnodecommunication"
#
#    source_addresses = [
#      "*"
#    ]
#
#    destination_ports = [
#      "1194",
#    ]
#
#    destination_addresses = [
#      "AzureCloud.${var.location}",
#    ]
#
#    protocols = [
#      "UDP"
#    ]
#  }
#
#  rule {
#    name = "akstunnelnodes"
#
#    source_addresses = [
#      "*"
#    ]
#
#    destination_addresses = [
#      "AzureCloud.${var.location}"
#    ]
#
#    destination_ports = [
#      "9000"
#    ]
#
#    protocols = [
#      "TCP"
#    ]
#  }
#
#  rule {
#    name = "ntp-protocol"
#
#    source_addresses = [
#      "*"
#    ]
#
#    destination_fqdns = [
#      "ntp.ubunutu.com"
#    ]
#
#    destination_ports = [
#      "123"
#    ]
#
#    protocols = [
#      "UDP"
#    ]
#  }
#
#  rule {
#    name = "kube-api"
#
#    source_addresses = [
#      "*"
#    ]
#
#    destination_fqdns = [
#      "${azurerm_kubernetes_cluster.kube_cluster.fqdn}"
#    ]
#
#    protocols = [
#      "TCP"
#    ]
#
#    destination_ports = [
#      "443"
#    ]
#  }
#
#}
#resource "azurerm_firewall_application_rule_collection" "example" {
#  name                = "akssystem"
#  azure_firewall_name = azurerm_firewall.firewall.name
#  resource_group_name = var.resource_group_name
#  priority            = 100
#  action              = "Allow"
#
#  rule {
#    name = "testrule"
#
#    source_addresses = [
#      "*",
#    ]
#
#    fqdn_tags = [
#      "AzureKubernetesService",
#    ]
#
#  }
#
#  rule {
#    name = "allurl"
#
#    source_addresses = [
#      "10.20.64.0/18"
#    ]
#
#    protocol {
#      port = "443"
#      type = "Https"
#    }
#
#    protocol {
#      port = "80"
#      type = "Http"
#    }
#
#    target_fqdns = [
#      "*"
#    ]
#  }
#}

resource "azurerm_firewall_policy_rule_collection_group" "firewall_rules_application" {
  count              = var.enable_managed_firewall ? 1 : 0
  name               = "app-${local.name_prefix}"
  firewall_policy_id = azurerm_firewall_policy.enable_dns_proxy[0].id
  priority           = 100


  application_rule_collection {
    name     = "aksservices"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "azureKube"
      source_addresses      = ["*"]
      destination_fqdn_tags = ["AzureKubernetesService"]
      protocols {
        port = "443"
        type = "Https"
      }

      protocols {
        port = "80"
        type = "Http"
      }
    }
    rule {
      name              = "outboundAccess"
      source_addresses  = ["${tolist("${data.azurerm_subnet.subnet_id.address_prefixes}")[0]}"]
      destination_fqdns = ["*"]
      protocols {
        port = "443"
        type = "Https"
      }
      protocols {
        port = "80"
        type = "Http"
      }
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "firewall_rules_network" {
  count              = var.enable_managed_firewall ? 1 : 0
  name               = "net-${local.name_prefix}"
  firewall_policy_id = azurerm_firewall_policy.enable_dns_proxy[0].id
  priority           = 100

  network_rule_collection {
    name     = "AzureKubecommunication"
    priority = 100
    action   = "Allow"
    rule {
      name                  = "aksnodecommunication"
      source_addresses      = ["*"]
      destination_ports     = ["1194"]
      destination_addresses = ["AzureCloud.${var.location}"]
      protocols             = ["UDP"]
    }
    rule {
      name                  = "akstunnelnodes"
      source_addresses      = ["*"]
      destination_addresses = ["AzureCloud.${var.location}"]
      destination_ports     = ["9000"]
      protocols             = ["TCP"]
    }
    rule {
      name              = "internal-kube-api"
      source_addresses  = ["*"]
      destination_fqdns = ["${azurerm_kubernetes_cluster.kube_cluster.fqdn}"]
      protocols         = ["TCP"]
      destination_ports = ["443"]
    }
    rule {
      name              = "ntp-protocol"
      source_addresses  = ["*"]
      destination_fqdns = ["ntp.ubunutu.com"]
      destination_ports = ["123"]
      protocols         = ["UDP"]
    }
    rule {
      name                  = "all-node-outbound"
      source_addresses      = ["${tolist("${data.azurerm_subnet.subnet_id.address_prefixes}")[0]}"]
      destination_addresses = ["*"]
      destination_ports     = ["*"]
      protocols             = ["Any"]
    }
  }
}

resource "azurerm_firewall_policy_rule_collection_group" "firewall_rules_dnat" {
  count              = var.enable_managed_firewall ? 1 : 0
  name               = "dnat-${local.name_prefix}"
  firewall_policy_id = azurerm_firewall_policy.enable_dns_proxy[0].id
  priority           = 100

  nat_rule_collection {
    name     = "sightmachine_access"
    priority = 100
    action   = "Dnat"

    rule {
      name                = "nginx_access"
      protocols           = ["TCP", "UDP"]
      source_addresses    = var.ip_url_whitelist
      destination_address = azurerm_public_ip.firewall_ip[0].ip_address
      destination_ports   = ["443"]
      translated_address  = azurerm_public_ip.nginx_ingress.ip_address
      translated_port     = "443"
    }
  }
}


resource "azurerm_public_ip" "nginx_ingress" {
  name                = "nginx-${local.name_prefix}"
  resource_group_name = azurerm_kubernetes_cluster.kube_cluster.node_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    Source = "Managed by terraform"
  }
}
