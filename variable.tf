variable "vm_config" {
  description = "Nested map for VM configuration"
  type = map(object({
    rg_name            = string
    location           = string
    vnet_name          = string
    vnet_address_space = list(string)
    subnets = map(object({
      name             = string
      address_prefixes = list(string)
    }))
    security_rules = map(object({
      name                       = string
      priority                   = number
      direction                  = string
      access                     = string
      protocol                   = string
      source_port_range          = string
      destination_port_range     = string
      source_address_prefix      = string
      destination_address_prefix = string
    }))
    vm_name        = string
    vm_size        = string
    admin_username = string
    admin_password = string # Added admin_password
  }))
}
