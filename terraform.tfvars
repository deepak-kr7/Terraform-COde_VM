vm_config = {
  "india_vm" = {
    rg_name            = "rg-india-project"
    location           = "Central India"
    vnet_name          = "vnet-india"
    vnet_address_space = ["192.168.0.0/16"]
    subnets = {
      "subnet1" = {
        name             = "india_frontend"
        address_prefixes = ["192.168.1.0/24"]
      },
      "subnet2" = {
        name             = "india_backend"
        address_prefixes = ["192.168.2.0/24"]
      },
      "bastion_subnet" = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["192.168.10.0/24"]
      }
    }
    security_rules = {
      "SSH" = {
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "HTTP" = {
        name                       = "AllowHTTP"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
    vm_name        = "vm-india-01"
    vm_size        = "Standard_D2s_v3"
    admin_username = "azureuser"
    admin_password = "Password@123456" # Add your password here
  },
  "japan_vm" = {
    rg_name            = "rg-japan-project"
    location           = "Japan East"
    vnet_name          = "vnet-japan"
    vnet_address_space = ["10.2.0.0/16"]
    subnets = {
      "subnet1" = {
        name             = "snet-japan-01"
        address_prefixes = ["10.2.1.0/24"]
      },
      "subnet2" = {
        name             = "snet-japan-02"
        address_prefixes = ["10.2.2.0/24"]
      },
      "bastion_subnet" = {
        name             = "AzureBastionSubnet"
        address_prefixes = ["10.2.10.0/24"]
      }
    }
    security_rules = {
      "SSH" = {
        name                       = "AllowSSH"
        priority                   = 100
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      },
      "HTTP" = {
        name                       = "AllowHTTP"
        priority                   = 110
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
      }
    }
    vm_name        = "vm-japan-01"
    vm_size        = "Standard_D2s_v3"
    admin_username = "azureuser"
    admin_password = "Password@123456" # Add your password here
  }
}
