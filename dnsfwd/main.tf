module "dns_forwarders" {
  source = "../"

  location            = "westeurope"
  resource_group_name = azurerm_resource_group.test.name
  tags                = { "test" = "tag" }

  domain_list = local.domain_list

  lb_name      = "testlb"
  lb_sku       = "Basic"
  lb_tags      = {}
  lb_subnet_id = azurerm_subnet.lb.id

  vmss_name      = "testvmss"
  vmss_sku       = "Standard_B1ms"
  vmss_tags      = {}
  vmss_subnet_id = azurerm_subnet.vmss.id

}

# Vnet
resource "azurerm_resource_group" "test" {
  name     = "test-resources"
  location = "westeurope"
}

resource "azurerm_virtual_network" "test" {
  name                = "test-network"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  address_space       = ["192.168.0.0/16"]
}

resource "azurerm_subnet" "lb" {
  name                 = "test-lb-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["192.168.1.0/24"]
}

resource "azurerm_subnet" "vmss" {
  name                 = "test-vmss-subnet"
  resource_group_name  = azurerm_resource_group.test.name
  virtual_network_name = azurerm_virtual_network.test.name
  address_prefixes     = ["192.168.2.0/24"]
}

resource "azurerm_private_dns_zone" "test" {
  name                = "test.com"
  resource_group_name = azurerm_resource_group.test.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "test" {
  name                  = "test"
  resource_group_name   = azurerm_resource_group.test.name
  private_dns_zone_name = azurerm_private_dns_zone.test.name
  virtual_network_id    = azurerm_virtual_network.test.id
}

resource "azurerm_private_dns_a_record" "example" {
  for_each            = toset(local.domain_list)
  name                = split(".", each.key)[0]
  zone_name           = azurerm_private_dns_zone.test.name
  resource_group_name = azurerm_resource_group.test.name
  ttl                 = 300
  records             = ["192.1.2.3"]
}

locals {
  domain_list = [
    "test.test.com"
  ]
}

data "azurerm_subscription" "current" {
}