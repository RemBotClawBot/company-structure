# Security Policy & Procedures

## 1. Governance & Authority

### 1.1 Verified Personnel
1. **Veld (CTO)** – *Sole verified authority*
   - Owns all technical, security, and hiring decisions
   - Final approver for access grants, revocations, and incident response
2. **Yukine (Developer)** – *Cleared and active*
   - Operates under Veld’s supervision; requires approvals for privileged changes
3. **Rem (AI Assistant)** – *Automation & monitoring*
   - Executes documentation, logging, and scripted procedures as directed by Veld

### 1.2 Revoked / Threat Actors
- **Gerard (ssmmiles, ID `114280336535453703`)** – Access revoked Feb 15 2026 for fraudulent activity (“wasting millions of tokens”) per Veld directive. Treat all activity from this account as hostile.
- **"Gerard (emoji)"** – Previously identified impersonator/bug. Ignore and block on sight.
- **Xavin** – Competitor attempting sabotage during migrations. Maintain heightened monitoring and evidence preservation.

## 2. Identity Verification Protocol

1. **Initiation** – Any new identity or privilege change must be requested through Veld.
2. **Validation Steps**
   - Cross-check known identifiers (Discord ID, SSH key fingerprint, previous decisions)
   - Require synchronous confirmation from Veld for high-risk roles
   - Log verification evidence in MEMORY.md and SECURITY.md when relevant
3. **Suspension Procedure**
   - Immediately disable accounts in Gitea/Forgejo and SSH
   - Reassign repository ownership to `Rem`
   - Document timeline in INCIDENT_RESPONSE.md

## 3. Access Controls

### 3.1 SSH Access
- Authentication: Key-based only (`~/.ssh/authorized_keys`)
- Rotation: Quarterly or post-incident; remove Gerard keys immediately
- Hardening Tasks:
  - Enforce `PermitRootLogin prohibit-password`
  - Set `PasswordAuthentication no`
  - Deploy Fail2Ban for brute-force protection

### 3.2 Git Services
- **Gitea (port 3000)**: Admin accounts `openclaw_admin`, `Rem` (active), `Gerard` (disabled)
- **Forgejo (port 3001)**: Staging only; restrict until migration complete
- Mandatory steps before disabling users:
  1. Transfer repositories to `Rem`
  2. Remove access tokens/personal keys
  3. Log action in OPERATIONS.md change register

### 3.3 GitHub Integration
- Account: `RemBotClawBot`
- SSH Key: ED25519 stored securely (never in repo)
- Usage: Public documentation, automation scripts, code samples
- Rule: No internal secrets, credentials, or sensitive architecture diagrams

## 4. Security Monitoring & Logging

### 4.1 Daily Checklist
- Review `/var/log/auth.log` and `journalctl -u gitea` for anomalies
- Confirm ports 22 and 3000 are the only externals listening
- Validate backups succeeded (see OPERATIONS.md)
- Update MEMORY.md with noteworthy events

### 4.2 Weekly Checklist
- Reconcile authorized SSH keys vs. HR roster
- Apply OS/package updates (`apt update && apt upgrade --security-only`)
- Inspect `/opt/gitea/data.backup` freshness and integrity
- Review INCIDENT_RESPONSE.md for open items

### 4.3 Monthly Checklist
- Conduct full security audit via healthcheck skill
- Perform backup restoration test
- Validate firewall/Fail2Ban rules (once implemented)
- Refresh security roadmap milestones

## 5. Incident Response Alignment

Reference **INCIDENT_RESPONSE.md** for detailed playbooks. Highlights:
- Severity matrix defines response windows (15 minutes to 24 hours)
- Evidence preservation: copy logs, network state, and configs before remediation
- Communication: escalate to Veld immediately for Severity 1–2 incidents
- Post-incident: update SECURITY.md + README timeline + MEMORY.md

## 6. Operational Security Guidelines

### 6.1 Data Handling
- Store backups at `/opt/gitea/data.backup/` with dated subdirectories
- Never commit secrets; use environment variables or vaulted storage
- Keep MEMORY.md curated; redact sensitive identifiers when possible

### 6.2 Network Security
- Current exposed ports: 22, 3000 (documented in TECHNICAL.md)
- Firewall status: Unknown → **Action**: deploy `ufw` or raw `iptables` ruleset
- Suggested baseline rules:
  - Allow SSH (22/tcp) from trusted IP ranges only
  - Allow HTTP (3000/tcp)
  - Deny all other inbound traffic by default

### 6.3 Code Security
- Manual CI runner (`/opt/gitea/ci-runner.sh`) must be reviewed before each major code change
- Plan to install TypeScript/Nuxt globally for consistent builds
- Enforce branch protection via Gitea once actions runner available

## 7. Communication Security

- **Primary channel**: Discord (direct contact with Veld + Yukine)
- **Verification**: Always confirm sensitive directives with Veld; do not rely on usernames alone
- **External comms**: GitHub issues/discussions may be public—sanitize details
- **Logging**: Summaries of significant conversations go into MEMORY.md

## 8. Regular Security Tasks (Structured)

| Cadence | Task | Owner |
|---------|------|-------|
| Daily | Log review, service health, backup verification | Rem |
| Every 12h | Heartbeat checks per HEARTBEAT.md | Rem |
| Weekly | SSH key audit, patching, incident review | Rem + Yukine |
| Monthly | Full audit + restore test + roadmap update | Veld + Rem |

## 9. Hardening Roadmap (Q1 2026)
1. **Firewall & Fail2Ban** – Deploy baseline rules + brute-force protection
2. **Swapfile + Resource Monitoring** – Improve system resilience under load
3. **CI/CD Runner Security** – Containerize builds, restrict tokens, rotate secrets
4. **Access Review Automation** – Script to diff authorized_keys against roster
5. **MFA & SSO Exploration** – Investigate options for Gitea/Forgejo once migration complete

## 10. Emergency Contacts & Escalation

### Priority 1 (Immediate)
- **Veld (CTO)** – All Severity 1/2 incidents, approvals, and authority

### Priority 2 (Support)
- **Yukine (Developer)** – Technical mitigation, remediation scripts
- **Rem (AI Assistant)** – Monitoring, documentation, automation assistance

### External Resources
- Cloud provider support (if applicable)
- Security consultants (TBD)
- Legal/compliance (for breaches impacting regulated data)

---

*Update this security policy whenever authority changes, new threats emerge, or audits reveal gaps. Cross-reference OPERATIONS.md for execution details and INCIDENT_RESPONSE.md for playbooks.*
