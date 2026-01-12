
# Azure SRE Lab – Virtual WAN Landing Zone

This repository contains a **hands-on Azure Site Reliability Engineering (SRE) lab** built using **Azure Landing Zone (ALZ) principles** and **Azure Virtual WAN (vWAN)**. The lab is intentionally structured to mirror **real-world enterprise network architecture** while remaining approachable for learning, experimentation, and demos.

The primary focus areas are:

- Azure core networking observability
- Virtual WAN hub-and-spoke routing
- VNet and NSG flow logs
- Azure Route Server and routing diagnostics
- Foundations for Azure SRE Agent–style investigations

---

## High-Level Architecture

The lab follows a **Landing Zone + Virtual WAN** design:

- **Central US** is the primary region
- A single **Virtual WAN** with a **Virtual Hub** acts as the network core
- Multiple **spoke VNets** connect to the vHub
- Addressing is private-only and RFC 1918 compliant
- Observability is centralized for SRE-style root cause analysis

App Spoke VNet
           |
           |
    +----------------+
    |  Virtual Hub   |  <-- Azure Virtual WAN (Central US)
    +----------------+
           |
           |
 Shared Services Spoke VNet

 ---

## Address Planning

This lab uses a **structured, private-only IP addressing plan** designed to resemble real-world enterprise Azure environments while remaining easy to reason about during troubleshooting and SRE exercises.

### Design Principles

- Use **RFC 1918 private address space** only
- Allocate **one /16 per Azure region** for clean growth and isolation
- Reserve **non-overlapping address space** for Virtual WAN hubs
- Use predictable subnet sizing for observability and routing analysis
- Optimize for **Virtual WAN, BGP, and flow log scenarios**

---

### Global Addressing Strategy

The lab uses the `10.0.0.0/8` private range with a **region-per-/16** model.

This approach allows:
- Simple summarization in routing tables
- Clean inter-region growth
- Predictable troubleshooting during incidents

---

### Central US Address Allocation

Central US is the **primary region** for this lab and consumes the entire `10.0.0.0/16` range.

| Component               | CIDR           | Notes |
|------------------------|----------------|------|
| Regional Address Space | `10.0.0.0/16`  | Dedicated to Central US |
| Virtual WAN vHub       | `10.0.0.0/23`  | Reserved exclusively for vHub |
| App Spoke VNet         | `10.0.16.0/22` | Application workloads |
| Shared Services Spoke  | `10.0.20.0/22` | DNS, jump hosts, shared services |

> ⚠️ **Important:**  
> The Virtual Hub address space **must not overlap** with any spoke VNet address ranges.

---

### Virtual Hub Addressing

Azure Virtual WAN hubs require a **large, contiguous address prefix**.  
For this lab, the vHub uses a `/23`.

Virtual Hub (Central US)
CIDR: 10.0.0.0/23
Range: 10.0.0.0 – 10.0.1.255

### Spoke VNet Addressing

Each spoke VNet uses a `/22`, which provides **1,024 IP addresses** per spoke.

#### Application Spoke VNet
Example subnet breakdown:

| Subnet Purpose        | CIDR             |
|----------------------|------------------|
| Web Tier             | `10.0.16.0/25`   |
| API Tier             | `10.0.16.128/25` |
| Private Endpoints    | `10.0.17.0/26`   |
| Reserved / Growth    | Remaining space  |

---

#### Shared Services Spoke VNet
Example subnet breakdown:

| Subnet Purpose   | CIDR            |
|-----------------|-----------------|
| Shared Services | `10.0.20.0/24`  |
| Management      | `10.0.21.0/24`  |
| Reserved        | Remaining space |

---

### Why This Matters for SRE Labs

This addressing model makes it easier to:

- Trace traffic paths using VNet and NSG flow logs
- Understand routing propagation in Virtual WAN
- Design BGP and Route Server test scenarios
- Identify asymmetric routing or blackholed prefixes
- Explain incidents clearly during reviews or demos

Clear address boundaries = faster root cause analysis.

---
## Disclaimer
This lab is intended for learning and demonstration purposes. It is not production-hardened and omits some controls (firewalls, forced tunneling, policy enforcement) intentionally to keep the environment easy to reason about.