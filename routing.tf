resource "azurerm_route_table" "routing_table_firewall" {
  count               = var.enable_managed_firewall ? 1 : 0
  name                = local.name_prefix
  location            = var.location
  resource_group_name = var.resource_group_name
}

resource "azurerm_route" "route_to_firewall" {
  count                  = var.enable_managed_firewall ? 1 : 0
  name                   = "RouteToFirewall"
  resource_group_name    = var.resource_group_name
  route_table_name       = azurerm_route_table.routing_table_firewall[0].name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = azurerm_firewall.firewall[0].ip_configuration[0].private_ip_address
}

resource "azurerm_route" "route_to_internet" {
  count               = var.enable_managed_firewall ? 1 : 0
  name                = "RouteToInternet"
  resource_group_name = var.resource_group_name
  route_table_name    = azurerm_route_table.routing_table_firewall[0].name
  address_prefix      = "${azurerm_public_ip.firewall_ip[0].ip_address}/32"
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "route_mapping_subnet" {
  count          = var.enable_managed_firewall ? 1 : 0
  route_table_id = azurerm_route_table.routing_table_firewall[0].id
  subnet_id      = data.azurerm_subnet.subnet_id.id
}
