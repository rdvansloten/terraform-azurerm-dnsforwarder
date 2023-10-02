locals {
  # Merge the domain_list and the template PowerShell script
  dns_template = templatefile("${path.module}/templates/dns.tftpl", {
    domain_list = join(",\n", [for k, v in toset(var.domain_list) : "\"${k}\""])
    dns_server  = var.dns_server
  })
}