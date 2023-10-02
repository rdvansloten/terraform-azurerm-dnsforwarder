# General variables
variable "location" {
  type        = string
  default     = "westeurope"
  description = "Specifies the supported Azure Region where the resources should be created."
}

variable "domain_list" {
  type        = list(string)
  default     = []
  description = "List of domain names to add to the DNS forwarder."
}

variable "dns_server" {
  type        = string
  default     = "168.63.129.16" # Azure DNS
  description = "DNS server to forward records to."
}

variable "resource_group_name" {
  type        = string
  description = "The name of the resource group in which to create the resources. Changing this forces a new resource to be created."
}

variable "zones" {
  type        = list(number)
  default     = [1, 2, 3]
  description = "Specifies a list of Availability Zones in which the resources should be located. Changing this forces a new Load Balancer and Virtual Machine Scale Set to be created."
}

variable "tags" {
  type = map(string)
  default = {
    "role"   = "dnsforwarder"
    "module" = "rdvansloten/terraform-azurerm-dnsforwarder"
  }
  description = "Map of tags to be applied to all resources."
}

# Load Balancer variables
variable "lb_name" {
  type        = string
  default     = "lb-dnsforwarder"
  description = "Specifies the name of the Load Balancer."
}

variable "lb_sku" {
  type        = string
  default     = "Basic"
  description = "The SKU of the Azure Load Balancer. Accepted values are Basic, Standard and Gateway. Defaults to Basic."
  validation {
    condition     = var.lb_sku == "Basic" || var.lb_sku == "Standard"
    error_message = "Load Balancer SKU must be either Basic or Standard."
  }
}

variable "lb_private_ip_address" {
  type        = string
  default     = null
  description = "Private IP Address to assign to the Load Balancer. The last one and first four IPs in any range are reserved and cannot be manually assigned."
}

variable "lb_private_ip_address_allocation" {
  type        = string
  default     = "Dynamic"
  description = "The allocation method for the Private IP Address used by this Load Balancer. Possible values as Dynamic and Static."
  validation {
    condition     = var.lb_private_ip_address_allocation == "Dynamic" || var.lb_private_ip_address_allocation == "Static"
    error_message = "Private IP address allocation must be either Dynamic or Static."
  }
}

variable "lb_private_ip_address_version" {
  type        = string
  default     = "IPv4"
  description = "The version of IP that the Private IP Address is. Possible values are IPv4 or IPv6."
  validation {
    condition     = var.lb_private_ip_address_version == "IPv4" || var.lb_private_ip_address_version == "IP64"
    error_message = "Private IP address version must be either IPv4 or IPv6."
  }
}

variable "lb_subnet_id" {
  type        = string
  description = "The ID of the Subnet which is associated with the IP Configuration."
}

variable "lb_tags" {
  type        = map(string)
  description = "A mapping of tags to assign to the resource."
}

# Virtual Machine Scale Set variables
variable "vmss_name" {
  type        = string
  default     = "vmss-dnsforwarder"
  description = "Specifies the name of the virtual machine scale set resource. Changing this forces a new resource to be created."
}

variable "vmss_sku" {
  type        = string
  default     = "Standard_B1s"
  description = "The Virtual Machine SKU for the Scale Set, such as Standard_B1s."
}

variable "vmss_instances" {
  type        = number
  default     = 1
  description = "The number of Virtual Machines in the Scale Set."
}

variable "vmss_tags" {
  type        = map(string)
  default     = {}
  description = "A mapping of tags which should be assigned to this Virtual Machine Scale Set."
}

variable "vmss_subnet_id" {
  type        = string
  description = "The ID of the Subnet which this IP Configuration should be connected to."
}

variable "vmss_admin_username" {
  type        = string
  default     = "azureadmin"
  description = "The username of the local administrator on each Virtual Machine Scale Set instance. Changing this forces a new resource to be created."
}

variable "vmss_admin_password" {
  type        = string
  default     = null
  description = "The Password which should be used for the local-administrator on this Virtual Machine. Changing this forces a new resource to be created."
}

variable "key_vault_secret_name" {
  type        = string
  default     = "vmss-dnsforwarder-admin-password"
  description = "Specifies the name of the Key Vault Secret. Changing this forces a new resource to be created."
}

variable "key_vault_id" {
  type        = string
  default     = null
  description = "The ID of the Key Vault where the Secret should be created."
}