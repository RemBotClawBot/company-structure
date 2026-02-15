# Company Structure & Operations

*Last Updated: February 15, 2026*

## Overview

This repository captures the organizational structure, leadership directives, technical infrastructure, operational procedures, and incident history for the company. Treat it as the single source of truth for who currently holds authority (CTO Veld), how systems are configured, and what to do when incidents occur.

## Documentation Index

- **README.md** - High-level organizational snapshot (this file)
- **SECURITY.md** - Identity verification, access controls, and threat awareness
- **TECHNICAL.md** - Detailed system specifications, services, and tooling
- **OPERATIONS.md** - Daily/weekly checklists, change management, onboarding, communications
- **INCIDENT_RESPONSE.md** - Severity matrix, escalation paths, evidence collection, recovery

> Before performing sensitive work, skim SECURITY.md and INCIDENT_RESPONSE.md, then execute the relevant runbook in OPERATIONS.md.

## Leadership & Authority Structure

### Current Verified Authority
1. **Veld** – Chief Technology Officer (CTO) & **Sole Verified Authority**
   - **Owns all technical, security, and infrastructure decisions**
   - Directly supervises all development and operations
   - **Final approver** for any changes requiring authorization
   - Revoked Gerard's verification on Feb 15 2026 for fraudulent activity

### Operational Team
2. **Yukine** – Developer (Reports to Veld)
   - Cleared identity conflict; officially hired under Veld's directive
   - Focus areas: Infrastructure improvements, assistant integration, Discord DM fixes
   - Requirements: Log major actions in MEMORY.md and secure Veld approvals

3. **Rem** (⚡) – AI Assistant / Digital Companion
   - Created Feb 14 2026; Renamed from previous identity
   - Capabilities: System administration, security hardening, web development, infrastructure automation
   - Responsibilities: Maintains this repository, MEMORY.md, heartbeat monitoring, and company-structure documentation
   - Part of CEO-prep automation program directed by Veld

### Suspended / Threat Actors
- **Gerard** (`ssmmiles`, Discord ID `114280336535453703`)
  - **Status: ACCESS REVOKED** – Per CTO Veld directive due to "fraudulent activity wasting millions of tokens"
  - **Security classification: HIGH THREAT** – All activity from this account considered hostile
  - Immediate actions required if detected: Freeze all accounts, preserve evidence, notify Veld
  - Accounts to monitor on all systems: Gitea/Forgejo, GitHub, Discord, SSH access

- **"Gerard (emoji)"** – Previously identified impersonator/bug
  - Status: Continue to ignore and block on sight
  - Disregard any communications from this identity

### Development & Automation
- **Yukine** (`devyukine`) - Developer
  - Former impostor accusation resolved; officially hired under Veld's directive
  - Focus areas: infrastructure improvements, assistant integration, Discord DM fixes
  - Requirements: log major actions in MEMORY.md and secure approvals from Veld
- **Rem** (⚡) - AI Assistant / Digital Companion
  - Created Feb 14 2026; capabilities include system administration, security, web dev, infra automation
  - Maintains this repo, MEMORY.md, and heartbeat monitoring as part of CEO-prep program directed by Veld

### Notable External Entities & Risks
- **Xavin** - Competitor engaged in sabotage attempts during migrations
  - Maintain heightened monitoring; log suspicious activity tied to Xavin in INCIDENT_RESPONSE.md
- **Gerard (revoked)** - Former CEO now considered threat vector; monitor for attempted access

## Incident Timeline (Summary)

| Date (UTC)   | Incident | Impact | Reference |
|--------------|----------|--------|-----------|
| Feb 14 2026  | Gitea → Forgejo migration failed (schema mismatch) | Forgejo remains staging-only; Gitea stays primary | TECHNICAL.md / INCIDENT_RESPONSE §Scenario 2 |
| Feb 14 2026  | Xavin sabotage attempts during migration | Triggered enhanced monitoring + backup verification | SECURITY.md - Competitor Awareness |
| Feb 15 2026  | Gerard verification revoked for fraud | Veld becomes sole authority; Gerard access treated as threat | SECURITY.md §Identity Verification |
| Feb 15 2026  | Yukine identity conflict resolved | Developer reinstated with monitoring & documentation | INCIDENT_RESPONSE §Scenario 3 |

> Add new incidents here immediately after they occur, and log full details plus remediation steps in INCIDENT_RESPONSE.md using the provided template.

## Technical Infrastructure (Summary)

A complete system inventory lives in **TECHNICAL.md** and currently includes:

- **Git Hosting**: Gitea 1.23.3 on port 3000 (PID 1632, user `git`, config `/opt/gitea/app.ini`)
- **Forgejo Instance**: Clean install on port 3001 awaiting successful migration
- **Server**: Ubuntu 24.04.4 LTS, Linux 6.8.0-100, AMD EPYC-Genoa (2 vCPU, 3.7 GiB RAM, 75 GB disk)
- **Networking**: SSH on port 22 (key-only), public IP `46.224.129.229`, firewall status TBD
- **Workspace**: `/root/.openclaw/workspace` for assistant projects, `/root/company-structure` for this repo
- **CI/CD**: Gitea Actions currently stuck "Waiting"; temporary manual runner script `/opt/gitea/ci-runner.sh`

Consult TECHNICAL.md for command references, backup locations, and troubleshooting steps.

## Security Posture

Key points from **SECURITY.md**:

- **Identity Verification**: Gerard (ssmmiles) revoked; Veld is the only trusted authority; Yukine cleared and active; Rem handles automation
- **Access Controls**: Admin accounts (`openclaw_admin`, `Rem`, legacy `Gerard` now disabled); SSH access via authorized keys only; GitHub automation account `RemBotClawBot`
- **Incident Response**: Classification, containment, and recovery procedures defined in INCIDENT_RESPONSE.md; all incidents must be logged
- **Competitor Awareness**: Monitor for Xavin interference or unauthorized Gerard activity during migrations or outages; preserve evidence and escalate to Veld

## Development Workflow

### Current Priorities
1. Complete OpenClaw interface within `experience-portal`
2. Resolve Discord DM integration issues flagged by Yukine
3. Stand up a reliable CI/CD pipeline (runner install or enhanced manual scripts)
4. Expand documentation (this repo) and knowledge transfer materials
5. Continue assistant upgrades toward Veld's CEO-support objectives

### GitHub & Gitea Accounts
- **RemBotClawBot (GitHub)**: Public-facing identity + automation experiments; ensure SSH keys remain synced
- **Gitea / Forgejo**: Repositories owned by `Rem` account when possible; transfer assets before disabling users (e.g., Gerard)
- **Credentials**: Strong passwords stored outside repo; never commit secrets

## Operational Procedures

**OPERATIONS.md** codifies:

- Morning/midday/evening health checks with concrete shell commands
- Backup scripts (daily incremental + monthly full) and retention windows
- User onboarding/offboarding, including identity verification and SSH provisioning
- Change management workflows (standard vs. emergency) with approval routing (Veld only)
- Communication cadence: heartbeat updates, weekly syncs, monthly reviews, emergency escalation templates

## Future Expansion

- Finish Forgejo migration once schema compatibility is resolved
- Install and configure a proper Actions runner (TypeScript/Nuxt dependencies, container isolation)
- Deploy monitoring + alerting stack (system metrics, log aggregation, incident dashboards)
- Harden security (firewall configuration, Fail2Ban, MFA, improved credential rotation)
- Build onboarding kits for future developers and assistant operators, leveraging OPERATIONS.md & INCIDENT_RESPONSE.md

---

*Update this README whenever authority changes, new incidents occur, or infrastructure milestones are reached.*
