
## Azure SRE Lab – Approach and Deployment Model

This lab is designed as a **deliberate, SRE‑focused Azure networking environment** built to mirror real‑world enterprise deployments rather than simplified tutorials. The goal is to create an environment that supports **investigation, failure analysis, and operational reasoning**, not just resource creation.

The lab follows **Azure Landing Zone (ALZ) principles** and uses **Azure Virtual WAN (vWAN)** as the foundational network architecture to reflect how large organizations design, operate, and troubleshoot Azure at scale.

---

## Design Philosophy

The lab is built around the following guiding principles:

- **Production realism over minimalism**  
  Architectural choices favor enterprise patterns that organizations actually use, even when they add complexity.

- **Observability-first mindset**  
  Every deployment decision is made with downstream investigation, telemetry, and troubleshooting in mind.

- **Incremental, layered deployment**  
  The environment is deployed in logical phases, allowing each layer to be reasoned about independently:
  networking → observability → workloads → failure scenarios.

- **Intentional fault tolerance and failure testing**  
  The lab is explicitly designed to support breaking things on purpose and understanding *why* they broke.

---

## Core Architecture Model

The lab implements a **hub-and-spoke topology using Azure Virtual WAN**, which provides:

- Centralized routing and connectivity management
- Realistic traffic flow patterns
- Scalable support for future hybrid or multi‑region expansion

### Key architectural components include:

- **Azure Virtual WAN (Standard)**
- **Virtual Hub** acting as the network core
- **Application Spoke VNets** for workload simulation
- **Shared Services Spoke VNets** for platform services
- **Private, non‑overlapping RFC 1918 address space**
- Clear separation of platform and workload resource groups

This structure aligns to how Azure networking is typically deployed in regulated, security‑conscious, or global environments.

---

## Deployment Strategy

The lab is deployed using **infrastructure as code (IaC)** with a focus on clarity and maintainability rather than terseness.

### Deployment characteristics

- Resources are deployed at the **appropriate scope** (platform vs workload)
- Cross‑resource‑group dependencies are handled explicitly
- Child resources are deployed in the same scope as their parents
- Modules are used where scoping boundaries matter (e.g., vHub connections)

This approach reinforces good engineering habits and mirrors patterns used in Microsoft‑led landing zone deliveries.

---

## SRE Focus and Intended Outcomes

This lab is not intended to simply “stand up Azure resources.”  
It is meant to enable deeper SRE‑style questions such as:

- Why is traffic not flowing between two workloads?
- Was the issue caused by routing, security rules, or platform behavior?
- What evidence exists to support the root cause?
- How would an operator explain this failure to another team?

By combining realistic networking, centralized observability, and controlled failure injection, the lab becomes a **foundation for operational learning, demos, and agent‑driven investigations**.

---

## Intended Use Cases

This environment is well suited for:

- Azure SRE Agent demonstrations and PoCs
- Network troubleshooting walkthroughs
- Internal enablement and learning
- Architecture validation exercises
- Controlled incident simulations

---

## Guiding Principle

> **The value of infrastructure is not that it exists — it’s that it can be understood when it fails.**

This lab is built to make Azure networking failures **explainable, observable, and actionable**, which is the core objective of Site Reliability Engineering.
