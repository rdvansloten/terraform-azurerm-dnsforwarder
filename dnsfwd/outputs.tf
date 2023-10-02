output "lb_private_ip_address" {
  value = module.dns_forwarders.lb_private_ip_address
}

output "lb_subnet_id" {
  value = module.dns_forwarders.lb_subnet_id
}

output "lb_id" {
  value = module.dns_forwarders.lb_id
}

output "lb_name" {
  value = module.dns_forwarders.lb_name
}

output "vmss_id" {
  value = module.dns_forwarders.vmss_id
}

output "resource_group_name" {
  value = module.dns_forwarders.resource_group_name
}

output "subscription_id" {
  value = data.azurerm_subscription.current.subscription_id
}

output "dns_server" {
  value = module.dns_forwarders.dns_server
}

output "dns_template" {
  value = module.dns_forwarders.dns_template
}