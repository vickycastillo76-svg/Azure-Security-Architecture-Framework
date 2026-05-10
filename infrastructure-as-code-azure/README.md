# 🏗️ Module: Secure Infrastructure as Code (Terraform)
**Project:** High-Availability Healthcare Infrastructure 
**Location:** `denmarkeast` (EU Data Sovereignty)

This module implements a **Zero Trust** network architecture and Layer 7 application security for a critical hospital environment. It focuses on micro-segmentation and automated compliance.

---

### ⚖️ Regulatory & Compliance Mapping
The following table maps the technical resources defined in `main.tf` to international security standards.


| Technical Resource | Standard / Control | Security Objective |
| :--- | :--- | :--- |
| **VNET & Subnets** (#2, 3, 4, 11) | **ISO 27001:2022 A.8.20** | **Network Segmentation:** Isolated tiers for WAF, Management (Bastion), and Medical Workloads. |
| **Azure Bastion** (#6) | **GDPR Art. 32 / NIS2** | **Secure Management:** "Zero Public IP" administration via TLS. Eliminates RDP/SSH exposure. |
| **NSG Shield** (#7, 8) | **ISO 27001:2022 A.8.22** | **Micro-segmentation:** "Deny by Default" ingress policy to mitigate lateral movement. |
| **WAF Policy** (#10) | **OWASP Top 10** | **Active Defense:** `Prevention` mode enabled to block SQL Injection and Cross-Site Scripting (XSS). |
| **Application Gateway** (#12)| **NIS2 / ISO A.8.14** | **Layer 7 Inspection:** Centralized reverse proxy for deep packet inspection and traffic governance. |
| **Resilient Public IP** (#9) | **ISO 27001:2022 A.8.14** | **High Availability:** 3-Zone redundancy to ensure healthcare service continuity. |

---

### 🚀 Technical Assets & Patterns
- **Idempotency:** Fully managed via Terraform (v1.15.x).
- **Security-First Design:** Managed Rulesets (OWASP 3.2) applied at the edge.
- **Auditability:** Resource tagging for Environment (Production) and Management (Terraform) tracking.

### 🛠️ Validation Workflow
To verify the integrity and security posture of this module, execute:
```bash
terraform init
terraform validate
terraform plan
```
---
**Note:** This module is part of the *Azure Enterprise Security Architecture Framework*.
