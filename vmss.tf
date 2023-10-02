# Create a Windows Virtual Machine Scale Set
resource "azurerm_windows_virtual_machine_scale_set" "vmss" {
  name                   = try(var.vmss_name, "dnsforwarder-vmss")
  resource_group_name    = var.resource_group_name
  location               = var.location
  sku                    = var.vmss_sku
  instances              = var.vmss_instances
  license_type           = "Windows_Server"
  single_placement_group = var.lb_sku == "Basic" ? true : false

  admin_password       = coalesce(var.vmss_admin_password, random_password.vmss_password.result)
  admin_username       = var.vmss_admin_username
  computer_name_prefix = "dnsfwd"

  tags = merge(var.vmss_tags, var.tags)

  zone_balance = var.lb_sku != "Basic" ? true : null
  zones        = var.lb_sku != "Basic" ? var.zones : null

  enable_automatic_updates = true
  upgrade_mode             = "Automatic"

  boot_diagnostics {
    storage_account_uri = "https://${azurerm_storage_account.vmss.primary_blob_host}/"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter-Core"
    version   = "latest"
  }

  automatic_os_upgrade_policy {
    disable_automatic_rollback  = false
    enable_automatic_os_upgrade = false
  }

  rolling_upgrade_policy {
    max_batch_instance_percent              = ceil(100 / var.vmss_instances)
    max_unhealthy_instance_percent          = ceil(100 / var.vmss_instances)
    max_unhealthy_upgraded_instance_percent = ceil(100 / var.vmss_instances)
    pause_time_between_batches              = "PT5M0S"
  }

  os_disk {
    storage_account_type = "Premium_LRS"
    caching              = "ReadOnly"
  }

  network_interface {
    name    = "private"
    primary = true

    ip_configuration {
      name                                   = "private"
      primary                                = true
      subnet_id                              = var.vmss_subnet_id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.vmss.id]
    }
  }
}

# Process templates/dns.tpl in a secure PowerShell extension
resource "azurerm_virtual_machine_scale_set_extension" "add_dns_domains" {
  name                         = "CustomScriptExtension"
  virtual_machine_scale_set_id = azurerm_windows_virtual_machine_scale_set.vmss.id
  publisher                    = "Microsoft.Compute"
  type                         = "CustomScriptExtension"
  type_handler_version         = "1.9"

  protected_settings = <<SETTINGS
  {
    "commandToExecute": "powershell -command \"[System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String('${base64encode(local.dns_template)}')) | Out-File -filepath dns.ps1\" && powershell -ExecutionPolicy Unrestricted -File dns.ps1"
  }
  SETTINGS
}

resource "random_string" "storage_account_name" {
  length  = 12
  special = false
}

resource "azurerm_storage_account" "vmss" {
  name                     = "vmssbootdiag${lower(random_string.storage_account_name.result)}"
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = merge(var.vmss_tags, var.tags)
}

# Generate admin_password if not defined by the user
resource "random_password" "vmss_password" {
  length           = 24
  special          = true
  override_special = "_%@"
}

# Secret which holds the admin_username
resource "azurerm_key_vault_secret" "admin_username" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "${azurerm_windows_virtual_machine_scale_set.vmss.name}-admin-username"
  value        = var.vmss_admin_password
  key_vault_id = var.key_vault_id
}

# Secret which holds the admin_password
resource "azurerm_key_vault_secret" "admin_password" {
  count = var.key_vault_id != null ? 1 : 0

  name         = "${azurerm_windows_virtual_machine_scale_set.vmss.name}-admin-password"
  value        = coalesce(var.vmss_admin_password, random_password.vmss_password.result)
  key_vault_id = var.key_vault_id
}