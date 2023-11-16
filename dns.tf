data "aws_route53_zone" "root" {
  name = var.root_domain
}
resource "aws_route53_zone" "subdomain" {
  name = "${azurerm_kubernetes_cluster.kube_cluster.name}.sightmachine.com"
  tags = {
    Source = "Managed by terraform"
  }
}
resource "aws_route53_record" "subdomain" {
  name    = aws_route53_zone.subdomain.name
  zone_id = data.aws_route53_zone.root.id
  type    = "NS"
  ttl     = "30"

  records = [
    aws_route53_zone.subdomain.name_servers.0,
    aws_route53_zone.subdomain.name_servers.1,
    aws_route53_zone.subdomain.name_servers.2,
    aws_route53_zone.subdomain.name_servers.3,
  ]
}

resource "aws_route53_record" "sightmachine_io" {
  for_each = var.enable_managed_firewall ? toset(var.list_urls) : []
  zone_id  = var.sightmachine_io_zone_id
  name     = each.value
  type     = "A"
  ttl      = 300
  records  = ["${azurerm_public_ip.firewall_ip[0].ip_address}"]
}
