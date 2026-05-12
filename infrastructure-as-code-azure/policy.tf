# 1. GDPR Compliance: Restrict Resource Deployment to EU Regions
# Ensures healthcare data remains within European sovereignty boundaries.
resource "azurerm_subscription_policy_assignment" "gdpr_location" {
  name                 = "Enforce-GDPR-Location"
  subscription_id      = "/subscriptions/5b493d47-78eb-4af6-ae46-ac682353ee07"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/e56962a6-4747-49cd-b67b-bf8b01975c4c"
  display_name         = "GDPR: Restricted Locations (EU Only)"
  description          = "Governance guardrail to prevent data residency issues by limiting deployments to EU regions."

  parameters = <<PARAMS
    {
      "listOfAllowedLocations": {
        "value": ["denmarkeast", "westeurope", "northeurope"]
      }
    }
PARAMS
}

# 2. NIS2 & ISO 27001 Compliance: Mandatory Asset Tagging
# Enforces the 'Environment' tag to ensure proper asset classification and auditability.
resource "azurerm_subscription_policy_assignment" "tagging_policy" {
  name                 = "Enforce-Asset-Tagging"
  subscription_id      = "/subscriptions/5b493d47-78eb-4af6-ae46-ac682353ee07"
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/1e30110a-5ceb-460c-a204-c1c3969c6d62"
  display_name         = "ISO 27001: Required Environment Tag"
  description          = "Ensures all resources are tagged with their respective environment for governance and cost tracking."

  parameters = <<PARAMS
    {
      "tagName": {
        "value": "Environment"
      }
    }
PARAMS
}

