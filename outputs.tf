output "lb_private_ip_address" {
  value = azurerm_lb.lb.frontend_ip_configuration[0].private_ip_address
}

output "lb_subnet_id" {
  value = azurerm_lb.lb.frontend_ip_configuration[0].subnet_id
}

output "lb_id" {
  value = azurerm_lb.lb.id
}

output "lb_name" {
  value = azurerm_lb.lb.name
}

output "vmss_id" {
  value = azurerm_windows_virtual_machine_scale_set.vmss.id
}

output "resource_group_name" {
  value = var.resource_group_name
}

output "dns_server" {
  value = var.dns_server
}

output "dns_template" {
  value = local.dns_template
}