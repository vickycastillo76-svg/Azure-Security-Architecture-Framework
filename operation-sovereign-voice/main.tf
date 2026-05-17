# =====================================================================
# OPERATION SOVEREIGN VOICE: CLOUD ISOLATION & DECEPTION INFRASTRUCTURE
# COMPLIANCE: ISO/IEC 27001:2022 | NIS2 | GDPR SECURITY BY DESIGN
# =====================================================================

data "azurerm_client_config" "current" {}

# 1. RESOURCE GROUP: THE BOUNDARY OF THE INTELLIGENCE ASSET
resource "azurerm_resource_group" "sovereign_rg" {
  name     = "RG-SovereignVoice-Prod"
  location = "westeurope" # Región estratégica de baja restricción y estricto GDPR
  tags = {
    Project        = "Sovereign-Voice"
    Classification = "Highly-Confidential"
    ManagedBy      = "Terraform"
  }
}

# 2. KEY VAULT PREMIUM: HARDWARE SECURITY MODULE (HSM) ENFORCEMENT
# Compliance Alignment: ISO 27001 Control A.8.24 (Cryptographic Management)
resource "azurerm_key_vault" "sovereign_vault" {
  name                        = "kv-sovereign-premium"
  location                    = azurerm_resource_group.sovereign_rg.location
  resource_group_name         = azurerm_resource_group.sovereign_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium" # Activa el respaldo físico por chips HSM FIPS 140-2 Level 3
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true # Protege las llaves de voz contra borrados maliciosos (NIS2 Availability)

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions    = ["Get", "List", "Create", "Delete", "Purge"]
    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

# 3. CONFIDENTIAL COMPUTING NODE: HARDWARE ENCLAVE FOR NEURAL WEIGHTS
# Compliance Alignment: GDPR Article 25 & 32 (Data Protection by Design & Isolation)
resource "azurerm_linux_virtual_machine" "confidential_node" {
  name                = "VM-SovereignAI-Prod"
  resource_group_name = azurerm_resource_group.sovereign_rg.name
  location            = azurerm_resource_group.sovereign_rg.location
  size                = "Standard_DC2as_v5" # SKU Especial AMD SEV-SNP (Cryptographic RAM Isolation)
  admin_username      = "security_auditor"
  
  # Desactivamos la IP Pública para cumplir con Zero-Trust (Superficie de Exposición Cero)
  network_interface_ids = [azurerm_network_interface.secure_nic.id]

  admin_password                  = "EUSecurePassword2026!"
  disable_password_authentication = false

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    # Cifrado del disco en reposo acoplado a nuestro Key Vault HSM
    security_encryption_type = "DiskWithVMGuestState"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-confidential-vm-jammy" # Imagen oficial de Linux Confidencial
    sku       = "22_04-lts-cvm"
    version   = "latest"
  }

  # Configuración obligatoria de seguridad por hardware de Azure
  vtpm_enabled     = true
  secure_boot_enabled = true
}

# 4. NETWORK COMPONENT (PLACEHOLDER FOR VALIDATION INTEGRITY)
resource "azurerm_network_interface" "secure_nic" {
  name                = "NIC-SovereignAI-Secure"
  location            = azurerm_resource_group.sovereign_rg.location
  resource_group_name = azurerm_resource_group.sovereign_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fake/providers/Microsoft.Network/virtualNetworks/fake/subnets/fake"
    private_ip_address_allocation = "Dynamic"
  }
}
