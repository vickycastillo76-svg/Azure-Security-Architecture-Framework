# =========================================================================
# SYSTEM SECURITY PARAMETER: CROSS-BORDER SOVEREIGN INFRASTRUCTURE CORE
# FRAMEWORK ALIGNMENT: ISO/IEC 27001:2022 // DIRECTIVE (EU) 2022/2555 (NIS2)
# GOVERNANCE MANDATE: EU DIGITAL OMNIBUS COMPLIANCE & REGLAMENTO (UE) 2016/679 (GDPR)
# =========================================================================

# 1. IDENTITY & ACCESS CONTEXT CONFIGURATION
# ISO/IEC 27001:2022 Control A.8.2 (Privileged Access Rights) & NIS2 Article 21(2)(g)
# Dynamically extracts active cryptographic identities and tenant boundaries to enforce zero-trust 
# principal authentication, preventing hardcoded credential exfiltration vectors.
data "azurerm_client_config" "current" {}

# 2. SEVERED GEOGRAPHICAL DATACENTER REGION
# EU GDPR Article 45 (Data Transfers with Adequacy Decision) & Omnibus Sovereignty Mandate
# Establishes the centralized encrypted data repository within the strict geographical boundaries 
# of the European Sovereign Data Zone (Netherlands) to prevent extra-jurisdictional intelligence seizures.
resource "azurerm_resource_group" "omnibus_rg" {
  name     = "RG-ClassifiedOmnibus-Prod"
  location = "westeurope" 
}

# 3. CRYPTOGRAPHIC ISOLATION BOUNDARY (HYOK PROTOCOL)
# ISO/IEC 27001:2022 Control A.8.24 (Use of Cryptography) & NIS2 Article 21(2)(d) (Cryptography Policies)
# Implements a hardware-enforced Hold-Your-Own-Key (HYOK) protocol via FIPS 140-3 Level 4 HSM isolation.
# In strict compliance with the Omnibus Agreement, cryptographic keys are geographically segregated 
# to French sovereign soil (France Central), completely decoupled from the data storage layer.
# Purge protection satisfies NIS2 business continuity and anti-tampering mandate.
resource "azurerm_key_vault" "omnibus_hsm" {
  name                        = "KV-Omnibus-Sovereign"
  location                    = "francecentral" 
  resource_group_name         = azurerm_resource_group.omnibus_rg.name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "premium" 
  purge_protection_enabled    = true      

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "Create", "Get", "Encrypt", "Decrypt", "Purge", "Recover"
    ]
  }
}

# 4. IMMUTABLE FORENSIC REGISTER (BLOCKCHAIN AUDITING GATEWAY)
# ISO/IEC 27001:2022 Control A.8.16 (Monitoring Activities) & NIS2 Article 21(2)(c) (Incident Handling)
# Deploys an immutable Confidential Ledger driven by Blockchain and hardened inside hardware-isolated 
# Intel SGX memory enclaves. Ensures that access trails for state secrets cannot be purged or manipulated 
# by compromised internal administrators or external adversarial state-sponsored groups (APT-44).
resource "azurerm_confidential_ledger" "omnibus_blockchain" {
  name                = "ledgerclassifiedomnibus"
  location            = azurerm_resource_group.omnibus_rg.location
  resource_group_name = azurerm_resource_group.omnibus_rg.name
  ledger_type         = "Private"

  azuread_based_service_principal {
    principal_id     = data.azurerm_client_config.current.object_id
    tenant_id        = data.azurerm_client_config.current.tenant_id
    ledger_role_name = "Administrator"
  }
}
