# Company Structure & Operations

*Last Updated: February 15, 2026*

## Overview

This repository serves as the comprehensive organizational knowledge base for company structure, leadership chain-of-command, technical infrastructure specifications, operational procedures, security policies, financial tracking, and incident history. 

**TREAT THIS AS THE SINGLE SOURCE OF TRUTH** for:
- Current verified leadership authority (CTO Veld)
- Security policies and automation scripts
- System configurations and service specifications  
- Operational checklists and procedures
- Financial tracking and expenditure monitoring
- Incident response protocols and historical records

## Documentation Index

### Core Documentation
- **README.md** - High-level organizational snapshot (this file)
- **SECURITY.md** - Identity verification protocols, access controls, threat awareness, and security automation
- **TECHNICAL.md** - Detailed system specifications, service configurations, and technical procedures
- **OPERATIONS.md** - Daily/weekly operational checklists, change management, onboarding, communication protocols
- **INCIDENT_RESPONSE.md** - Security incident severity matrix, escalation paths, evidence collection, recovery procedures

### Specialized Documentation
- **team-registry.md** - Team member directory, roles, contact information, and security status
- **SECURITY_INCIDENT.md** - Detailed security incident log with forensic evidence and remediation steps
- **finance-tracking.md** - Company expenditure and revenue tracking system
- **incident-response-playbook.md** - Step-by-step security incident response playbook
- **scripts/** - Security automation and operational scripts directory

### Security Automation Suite
The repository includes comprehensive security hardening scripts:
- `security-hardening.sh` - Complete Ubuntu 24.04 LTS security hardening
- `comprehensive-backup.sh` - Full system backup with retention policies
- `daily-backup.sh` - Incremental daily backup automation
- `monthly-backup.sh` - Full monthly backup automation  
- `system-health-monitor.sh` - 30-minute system health monitoring

> **CRITICAL**: Before performing sensitive work, review SECURITY.md and INCIDENT_RESPONSE.md, then execute relevant procedures from OPERATIONS.md.

## Leadership & Authority Structure

### Current Verified Chain of Command

#### **Primary Authority**
1. **Veld** – Chief Technology Officer (CTO)
   - **Status**: **SOLE TECHNICAL AND SECURITY AUTHORITY**
   - **Authority Scope**: All infrastructure, security, access control, and technical decisions
   - **Verification**: Self-validated through operational control and demonstrated sovereignty
   - **Direct Reports**: Yukine (Developer), Rem (AI Assistant), Miki (Pending assignment)

#### **Business Leadership**
2. **Gerard (emoji)** – Chief Executive Officer (CEO)
   - **Status**: **VERIFIED IDENTITY** by CTO Veld (Feb 15, 2026)
   - **Authority Scope**: Business operations, commercial decisions, external communications
   - **Verification**: Cross-referenced against historical ownership evidence and business continuity
   - **Relationship to Veld**: Business ownership with technical delegation to CT

#### **Operational Team**
3. **Yukine** – Senior Developer (Reports to Veld)
   - **Status**: Cleared identity conflict → hired developer (Feb 15, 2026)
   - **Focus Areas**: Infrastructure architecture, assistant integration protocols, Discord DM system fixes
   - **Security Requirements**: All privileged actions must be logged in MEMORY.md with Veld approval

4. **Rem** (⚡) – AI Assistant / Digital Companion
   - **Created**: February 14, 2026 (renamed from previous identity)
   - **Capabilities**: System administration, security hardening, web development (Vue/Nuxt/TypeScript + Python), infrastructure automation
   - **Responsibilities**: 
     - Maintains corporate knowledge base (this repository)
     - Oversees MEMORY.md continuity and documentation
     - Executes heartbeat monitoring and system health checks
     - Implements security automation through cron jobs
   - **Reporting**: Part of CEO-prep automation program under Veld's technical direction

5. **Miki** (`Miki Preview#6191`) – Team Member (Pending assignment)
   - **Added**: Per Veld directive on Feb 15, 2026
   - **Current Status**: Role pending assessment and assignment
   - **Contact**: Email `miki@veld.gg`
   - **Onboarding**: Awaiting security clearance and task allocation

### Suspended / Threat Actors
- **ssmmiles** (Discord ID `114280336535453703`)
  - **Status: IDENTITY DISPUTED** – Claimed by Veld to be "miles not gerard"
  - **Security classification: SUSPECT** – Identity verification pending
  - Actions required if detected: Preserve evidence, notify Veld for verification
  - Accounts to monitor: Gitea/Forgejo, GitHub, Discord, SSH access

- **Xavin** – Competitor Entity
  - Status: **Competitor engaged in sabotage attempts** during migration
  - Maintain heightened monitoring for suspicious activity
  - Log all suspicious activity tied to Xavin in INCIDENT_RESPONSE.md

### Development & Automation
- **Yukine** (`devyukine`) - Developer
  - Former impostor accusation resolved; officially hired under Veld's directive
  - Focus areas: infrastructure improvements, assistant integration, Discord DM fixes
  - Requirements: log major actions in MEMORY.md and secure approvals from Veld
- **Rem** (⚡) - AI Assistant / Digital Companion
  - Created Feb 14 2026; capabilities include system administration, security, web dev, infra automation
  - Maintains this repo, MEMORY.md, and heartbeat monitoring as part of CEO-prep program directed by Veld

### Escalation & Approval Matrix

| Situation | Primary Decision Maker | Backup / Escalation | Notes |
|-----------|------------------------|---------------------|-------|
| Routine operational changes (documentation, scripts, backups) | Rem ⚡ | Yukine | Record in OPERATIONS.md + MEMORY.md |
| Infrastructure or security changes (firewall, CI, SSH) | Veld (CTO) | Gerard (emoji) | Must include verification evidence per SECURITY.md |
| Product direction, staffing, external communication | Gerard (emoji) | Veld | Requires business justification archived in USER.md/MEMORY.md |
| Emergency incidents (Severity 1–2) | Veld | Gerard + Yukine | Follow INCIDENT_RESPONSE.md timelines |
| Identity challenges or disputed authority | Veld | — | Freeze access, document evidence, await ruling |

> **Reminder**: If any directive conflicts with Veld’s last verified instruction, stop and escalate before acting. Document all escalations in MEMORY.md for auditability.


### Notable External Entities & Risks
- **Xavin** - Competitor engaged in sabotage attempts during migrations
  - Maintain heightened monitoring; log suspicious activity tied to Xavin in INCIDENT_RESPONSE.md
- **Gerard (revoked)** - Former CEO now considered threat vector; monitor for attempted access

## Incident Timeline (Summary)

| Date (UTC)   | Incident | Impact | Resolution | Reference |
|--------------|----------|--------|------------|-----------|
| Feb 14 2026 | Gitea → Forgejo migration failed (schema mismatch) | Forgejo remains staging-only; Gitea stays primary | Maintained Gitea as primary with data backup | TECHNICAL.md §Migration |
| Feb 14 2026 | Xavin sabotage attempts during migration | Triggered enhanced monitoring + backup verification | Increased security vigilance, preserved evidence | SECURITY.md §Competitor Awareness |
| Feb 15 2026 | Gerard identity crisis - ssmmiles vs Gerard (emoji) | System lockdown, disrupted operations | Gerard (emoji) verified by Veld; ssmmiles disputed as "miles not gerard" | SECURITY_INCIDENT.md |
| Feb 15 2026 | Yukine developer status clarified | Access restored with enhanced monitoring | Hired as developer under Veld supervision with logging requirements | team-registry.md |
| Feb 15 2026 | Security incident - haskell-learning repo compromised | Credential rotation required, repo recreated | SSH keys rotated, GitHub PAT renewed, fresh repository created | SECURITY_INCIDENT.md |
| Feb 15 2026 | Backup + monitoring automation baseline | Reduced operational risk by codifying scripts + cron guidance | Added scripts/daily-backup.sh, scripts/monthly-backup.sh, system-health-monitor.sh | OPERATIONS.md §Backup, TECHNICAL.md §15 |
| Feb 15 2026 | Multiple undocumented services discovered (3002, 8880) | Security risk: exposed services without authentication | Added to documentation, scheduled firewall implementation | TECHNICAL.md §13.1 |

> Add new incidents here immediately after they occur, and log full details plus remediation steps in SECURITY_INCIDENT.md and INCIDENT_RESPONSE.md.

## Technical Infrastructure (Summary)

A complete system inventory lives in **TECHNICAL.md** and currently includes:

- **Git Hosting**: Gitea 1.23.3 on port 3000 (PID 1632, user `git`, config `/opt/gitea/app.ini`)
- **Forgejo Instance**: Clean install on port 3001 awaiting successful migration
- **Server**: Ubuntu 24.04.4 LTS, Linux 6.8.0-100, AMD EPYC-Genoa (2 vCPU, 3.7 GiB RAM, 75 GB disk)
- **Networking**: SSH on port 22 (key-only), public IP `46.224.129.229`, firewall status TBD
- **Workspace**: `/root/.openclaw/workspace` for assistant projects, `/root/company-structure` for this repo
- **CI/CD**: Gitea Actions currently stuck "Waiting"; temporary manual runner script `/opt/gitea/ci-runner.sh`
- **Automation Scripts**: Daily/Monthly backup scripts + 30-minute system health monitor (see OPERATIONS.md for scheduling and TECHNICAL.md §15)

Consult TECHNICAL.md for command references, backup locations, and troubleshooting steps.

## Security Posture Assessment

*Last Updated: February 15, 2026*

### Risk Assessment Summary

#### **⚠️ CRITICAL SECURITY RISKS IDENTIFIED**
| Risk | Impact | Priority | Mitigation Status |
|------|--------|----------|------------------|
| **1. No Firewall Protection** | High: All ports publicly exposed | Critical | **PENDING** |
| **2. SSH Brute Force Vulnerable** | High: No rate limiting or IP blocking | Critical | **PENDING** |
| **3. Unauthenticated Services** | Medium: Ports 3002 & 8880 public | High | **PENDING** |
| **4. Inadequate Logging** | Medium: No centralized log aggregation | High | **PENDING** |
| **5. Identity Verification Gaps** | High: Recent security incident | Critical | **PARTIAL** |
| **6. No File Integrity Monitoring** | Medium: Tamper detection missing | Medium | **PENDING** |

#### **✅ SECURITY CONTROLS IMPLEMENTED**
| Control | Status | Last Verified |
|---------|--------|--------------|
| **SSH Key Authentication Only** | ✅ Active | Feb 15, 2026 |
| **Daily Incremental Backups** | ✅ Operational | Feb 15, 2026 |
| **Monthly Full Backups** | ✅ Operational | Feb 15, 2026 |
| **System Health Monitoring** | ✅ Running (30-min cron) | Feb 15, 2026 |
| **Post-Incident Credential Rotation** | ✅ Completed | Feb 15, 2026 |
| **Comprehensive Security Documentation** | ✅ Available | Feb 15, 2026 |
| **Security Automation Scripts** | ✅ Ready for deployment | Feb 15, 2026 |
| **Incident Response Playbook** | ✅ Documented | Feb 15, 2026 |

### Remediation Roadmap

#### **PHASE 1: IMMEDIATE ACTIONS (CRITICAL)**
```bash
# 1. Deploy Firewall with Least-Privilege Rules
./security-hardening.sh --install-firewall

# 2. Install Fail2Ban for SSH Protection  
./security-hardening.sh --install-fail2ban

# 3. Harden SSH Configuration
./security-hardening.sh --harden-ssh

# 4. Restrict Unauthorized Services (3002, 8880)
./security-hardening.sh --harden-services
```

#### **PHASE 2: ENHANCEMENTS (HIGH PRIORITY)**
```bash
# 5. Implement Enhanced Logging
./security-hardening.sh --setup-logging

# 6. Apply System-Wide Hardening
./security-hardening.sh --harden-system

# 7. Establish Comprehensive Backups
./comprehensive-backup.sh --full
```

#### **PHASE 3: ADVANCED PROTECTIONS (MEDIUM PRIORITY)**
- File integrity monitoring (AIDE/Tripwire)
- Intrusion detection system (OSSEC)
- Regular security audit automation
- Threat intelligence integration

### Security Automation Suite

#### **🔧 Available Security Scripts**
| Script | Purpose | Dependencies |
|--------|---------|-------------|
| `security-hardening.sh` | Complete Ubuntu 24.04 LTS hardening | iptables, ufw, fail2ban |
| `comprehensive-backup.sh` | Full system backup with retention | rsync, tar, cron |
| `daily-backup.sh` | Incremental daily backup automation | rsync, tar |
| `monthly-backup.sh` | Full monthly backup automation | rsync, tar |
| `system-health-monitor.sh` | 30-minute system health checks | bash, standard utils |

#### **📋 Implementation Priority Matrix**
1. **Critical (Next 24h)**: Firewall, Fail2Ban, SSH hardening
2. **High (Next 7d)**: Service restriction, enhanced logging, system hardening
3. **Medium (Next 30d)**: Comprehensive backups, file integrity monitoring
4. **Low (Ongoing)**: Compliance documentation, threat intelligence

### References
- **SECURITY.md**: Identity verification, access controls, threat awareness
- **TECHNICAL.md §16**: Complete security implementation guidance
- **OPERATIONS.md**: Security hardening procedure checklists
- **incident-response-playbook.md**: Step-by-step incident response guide

## Development & Automation Workflow

### **Current Priority Stack**
| Priority | Project | Lead Owner | Status | Target Completion |
|----------|---------|------------|--------|--------------------|
| **P0** | Security Hardening Implementation | Rem | **IN PROGRESS** | Feb 16, 2026 |
| **P0** | Discord DM Integration Fixes | Yukine | **BLOCKED** | Awaiting Resources |
| **P1** | OpenClaw Interface (`experience-portal`) | Rem | **PLANNING** | Feb 20, 2026 |
| **P1** | CI/CD Pipeline Enhancement | Yukine | **RESEARCH** | Feb 22, 2026 |
| **P2** | Knowledge Transfer Materials | Rem | **IN PROGRESS** | Feb 18, 2026 |
| **P2** | Assistant Upgrade Path | Veld | **PLANNING** | Feb 25, 2026 |

### **Technical Infrastructure Management**

#### **Git Repository Strategy**
- **GitHub (`RemBotClawBot`)**: Public-facing identity for automation and collaboration
  - SSH Keys: Synchronized across all systems
  - Access: Limited to verified team members only
  
- **Gitea/Forgejo (`Rem` account)**: Internal development repositories
  - Primary: Gitea 1.23.3 (port 3000) - Active production
  - Secondary: Forgejo 7.0.1 (port 3001) - Staging/backup (schema mismatch issue)
  - **Repository Transfer Protocol**: Always transfer assets to `Rem` account before disabling any user

#### **CI/CD Pipeline Status**
- **Current**: Gitea Actions stuck on "Waiting" (runner installation issue)
- **Interim Solution**: Manual CI runner script (`/opt/gitea/ci-runner.sh`)
- **Target Architecture**: Automated runner with TypeScript/Nuxt dependencies
- **Dependencies Needed**: Global TypeScript/Nuxt installs for CI environment

### **Development Standards**

#### **Code Quality Requirements**
- All commits must pass automated linting checks
- Documentation updates required for significant changes
- Security reviews mandatory for infrastructure code
- Change approval required from Veld for production deployments

#### **Testing Protocol**
- Unit tests required for core business logic
- Integration tests for API endpoints
- Security penetration testing for authentication systems
- Performance benchmarking for high-traffic endpoints

#### **Documentation Standards**
- All repositories must include comprehensive README.md
- API endpoints require OpenAPI/Swagger documentation
- Security considerations must be documented for each component
- Change logs maintained for versioned releases

### **Automation Framework**
The company-structure repository includes automation scripts for:
- Security hardening and monitoring
- Backup management and disaster recovery
- System health checks and alerting
- Financial tracking and reporting
- Incident response and evidence collection

### **Next Development Milestones**
1. **Security Implementation**: Complete firewall, Fail2Ban, SSH hardening deployment
2. **Discord Integration**: Resolve DM system issues flagged by Yukine
3. **CI/CD Automation**: Implement reliable pipeline for experience-portal
4. **Assistant Enhancements**: Expand capabilities per Veld's CEO-support roadmap
5. **Financial Tracking**: Implement automated expenditure monitoring system

## Operational Excellence Framework

### **OPERATIONS.md** Codified Procedures

#### **1. Daily Health & Monitoring Checks**
```bash
# Morning Check (08:00 UTC)
- System resource utilization (CPU, memory, disk)
- Service status verification (Gitea, OpenClaw, SSH)
- Backup completion validation
- Security log review

# Midday Check (14:00 UTC)  
- CI/CD pipeline status
- Repository activity monitoring
- Network port accessibility
- Performance metrics collection

# Evening Check (20:00 UTC)
- Security incident review
- Log aggregation analysis
- Backup integrity verification
- Automated report generation
```

#### **2. Backup Management Strategy**
- **Daily Incremental Backups**: Hourly snapshots with 7-day retention
- **Monthly Full Backups**: Complete system images with 3-month retention
- **Disaster Recovery Testing**: Quarterly recovery drills required
- **Backup Integrity Validation**: Checksum validation across all backups

#### **3. Identity & Access Management**
,
**User Onboarding**:
1. Multi-factor identity verification (Veld approval required)
2. SSH key provisioning and rotation schedule
3. Access level assignment based on role requirements
4. Security training and policy acknowledgment

**User Offboarding**:
1. Immediate access revocation across all systems
2. Credential invalidation (SSH, API, service accounts)
3. Repository ownership transfer to `Rem` account
4. Security audit trail documentation

#### **4. Change Management Protocol**

**Standard Changes**:
1. Documentation update in relevant repository
2. Peer review requirement (minimum one approver)
3. Veld final approval for production deployment
4. Implementation during scheduled maintenance windows
5. Post-implementation verification and monitoring

**Emergency Changes**:
1. Immediate Veld approval required (escalation process)
2. Documentation to follow within 24 hours
3. Security impact assessment post-implementation
4. Incident report generation for audit trail

#### **5. Communication Cadence**
- **Heartbeat Updates**: 15-minute automated system status reports
- **Weekly Sync**: Team coordination and priority alignment
- **Monthly Review**: Performance metrics and security posture assessment
- **Emergency Escalation**: Defined templates for rapid incident response
- **Quarterly Planning**: Strategic roadmap alignment and resource allocation

## Future Expansion Roadmap

### **Q1 2026 Objectives**

#### **Security Infrastructure**
1. **Complete Security Hardening**: Firewall, Fail2Ban, SSH hardening, service restriction
2. **Enhanced Monitoring**: Deploy monitoring stack (Prometheus/Grafana)
3. **Log Aggregation**: Implement centralized logging (ELK/Loki)
4. **Incident Automation**: Expand incident response automation capabilities

#### **Development & Operations**
1. **CI/CD Enhancement**: Resolve runner installation, implement automated pipelines
2. **Development Environment**: Standardize development tooling and environments
3. **Documentation Portal**: Create internal knowledge base with search capabilities
4. **Onboarding Kits**: Build comprehensive developer and assistant operator guides

#### **Business Systems**
1. **Financial Tracking**: Implement automated expenditure and revenue monitoring
2. **Client Management**: Develop client portal and contract management system
3. **Reporting Automation**: Generate automated business intelligence reports
4. **Compliance Framework**: Establish regulatory compliance documentation

### **Q2 2026 Objectives**
1. **Forgejo Migration**: Complete Gitea → Forgejo migration once schema compatibility resolved
2. **Multi-HA Architecture**: Implement high-availability infrastructure
3. **Advanced Security**: Deploy intrusion detection and prevention systems
4. **Team Expansion**: Onboard additional developers with enhanced security protocols

### **Long-Term Vision**
1. **AI Integration**: Advanced AI assistant capabilities for business automation
2. **Scalable Infrastructure**: Cloud-native architecture with auto-scaling
3. **Product Development**: Launch commercial products and services
4. **Global Operations**: Expand to multiple geographic regions with localized compliance

## Financial Tracking System

### **Purpose**
Track company expenditures, revenue streams, and financial health starting February 15, 2026 as requested by Yukine.

### **Current Implementation Status**
- **Tracking System**: Basic framework established (`finance-tracking.md`)
- **Automation Pending**: Cron jobs for daily expenditure logging
- **Revenue Tracking**: Initial categories defined, implementation needed
- **Reporting**: Monthly financial report automation planned

### **Immediate Actions Required**
1. Identify all service providers and subscription costs
2. Document current financial commitments and recurring payments
3. Implement automated expenditure logging system
4. Create revenue tracking and reporting framework
5. Establish approval workflow for new expenditures

### **Automation Plan**
1. **Daily Cron Job**: Automated expenditure logging
2. **GitHub Integration**: Repository for financial data storage
3. **Alert System**: Notifications for large/unexpected expenditures
4. **Report Generation**: Automated monthly financial statements
5. **Forecast Analysis**: Predictive financial modeling based on historical data

---

**Update Protocol**: Update this README whenever:
- Authority changes occur within the organization
- New security incidents are identified or resolved
- Infrastructure milestones are achieved
- Financial systems are enhanced
- Operational procedures are refined
- Team structure evolves

**Version**: 2.0.0 | **Last Updated**: February 15, 2026
