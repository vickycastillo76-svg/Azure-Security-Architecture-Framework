# =========================================================================
# 🕵️‍♂️ OPERATION CLASSIFIED OMNIBUS: SOVEREIGN IaC CORE ARCHITECTURE
# STANDARD: ISO/IEC 27001:2022 & NIS2 COMPLIANCE-AS-CODE
# =========================================================================

# 1. THE RECOGNITION DATA CONFIGURATION
data "azurerm_client_config" "current" {}

# 2. THE RESOURCE GROUP (The Central Intelligence Hub)
resource "azurerm_resource_group" "omnibus_rg" {
  name     = "RG-ClassifiedOmnibus-Prod"
  location = "westeurope" # Países Bajos: Central Data Vault Zone
}

# 3. THE SOBERANO CRYPTOGRAPHIC VAULT (Omnibus Isolation Protocol)
resource "azurerm_key_vault" "omnibus_hsm" {
  name                        = "KV-Omnibus-Sovereign-Keys"
  location                    = "francecentral" # París: Isolated Sovereign Key Zone
  resource_group_name         = azurerm_resource_group.omnibus_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium" # FIPS 140-2 Level 3 Hardware Security Module (HSM)
  purge_protection_enabled    = true      # Anti-Tampering Security Lock (NIS2 compliance)

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Get", "Encrypt", "Decrypt", "Purge", "Recover"
    ]
  }
}

# 4. THE IMMUTABLE FORENSIC REGISTER (Blockchain Auditing)
resource "azurerm_confidential_ledger" "omnibus_blockchain" {
  name                = "ledgerclassifiedomnibus"
  location            = azurerm_resource_group.omnibus_rg.location
  resource_group_name = azurerm_resource_group.omnibus_rg.name
  ledger_type         = "Private"

  # CORREGIDO: Bloque oficial exigido por la bombilla de VS Code para el Proveedor de Azure
  azuread_based_service_principal {
    principal_id = data.azurerm_client_config.current.object_id
    tenant_id    = data.azurerm_client_config.current.tenant_id
    ledger_role_name = "Administrator"
  }
}

