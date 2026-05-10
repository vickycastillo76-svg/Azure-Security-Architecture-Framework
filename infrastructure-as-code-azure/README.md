# 🏗️ Module 1: Secure Infrastructure as Code (Terraform)
**Project:** Healthcare Enterprise Architecture 
**Compliance Standards:** ISO 27001:2022 | GDPR | NIS2 | OWASP Top 10

This module defines the core secure network perimeter for a hospital environment, enforcing **Zero Trust** principles at every layer.

### 📋 Technical Compliance Mapping


| Resource | Control | Objective |
| :--- | :--- | :--- |
| **VNET & Subnets** | **ISO A.8.20** | Network segmentation separating WAF, Management, and Workload tiers. |
| **Azure Bastion** | **GDPR Art. 32** | Zero-exposure administration. No Public IPs on internal nodes. |
| **NSG Shield** | **ISO A.8.22** | "Deny by Default" ingress logic to mitigate lateral movement. |
| **WAF Policy** | **OWASP / NIS2** | Active **Prevention** mode against SQLi and XSS attacks. |
| **App Gateway** | **ISO A.8.14** | Layer 7 Traffic Governance and centralized security inspection. |
| **Resilient IP** | **NIS2 / Availability** | **High Availability:** 3-Zone redundancy for critical service continuity. |

### 🛠️ Validation Workflow
```bash
terraform init
terraform validate
terraform plan
```
