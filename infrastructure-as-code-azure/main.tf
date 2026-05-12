# 1. Resource Group
resource "azurerm_resource_group" "hospital_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = { Environment = "Production", ManagedBy = "Terraform" }
}

# 2. Virtual Network (VNet)
resource "azurerm_virtual_network" "hospital_vnet" {
  name                = "VNet-Secure-IaC"
  address_space       = ["10.10.0.0/16"]
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
}

# 3. Subnetwork for the Bastion
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hospital_rg.name
  virtual_network_name = azurerm_virtual_network.hospital_vnet.name
  address_prefixes     = ["10.10.2.0/26"]
}

# 4. Subnet for Virtual Machines
resource "azurerm_subnet" "workload_subnet" {
  name                 = "Workload-Subnet"
  resource_group_name  = azurerm_resource_group.hospital_rg.name
  virtual_network_name = azurerm_virtual_network.hospital_vnet.name
  address_prefixes     = ["10.10.1.0/24"]
}

# 5. Public IP for the Bastion (Requirement: Standard SKU)
resource "azurerm_public_ip" "bastion_ip" {
  name                = "IP-Bastion-IaC"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 6. The Bastion Host (The Security Tunnel)
resource "azurerm_bastion_host" "hospital_bastion" {
  name                = "Security-Bastion-IaC"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet.id
    public_ip_address_id = azurerm_public_ip.bastion_ip.id
  }
}

# 7. Network Security Group (NSG) - The Shield
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
    destination_port_range     = "3389"         # RDP seguro
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

# 8. NSG Association to Subnetwork (Mandatory Linking)
resource "azurerm_subnet_network_security_group_association" "workload_assoc" {
  subnet_id                 = azurerm_subnet.workload_subnet.id
  network_security_group_id = azurerm_network_security_group.workload_nsg.id
}

# 9. Public IP address for the WAF (The hospital's entry point)
resource "azurerm_public_ip" "waf_ip" {
  name                = "IP-WAF-Prod"
  location            = azurerm_resource_group.hospital_rg.location
  resource_group_name = azurerm_resource_group.hospital_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2", "3"] #Healthcare/Banking Level Resilience
}

# 10. WAF Security Policy (Attack Detection Rules)
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

# 11. Specific subnet for the WAF
resource "azurerm_subnet" "waf_subnet" {
  name                 = "WAF-Subnet"
  resource_group_name  = azurerm_resource_group.hospital_rg.name
  virtual_network_name = azurerm_virtual_network.hospital_vnet.name
  address_prefixes     = ["10.10.3.0/24"]
}

# 12. Application Gateway con WAF (El Escudo Activo)
resource "azurerm_application_gateway" "hospital_appgw" {
  name                = "AppGW-Hospital-Secure"
  resource_group_name = azurerm_resource_group.hospital_rg.name
  location            = azurerm_resource_group.hospital_rg.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.waf_subnet.id
  }

  frontend_port {
    name = "http_port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip-configuration"
    public_ip_address_id = azurerm_public_ip.waf_ip.id
  }

  backend_address_pool {
    name = "hospital-backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "my-frontend-ip-configuration"
    frontend_port_name             = "http_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "hospital-backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 1
  }

  firewall_policy_id = azurerm_web_application_firewall_policy.hospital_waf_policy.id
}

# 13. Resource Lock: Business Continuity (Resilience)
# Prevents accidental deletion of the core infrastructure.
resource "azurerm_management_lock" "hospital_lock" {
  name       = "CanNotDelete-Core-Infrastructure"
  scope      = azurerm_resource_group.hospital_rg.id
  lock_level = "CanNotDelete"
  notes      = "Critical Healthcare Infrastructure: Protected against accidental deletion for NIS2 compliance."
}

# 14. Azure Key Vault: The Hospital's Safe (Secrets Management)
# ISO 27001 A.8.24 Compliance
resource "azurerm_key_vault" "hospital_vault" {
  name                        = "KV-Hospital-Secure-IaC" # Nombre único
  location                    = azurerm_resource_group.hospital_rg.location
  resource_group_name         = azurerm_resource_group.hospital_rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = "5b493d47-78eb-4af6-ae46-ac682353ee07" # Tu ID de inquilino
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = "5b493d47-78eb-4af6-ae46-ac682353ee07"
    object_id = "vicky-object-id" # Lo cambiaremos mañana en el repaso de variables

    key_permissions = ["Get", "List", "Create"]
    secret_permissions = ["Get", "List", "Set"]
  }
}
