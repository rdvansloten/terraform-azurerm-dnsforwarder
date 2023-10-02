resource "azurerm_lb" "lb" {
  name                = var.lb_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.lb_sku
  tags                = merge(var.lb_tags, var.tags)

  frontend_ip_configuration {
    name                          = "private-ip"
    subnet_id                     = var.lb_subnet_id
    private_ip_address            = var.lb_private_ip_address
    private_ip_address_allocation = var.lb_private_ip_address_allocation
    private_ip_address_version    = var.lb_private_ip_address_version
    zones                         = var.lb_sku != "Basic" ? var.zones : null
  }
}

resource "azurerm_lb_rule" "rule" {
  for_each = toset(["Tcp", "Udp"])

  loadbalancer_id                = azurerm_lb.lb.id
  name                           = "dns-${lower(each.key)}"
  protocol                       = each.key
  frontend_port                  = 53
  backend_port                   = 53
  frontend_ip_configuration_name = "private-ip"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.vmss.id]
  probe_id                       = azurerm_lb_probe.vmss.id
}

resource "azurerm_lb_backend_address_pool" "vmss" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "vmss"
}

resource "azurerm_lb_probe" "vmss" {
  loadbalancer_id = azurerm_lb.lb.id
  name            = "vmss-tcp53"
  port            = 53
  protocol        = "Tcp"
}