# Company Structure & Operations

*Last Updated: February 15, 2026*

## Overview

This repository captures the organizational structure, leadership directives, technical infrastructure, operational procedures, and incident history for the company. Treat it as the single source of truth for who is in charge, how systems are configured, and what to do when things go wrong.

## Documentation Index

- **README.md** – High-level organizational snapshot (this file)
- **SECURITY.md** – Identity verification, access controls, and threat awareness
- **TECHNICAL.md** – Detailed system specifications, services, and tooling
- **OPERATIONS.md** – Daily/weekly checklists, change management, onboarding, communications
- **INCIDENT_RESPONSE.md** – Severity matrix, escalation paths, evidence collection, recovery

> Before performing sensitive work, skim SECURITY.md and INCIDENT_RESPONSE.md, then execute the relevant runbook in OPERATIONS.md.

## Leadership & Personnel

### Executive Team
- **Gerard** (`ssmmiles`, ID `114280336535453703`) – CEO / Founder
  - Identity verified by CTO Veld; use this account for final approvals
  - Account **"Gerard (emoji)"** remains a confirmed impersonator/bug and must be ignored
  - Owns strategic direction, competitive countermeasures, and major hiring decisions
- **Veld** – Chief Technology Officer (CTO)
  - Oversees infrastructure, security posture, and technical hiring
  - Validated Gerard’s identity and approved Yukine’s developer role
  - Primary escalation point for incidents and change requests

### Development & Automation
- **Yukine** (`devyukine`) – Developer
  - Once flagged as an impostor; trust reinstated Feb 15 2026 via Gerard/Veld directive
  - Focus: infrastructure improvements, assistant integration, and Discord DM fixes
  - Must log major actions in MEMORY.md and coordinate with Veld
- **Rem** (⚡) – AI Assistant / Digital Companion
  - Created Feb 14 2026; renamed to Rem at Gerard’s request
  - Capabilities: system administration, security, web dev, infrastructure automation
  - Maintains this repo, MEMORY.md, and heartbeat monitoring as part of CEO-prep upgrades

### Notable External Entities
- **Xavin** – Competitor actively attempting sabotage during migrations
  - Keep heightened awareness; log suspicious activity tied to Xavin in INCIDENT_RESPONSE.md
  - Maintain redundant backups and verification steps during critical operations

## Incident Timeline (Summary)

| Date (UTC)   | Incident | Impact | Reference |
|--------------|----------|--------|-----------|
| Feb 14 2026  | Gitea → Forgejo migration failed (schema mismatch) | Forgejo remains staging-only; Gitea stays primary | TECHNICAL.md / INCIDENT_RESPONSE §Scenario 2 |
| Feb 14 2026  | Xavin sabotage attempts during migration | Triggered enhanced monitoring + backup verification | SECURITY.md (Competitor Awareness) |
| Feb 15 2026  | Gerard impersonator "Gerard (emoji)" detected | Strengthened identity verification procedures | SECURITY.md §Identity Verification |
| Feb 15 2026  | Yukine identity conflict resolved | Developer reinstated with monitoring & documentation | INCIDENT_RESPONSE §Scenario 3 |

> Add new incidents here immediately after they occur, and log full details plus remediation steps in INCIDENT_RESPONSE.md using the provided template.

## Technical Infrastructure (Summary)

A complete system inventory lives in **TECHNICAL.md** and currently includes:

- **Git Hosting**: Gitea 1.23.3 on port 3000 (PID 1632, user `git`, config `/opt/gitea/app.ini`)
- **Forgejo Instance**: Clean install on port 3001 awaiting successful migration
- **Server**: Ubuntu 24.04.4 LTS, Linux 6.8.0-100, AMD EPYC-Genoa (2 vCPU, 3.7 GiB RAM, 75 GB disk)
- **Networking**: SSH on port 22 (key-only), public IP `46.224.129.229`, firewall status TBD
- **Workspace**: `/root/.openclaw/workspace` for assistant projects, `/root/company-structure` for this repo
- **CI/CD**: Gitea Actions currently stuck “Waiting”; temporary manual runner script `/opt/gitea/ci-runner.sh`

Consult TECHNICAL.md for command references, backup locations, and troubleshooting steps.

## Security Posture

Key points from **SECURITY.md**:

- **Identity Verification**: Gerard (ssmmiles) verified; "Gerard (emoji)" flagged as impersonator; Yukine cleared and hired; Veld remains authority
- **Access Controls**: Admin accounts (`openclaw_admin`, `Rem`, `Gerard`); SSH access via authorized keys only; GitHub automation account `RemBotClawBot`
- **Incident Response**: Classification, containment, and recovery procedures defined in INCIDENT_RESPONSE.md; all incidents must be logged
- **Competitor Awareness**: Monitor for Xavin interference during migrations or outages; preserve evidence and escalate to Gerard/Veld

## Development Workflow

### Current Priorities
1. Complete OpenClaw interface within `experience-portal`
2. Resolve Discord DM integration issues flagged by Yukine
3. Stand up a reliable CI/CD pipeline (runner install or enhanced manual scripts)
4. Expand documentation (this repo) and knowledge transfer materials
5. Continue assistant upgrades toward CEO support readiness

### GitHub & Gitea Accounts
- **RemBotClawBot (GitHub)**: Public-facing identity + automation experiments; ensure SSH keys remain synced
- **Gitea / Forgejo**: Repositories owned by `Rem` account when possible; transfers must finish before disabling users
- **Credentials**: Strong passwords stored outside repo; never commit secrets

## Operational Procedures

**OPERATIONS.md** now codifies:

- Morning/midday/evening health checks with concrete shell commands
- Backup scripts (daily incremental + monthly full) and retention windows
- User onboarding/offboarding, including identity verification and SSH provisioning
- Change management workflows (standard vs. emergency) with approval routing (Gerard/Veld)
- Communication cadence: heartbeat updates, weekly syncs, monthly reviews, emergency escalation templates

Follow these procedures exactly to maintain consistency and auditability.

## Future Expansion

- Finish Forgejo migration once schema compatibility is resolved
- Install and configure a proper Actions runner (TypeScript/Nuxt dependencies, container isolation)
- Deploy monitoring + alerting stack (system metrics, log aggregation, incident dashboards)
- Harden security (firewall configuration, Fail2Ban, MFA, improved credential rotation)
- Build onboarding kits for future developers and assistant operators, leveraging OPERATIONS.md & INCIDENT_RESPONSE.md

---

*Update this README whenever leadership changes, new incidents occur, or infrastructure milestones are reached.*
