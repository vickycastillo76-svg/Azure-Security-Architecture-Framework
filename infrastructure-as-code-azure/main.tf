# 1. Grupo de Recursos
resource "azurerm_resource_group" "hospital_rg" {
  name     = var.resource_group_name
  location = var.location
  tags = { Environment = "Production", ManagedBy = "Terraform" }
}

# 2. Red Virtual (VNet)
resource "azurerm_virtual_network" "hospital_vnet" {
  name                = "VNet-Secure-IaC"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
}

# 3. Subred para el Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hospital_rg.name
  virtual_network_name = azurerm_virtual_network.hospital_vnet.name
  address_prefixes     = ["10.10.2.0/26"]
}

# 4. Subred para Máquinas Virtuales
resource "azurerm_subnet" "workload_subnet" {
  name                 = "Workload-Subnet"
  resource_group_name  = azurerm_resource_group.hospital_rg.name
  virtual_network_name = azurerm_virtual_network.hospital_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# 5. IP Pública para el Bastion (Requisito: SKU Standard)
resource "azurerm_public_ip" "bastion_ip" {
  name                = "IP-Bastion-IaC"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 6. El Bastion Host (El túnel de seguridad)
resource "azurerm_bastion_host" "hospital_bastion" {
  name                = "Security-Bastion-IaC"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name

  ip_configuration {
    name      = "configuration"
    subnet_id = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}

# 7. Grupo de Seguridad de Red (NSG) - El Escudo
resource "azurerm_network_security_group" "workload_nsg" {
  name                = "NSG-Workload-Security"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name

  security_rule {
    name                       = "AllowBastionInbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389" # RDP seguro
    source_address_prefix      = "10.10.2.0/26" # Solo desde la Subred del Bastion
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "DenyAllInbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# 8. Asociación del NSG a la Subred (Vinculación obligatoria)
resource "azurerm_subnet_network_security_group_association" "workload_assoc" {
  subnet_id                 = azurerm_subnet.workload_subnet.id
  network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

# 9. IP Pública para el WAF (El punto de entrada al hospital)
resource "azurerm_public_ip" "waf_ip" {
  name                = "IP-WAF-Prod"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 10. Política de Seguridad WAF (Reglas de detección de ataques)
resource "azurerm_web_application_firewall_policy" "hospital_waf_policy" {
  name                = "WAF-Policy-Hospital"
  resource_group_name = azurerm_resource_group.hospital_rg.name
  location            = azurerm_resource_group.hospital_rg.location

  policy_settings {
    enabled = true
    mode    = "Prevention" # Bloquea el ataque, no solo avisa
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2" # Estándar de la industria contra Inyección SQL/XSS
    }
  }
}
