# =====================================================================
# OPERATION SOVEREIGN VOICE: LAYER 7 PERIMETER DEFENSE & DECEPTION POLICY
# COMPLIANCE: ISO/IEC 27001:2022 A.8.20 & A.8.22 | NIS2 PERIMETER HARDENING
# =====================================================================

# 1. WEB APPLICATION FIREWALL (WAF) POLICY IN PREVENTION MODE
# Compliance Alignment: ISO 27001 Control A.8.24 & OWASP Top 10 Mitigation
resource "azurerm_web_application_firewall_policy" "sovereign_waf" {
  name                = "waf-sovereign-policy"
  resource_group_name = "RG-SovereignVoice-Prod"
  location            = "westeurope"

  policy_settings {
    enabled       = true
    mode          = "Prevention" # Bloqueo activo y fulminante de la firma del atacante
    request_body_check = true
    max_request_body_size_in_kb = 128
  }

  # OWASP Core Ruleset 3.2: Activación de firmas contra SQLi y XSS
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }

  tags = {
    PolicyType     = "Active-Prevention"
    Infrastructure = "Sovereign-Gate"
  }
}

# 2. DECEPTION ROUTING LAYER: MULTI-STAGE HONEYPOT ENFORCEMENT
# Principal Strategy: Defense in Depth & Adversary Deception
resource "azurerm_application_gateway" "sovereign_gateway" {
  name                = "agw-sovereign-ingress"
  resource_group_name = "RG-SovereignVoice-Prod"
  location            = "westeurope"

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  # Vinculación mandatoria del escudo inteligente WAF al cuerpo del Gateway
  firewall_policy_id = azurerm_web_application_firewall_policy.sovereign_waf.id

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fake/providers/Microsoft.Network/virtualNetworks/fake/subnets/fake-waf"
  }

  frontend_port {
    name = "http-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/fake/providers/Microsoft.Network/publicIPAddresses/fake-ip"
  }

  # CONFIGURACIÓN DEL TRIGER DE ENGAÑO (THE MOCK BACKEND)
  backend_address_pool {
    name = "deception-honeypot-pool"
    # Redirige el tráfico del atacante hacia un sumidero controlado (Señuelo)
    fqdns = ["deception.internal.secure.eu"]
  }

  backend_http_settings {
    name                  = "http-deception-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 20
  }

  http_listener {
    name                           = "listener-honeypot"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule-honeypot-interception"
    rule_type                  = "Basic"
    http_listener_name         = "listener-honeypot"
    backend_address_pool_name  = "deception-honeypot-pool"
    backend_http_settings_name = "http-deception-settings"
    priority                   = 100 # Máxima prioridad de inspección y enrutamiento
  }
}
