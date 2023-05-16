resource "azurerm_virtual_network" "main" {
  name = "TME-terra-metal"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  address_space               = ["10.0.0.0/26"]
  dns_servers                 = ["8.8.8.8", "1.1.1.1"]
}

resource "azurerm_subnet" "main" {
  name         = "Terra-AHV"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes   = ["10.0.0.0/27"]
  #delegation {
    #name = "delegation"

    #service_delegation {
     # name    = "Microsoft.BareMetal/AzureHostedService"
      
    #}
  #}

}

resource "azurerm_virtual_network" "mainpc" {
  name                        = "TME-terra-PC"
  location                    = azurerm_resource_group.main.location
  resource_group_name         = azurerm_resource_group.main.name
  address_space               = ["10.0.10.0/24"]
  dns_servers                 = ["8.8.8.8", "1.1.1.1"]

  subnet {
    name           = "Terra-FlowInteral"
    address_prefix = "10.0.10.32/27"
  }
}

resource "azurerm_subnet" "mainpc" {
  name         = "Terra-PC"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.mainpc.name
  address_prefixes   = ["10.0.10.0/27"]
  #delegation {
    #name = "delegation"

    #service_delegation {
     # name    = "Microsoft.BareMetal/AzureHostedService"
      
    #}
  #}

}
resource "azurerm_subnet" "mainpcEXT" {
  name         = "Terra-FlowExternal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.mainpc.name
  address_prefixes   = ["10.0.10.128/26"]
  #delegation {
    #name = "delegation"

    #service_delegation {
     # name    = "Microsoft.BareMetal/AzureHostedService"
      
    #}
  #}

}
resource "azurerm_public_ip_prefix" "tme_gw_ahv" {
  name                = "TME-AHV-nat-pre"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_version          = "IPv4"
  prefix_length       = 29
  sku                 = "Standard"
  zones               = ["1"]
}
resource "azurerm_nat_gateway" "tme_gw_ahv" {
  name                    = "natgw-ahv"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
  tags                    = {"fastpathenabled" = "true"}
}

resource "azurerm_public_ip" "tme_gw_ahv" {
  name                = "tme_gw_ahv-PIP"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway_public_ip_association" "tme_gw_ahv" {
  nat_gateway_id       = azurerm_nat_gateway.tme_gw_ahv.id
  public_ip_address_id = azurerm_public_ip.tme_gw_ahv.id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "tme_gw_ahv" {
  nat_gateway_id      = azurerm_nat_gateway.tme_gw_ahv.id
  public_ip_prefix_id = azurerm_public_ip_prefix.tme_gw_ahv.id

}

resource "azurerm_subnet_nat_gateway_association" "tme_gw_ahv" {
  subnet_id      = azurerm_subnet.main.id
  nat_gateway_id = azurerm_nat_gateway.tme_gw_ahv.id
}

output "gateway_ips" {
  value = azurerm_public_ip_prefix.tme_gw_ahv.ip_prefix
}

######################## - Azure PC 
resource "azurerm_public_ip_prefix" "tme_gw_PC" {
  name                = "TME-PX-nat-pre"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_version          = "IPv4"
  prefix_length       = 29
  sku                 = "Standard"
  zones               = ["1"]
}

resource "azurerm_nat_gateway" "tme_gw_PC" {
  name                    = "natgw-PC"
  resource_group_name     = azurerm_resource_group.main.name
  location                = azurerm_resource_group.main.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = 10
  zones                   = ["1"]
  tags                    = {"fastpathenabled" = "true"}
}

resource "azurerm_public_ip" "tme_gw_PC" {
  name                = "tme_gw_PC-PIP"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1"]                
}

resource "azurerm_nat_gateway_public_ip_association" "tme_gw_PC" {
  nat_gateway_id       = azurerm_nat_gateway.tme_gw_PC.id
  public_ip_address_id = azurerm_public_ip.tme_gw_PC.id
}

resource "azurerm_nat_gateway_public_ip_prefix_association" "tme_gw_PC" {
  nat_gateway_id      = azurerm_nat_gateway.tme_gw_PC.id
  public_ip_prefix_id = azurerm_public_ip_prefix.tme_gw_PC.id

}

resource "azurerm_subnet_nat_gateway_association" "tme_gw_PC" {
  subnet_id      = azurerm_subnet.mainpc.id
  nat_gateway_id = azurerm_nat_gateway.tme_gw_PC.id
}

resource "azurerm_subnet_nat_gateway_association" "tme_gw_PC2" {
  subnet_id      = azurerm_subnet.mainpcEXT.id
  nat_gateway_id = azurerm_nat_gateway.tme_gw_PC.id
}

output "gateway_PC_ips" {
  value = azurerm_public_ip_prefix.tme_gw_PC.ip_prefix
}

resource "azurerm_virtual_network_peering" "main" {
  name                      = "peer1to2"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.main.name
  remote_virtual_network_id = azurerm_virtual_network.mainpc.id
}

resource "azurerm_virtual_network_peering" "mainpc" {
  name                      = "peer2to1"
  resource_group_name       = azurerm_resource_group.main.name
  virtual_network_name      = azurerm_virtual_network.mainpc.name
  remote_virtual_network_id = azurerm_virtual_network.main.id
}