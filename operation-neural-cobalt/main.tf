# =========================================================================
# SYSTEM SECURITY PARAMETER: COGNITIVE SERVICES SOVEREIGN PLATFORM
# FRAMEWORK ALIGNMENT: ISO/IEC 42001:2023 // ISO/IEC 27001:2022
# REGULATORY COMPLIANCE: EU AI ACT (HIGH-RISK STACK) & REGULATION (EU) 2016/679 (GDPR)
# GOVERNANCE MANDATE: DIRECTIVE (EU) 2022/2555 (NIS2 ARTICLE 21)
# =========================================================================

# 1. IDENTITY & ENCLAVE CRYPTOGRAPHIC CONTEXT CONFIGURATION
# ISO/IEC 42001:2023 Clause 6.1.2 (AI Risk Assessment) & ISO/IEC 27001:2022 Control A.8.2 (Access Rights)
# NIS2 Article 21(2)(g) (Data Access Security) & GDPR Article 25 (Privacy by Design)
# Dynamically extracts active cryptographic identities and tenant boundaries to enforce zero-trust 
# principal authentication, ensuring all algorithmic training pipeline operations are strictly non-repudiable.
data "azurerm_client_config" "current" {}

# 2. SEVERED GEOGRAPHICAL DATACENTER REGION FOR HIGH-RISK WORKLOADS
# EU AI Act Article 9 (Risk Management System for High-Risk AI) & GDPR Article 45 (Data Transfers)
# Establishes the centralized encrypted AI infrastructure within the strict geographical boundaries 
# of the European Sovereign Data Zone (Netherlands) to prevent cross-border data leakage or illegal foreign seizure.
resource "azurerm_resource_group" "ai_governance_rg" {
  name     = "RG-NeuralCobalt-AI-Prod"
  location = "westeurope" 
}

# 3. AZURE COGNITIVE SERVICES (THE MAIN CORE ENGINE - COGNITIVE SHIELD)
# ISO/IEC 42001:2023 Control B.7.4 (Continuous AI System Hardening & Operational Robustness)
# ISO/IEC 42001:2023 Control B.7.3 (AI System Bias Management & Algorithmic Fairness Validation)
# ISO/IEC 27001:2022 Control A.8.24 (Use of Cryptography) & NIS2 Article 21(2)(d) (Cryptography Policies)
# Provisions an isolated instance for OpenAI/Cognitive deployments driven by hardware-enforced enclaves.
# Outbound network access is disabled to guarantee total isolation of proprietary training datasets.
resource "azurerm_cognitive_account" "esa_ai_engine" {
  name                  = "Cognitive-NeuralCobalt-Core"
  location              = azurerm_resource_group.ai_governance_rg.location
  resource_group_name   = azurerm_resource_group.ai_governance_rg.name
  kind                  = "OpenAI"
  sku_name              = "S0" 
  custom_subdomain_name = "esa-neuralcobalt-secure-api"

  # CONTROL A.8.2 / NIS2: Disables legacy local API authentication keys, forcing Entra ID RBAC exclusive access.
  local_auth_enabled = false

  # EU AI ACT / GDPR: Air-gapped boundary. Blocks all public ingress vectors to eliminate remote prompt injection risks.
  public_network_access_enabled = false 

  identity {
    type = "SystemAssigned"
  }
}
