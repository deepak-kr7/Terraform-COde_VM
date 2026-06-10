# 1. Resource Groups
resource "azurerm_resource_group" "rg" {
  for_each = var.vm_config
  name     = each.value.rg_name
  location = each.value.location
}

# 2. Virtual Networks with Dynamic Subnets
resource "azurerm_virtual_network" "vnet" {
  for_each            = var.vm_config
  name                = each.value.vnet_name
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  address_space       = each.value.vnet_address_space

  dynamic "subnet" {
    for_each = each.value.subnets
    content {
      name             = subnet.value.name
      address_prefixes = subnet.value.address_prefixes
    }
  }
}

# 3. Network Security Groups
resource "azurerm_network_security_group" "nsg" {
  for_each            = var.vm_config
  name                = "nsg-${each.value.vm_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  dynamic "security_rule" {
    for_each = each.value.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# 4. Public IPs (for VMs)
resource "azurerm_public_ip" "pip" {
  for_each            = var.vm_config
  name                = "pip-${each.value.vm_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
}

# 5. Network Interfaces
resource "azurerm_network_interface" "nic" {
  for_each            = var.vm_config
  name                = "nic-${each.value.vm_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name = "internal"
    # Referencing the inline subnet ID by constructing the resource ID string
    subnet_id                     = "${azurerm_virtual_network.vnet[each.key].id}/subnets/${each.value.subnets["subnet1"].name}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip[each.key].id
  }
}

# 6. Associate NSG with NIC
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  for_each                  = var.vm_config
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nsg[each.key].id
}

# 7. Virtual Machines
resource "azurerm_linux_virtual_machine" "vm" {
  for_each                        = var.vm_config
  name                            = each.value.vm_name
  resource_group_name             = azurerm_resource_group.rg[each.key].name
  location                        = each.value.location
  size                            = each.value.vm_size
  admin_username                  = each.value.admin_username
  admin_password                  = each.value.admin_password
  disable_password_authentication = false

  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

# 8. VNET Peering (India to Japan)
resource "azurerm_virtual_network_peering" "india_to_japan" {
  name                         = "peering-india-to-japan"
  resource_group_name          = azurerm_resource_group.rg["india_vm"].name
  virtual_network_name         = azurerm_virtual_network.vnet["india_vm"].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet["japan_vm"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# 9. VNET Peering (Japan to India)
resource "azurerm_virtual_network_peering" "japan_to_india" {
  name                         = "peering-japan-to-india"
  resource_group_name          = azurerm_resource_group.rg["japan_vm"].name
  virtual_network_name         = azurerm_virtual_network.vnet["japan_vm"].name
  remote_virtual_network_id    = azurerm_virtual_network.vnet["india_vm"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
}

# 10. Bastion Host Public IPs
resource "azurerm_public_ip" "bastion_pip" {
  for_each            = var.vm_config
  name                = "pip-bastion-${each.value.vm_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 11. Bastion Hosts
resource "azurerm_bastion_host" "bastion" {
  for_each            = var.vm_config
  name                = "bastion-${each.value.vm_name}"
  location            = each.value.location
  resource_group_name = azurerm_resource_group.rg[each.key].name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = "${azurerm_virtual_network.vnet[each.key].id}/subnets/AzureBastionSubnet"
    public_ip_address_id = azurerm_public_ip.bastion_pip[each.key].id
  }
}
