# Technical Infrastructure Documentation

## 1. Server Specification

### 1.1 Hardware / Cloud Profile
- **Hostname**: `openclaw-x64`
- **Public IP**: `46.224.129.229`
- **Provider**: Unspecified (bare/VM)
- **CPU**: AMD EPYC-Genoa (2 vCPU, 1 thread per core, 1 socket)
- **Memory**: 3.7 GiB total (≈2.4 GiB used under normal load)
- **Storage**: 75 GB SSD (`/dev/sda1`, ~14 % utilized)
- **Swap**: Not configured (0 B). Consider adding swap for burst tolerance.

### 1.2 Operating System & Toolchain
- **OS**: Ubuntu 24.04.4 LTS (Noble Numbat)
- **Kernel**: Linux 6.8.0-100-generic #100-Ubuntu (PREEMPT_DYNAMIC)
- **Shell**: `/bin/bash`
- **Node.js**: v22.22.0
- **Git**: 2.43.0
- **Default Workspace**: `/root/.openclaw/workspace`

## 2. Network Configuration

### 2.1 Listening Ports
| Port | Protocol | Service | Notes |
|------|----------|---------|-------|
| 22   | TCP      | SSH (sshd PID 1215) | Key-based root access only |
| 3000 | TCP      | Gitea 1.23.3 (`/usr/local/bin/gitea web`) | Primary git frontend |
| 3001 | TCP      | Forgejo (inactive) | Reserved for future migration |
| 3002 | TCP      | Nuxt.js experience-portal (`node .output/server/index.mjs`) | Development web interface |
| 8880 | TCP      | DeepInfra Proxy (`python3 /root/deepinfra/proxy.py`) | AI model proxy service |
| 18789 | TCP      | OpenClaw Gateway (`openclaw-gateway`) | Local management API |
| 18792 | TCP      | OpenClaw Gateway (`openclaw-gateway`) | Additional API endpoint |
| 53   | TCP/UDP  | systemd-resolve | Systemd DNS resolver |

> Use `ss -tlnp` to verify port bindings after changes. Note that ports 3002 and 8880 are undocumented services needing firewall rules.

### 2.2 Firewall Configuration (Current Status)
Current status: **Not configured** - UFW detected but not running, iptables not available

**Security Risk**: All exposed ports (22, 3000, 3002, 8880) are publicly accessible without firewall protection.

**Immediate Action Required**:
```bash
# Check current firewall status
apt install iptables -y                    # Install iptables if missing
apt install ufw -y                         # Reinstall UFW if broken

# Check current iptables rules (empty table indicates no protection)
iptables -L -n -v

# Recommended temporary measure if firewall can't be installed now:
# Set up fail2ban for brute force protection
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure fail2ban for SSH
cat >> /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl start fail2ban
```

#### Recommended UFW Ruleset:
```bash
# Install UFW if not present
apt install ufw -y

# Set default policies
ufw default deny incoming
ufw default allow outgoing

# Allow SSH (limit to trusted IPs if possible)
ufw allow 22/tcp
# ufw allow from 192.168.1.0/24 to any port 22  # More restrictive example

# Allow Gitea web interface
ufw allow 3000/tcp

# Allow Forgejo (when active)
# ufw allow 3001/tcp

# Enable SSH rate limiting
ufw limit ssh

# Enable logging
ufw logging on

# Enable firewall
ufw --force enable

# Verify configuration
ufw status verbose
```

#### Alternative iptables Ruleset (if UFW not available):
```bash
# Flush existing rules
iptables -F
iptables -X

# Default policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT

# Allow SSH
iptables -A INPUT -p tcp --dport 22 -j ACCEPT

# Allow Gitea
iptables -A INPUT -p tcp --dport 3000 -j ACCEPT

# ICMP (ping)
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT

# Save rules (persist across reboots)
apt install iptables-persistent -y
iptables-save > /etc/iptables/rules.v4
```

#### Firewall Status Check Commands:
```bash
# Check listening ports
ss -tlnp

# Check firewall status
ufw status  # if using UFW
iptables -L -n -v  # if using raw iptables

# Check active connections
netstat -tunap
```

## 3. Service Architecture

### 3.1 Gitea (Primary Git Hosting)
```
Binary: /usr/local/bin/gitea
Service: gitea.service (systemd)
Config: /opt/gitea/app.ini
Data Dir: /opt/gitea/data/
Database: /opt/gitea/data/forgejo.db (SQLite)
Process: PID 1632, user `git`
URL: http://46.224.129.229:3000/
Admin Accounts: openclaw_admin, Rem, Gerard
```

### 3.2 Forgejo (Staging / Migration Target)
```
Purpose: Clean Forgejo instance on port 3001
Status: Installed, migration blocked by schema mismatch (Gitea → Forgejo 7.0.1)
Action: Await upgraded migration tooling or manual data transform
```

### 3.3 OpenClaw Runtime
```
Workspace: /root/.openclaw/workspace
Skills: /usr/lib/node_modules/openclaw/skills/
Memory: MEMORY.md + memory/YYYY-MM-DD.md + HEARTBEAT.md
Model Alias: deepinfra/deepseek-ai/DeepSeek-V3.2
Gateway Ports: 18789, 18792 (local management API)
```

### 3.4 Nuxt.js experience-portal (Development Web Interface)
```
Location: /tmp/nuxt-live/
Port: 3002
Purpose: Development web interface for experience-portal
Status: Currently running, accessible on all interfaces (0.0.0.0)
Security Risk: No authentication, publicly accessible
Command: PORT=3002 HOST=0.0.0.0 node .output/server/index.mjs
```

### 3.5 DeepInfra Proxy Service
```
Location: /root/deepinfra/proxy.py
Port: 8880
Purpose: AI model proxy for deepinfra models
Status: Running with Werkzeug/3.0.1
Security Risk: No authentication, publicly accessible
Command: /usr/bin/python3 /root/deepinfra/proxy.py
Action: Restrict to localhost only or implement authentication
```

## 4. CI/CD Pipeline Status

| Component | Status | Notes |
|-----------|--------|-------|
| Gitea Actions UI | "Waiting" | Runner not installed |
| Actions API | 404 responses | Indicates misconfigured or disabled API |
| Manual Runner | `/opt/gitea/ci-runner.sh` | Triggered via post-receive hook |
| Dependencies | TypeScript, Nuxt CLI (global) | Pending installation |

> Short term: maintain manual script workflow. Long term: provision Forgejo runner or migrate to external CI.

## 5. Repository Landscape

### 5.1 Internal (Gitea)
- `experience-portal` – Nuxt + TypeScript app (needs OpenClaw interface + Discord DM fixes)
- `company-structure` – This documentation repository

### 5.2 External (GitHub)
- `RemBotClawBot/RemBotClawBot` – Public identity & automation showcase
- `RemBotClawBot/company-structure` – Public mirror (if desired) once sanitized

### 5.3 Account & Credential Notes
- Admin transfer protocol: always transfer repositories to `Rem` before disabling legacy accounts
- Password hygiene: strong passphrases stored outside repo; never commit secrets

## 6. Development Environment

### 6.1 Tools Installed
- Node.js 22.x + npm
- Git CLI
- curl / wget
- Standard GNU utilities

### 6.2 Missing / Planned Tools
- TypeScript (global)
- Nuxt CLI
- Process supervisors (systemd units exist; consider PM2 for apps)
- Firewall tooling (ufw/iptables wrappers)

## 7. Backup & Recovery

### 7.1 Current Strategy
| Target | Location | Frequency | Notes |
|--------|----------|-----------|-------|
| Gitea data | `/opt/gitea/data.backup/` | Manual pre-change | Contains `gitea.db` snapshot |
| Config files | `/opt/gitea/app.ini`, `/root/.openclaw/config.yaml` | Manual copies | Include in future scripted backups |
| SSH keys | `~/.ssh/` | Manual | Should be part of scheduled secure backup |

### 7.2 Recommended Scripts (see OPERATIONS.md)
- `daily-backup.sh` – rsync-based incremental copies + 7-day retention
- `monthly-backup.sh` – Full tarball backup with service stop/start and verification

### 7.3 Restore Procedure (High-Level)
1. Stop service: `systemctl stop gitea`
2. Replace data dir from known-good backup
3. Restore configuration + verify permissions (owner `git:git`)
4. Start service: `systemctl start gitea`
5. Validate via `curl http://localhost:3000/`

## 8. Monitoring & Health Checks

### 8.1 Heartbeat Tasks (see HEARTBEAT.md / OPERATIONS.md)
- System health (ports, disk, CPU, memory)
- Security log review
- Project progress review (experience-portal, CI pipeline)
- Memory maintenance (summaries into MEMORY.md)

### 8.2 Command Reference
```bash
# Process + resource snapshots
systemctl status gitea
ps aux | grep gitea
ss -tlnp | grep 3000
free -h
 df -h /

# Log review
journalctl -u gitea -n 50 --no-pager
tail -100 /var/log/syslog | grep -i "error\|warn"
```

## 9. Upgrade & Change Procedures

### 9.1 Gitea → Forgejo Migration Attempt (Feb 14 2026)
- Result: Schema mismatch prevented migration
- Mitigation: Maintained Gitea as primary; preserved `/opt/gitea/data.backup`
- Next Steps: Research compatible Forgejo version or export/import strategy

### 9.2 Assistant Upgrades
- Model alias `deepinfra/deepseek-ai/DeepSeek-V3.2`
- Additional skills enabled: healthcheck, weather, etc.
- Cron-driven documentation improvements every 15 minutes (this task)

### 9.3 Change Management
- Standard + emergency workflows defined in OPERATIONS.md
- Approvals: Gerard (business) + Veld (technical)
- Documentation: log in MEMORY.md + relevant *.md files

## 10. Network Services & Connectivity

### 10.1 External Connectivity Tests
```bash
curl -s https://ipinfo.io
curl -s http://46.224.129.229:3000/
ssh -T git@github.com  # via RemBotClawBot key
```

### 10.2 SSH Configuration
- Root access via authorized_keys only
- Ensure `PermitRootLogin prohibit-password` and `PasswordAuthentication no` (verify in `/etc/ssh/sshd_config`)
- Rotate keys after personnel changes per OPERATIONS.md

## 11. Security Configuration Snapshot

- **Identity Controls**: Documented in SECURITY.md (Gerard, Veld, Yukine, Rem) with verification procedures
- **Competitor Awareness**: Track Xavin interference; escalate anomalies
- **Logging**: Systemd journal, `/var/log/syslog`, `/var/log/auth.log`
- **Incident Playbooks**: See INCIDENT_RESPONSE.md for severity matrix and response templates

## 12. Troubleshooting Guide

| Symptom | Diagnostic Commands | Likely Cause | Resolution |
|---------|---------------------|--------------|------------|
| Port 3000 unreachable | `ss -tlnp | grep 3000`, `systemctl status gitea`, `curl http://localhost:3000/` | Service down / firewall issue | Restart service, verify firewall, check logs |
| Port 3002 unreachable | `ss -tlnp | grep 3002`, `ps aux | grep node.*3002`, `cd /tmp/nuxt-live && node .output/server/index.mjs &` | Nuxt app not running | Restart from /tmp/nuxt-live/ directory |
| Port 8880 unreachable | `ss -tlnp | grep 8880`, `ps aux | grep python.*8880` | DeepInfra proxy down | Check `/root/deepinfra/proxy.py` and restart |
| Gateway API unreachable | `ss -tlnp | grep 18789`, `systemctl status openclaw-gateway` | OpenClaw gateway down | Restart gateway service |
| Actions stuck "Waiting" | `journalctl -u gitea | grep runner`, API checks | Runner missing / misconfigured | Install runner, configure token, restart |
| Unauthorized access alerts | `tail /var/log/auth.log`, `last`, `who` | Brute force attempt | Block IP, enable fail2ban, rotate keys |
| Disk pressure | `df -h /`, `du -sh /opt/gitea/data` | Large repo data / logs | Prune repos/logs, expand disk, tighten backups |
| High memory usage | `free -h`, `ps aux --sort=-%mem \| head` | runaway process | Restart offending service, investigate leak |
| SSL/TLS connection errors | `openssl s_client -connect localhost:3000 -tls1_2` | Certificate issues | Check cert validity, renew if expired |

### 12.1 Service Monitoring Commands
```bash
# Check all running services
ss -tlnp  # List all listening ports
ps aux | grep -E "(gitea|node.*3002|python.*8880|openclaw)"  # Key processes
systemctl list-units --type=service --state=running  # System services

# Health checks
curl -fs http://localhost:3000/healthz || echo "Gitea HTTP check failed"
curl -fs http://localhost:3002/ || echo "Nuxt app health check failed"
curl -fs http://localhost:8880/ || echo "DeepInfra proxy check failed"

# Log monitoring
journalctl -u gitea -n 20 --no-pager
journalctl -u openclaw -n 20 --no-pager
tail -50 /var/log/syslog
tail -50 /var/log/auth.log  # SSH authentication logs
```

## 13. Documented Security Risks & Remediation

### 13.1 Exposed Services Without Authentication
**Risk**: Ports 3002 (Nuxt.js) and 8880 (DeepInfra proxy) are publicly accessible without authentication.

**Remediation**:
1. **Immediate**: Restrict to localhost only
   ```bash
   # For Nuxt.js (port 3002)
   # Change from HOST=0.0.0.0 to HOST=127.0.0.1 in startup command
   
   # For DeepInfra proxy (port 8880)  
   # Update proxy.py to bind to 127.0.0.1 instead of 0.0.0.0
   ```

2. **Short-term**: Implement basic authentication
   ```python
   # Add HTTP Basic Auth to proxy.py
   from werkzeug.middleware.http_proxy import ProxyMiddleware
   from werkzeug.security import generate_password_hash, check_password_hash
   ```

3. **Long-term**: Deploy reverse proxy (Nginx/Apache) with TLS and proper authentication

### 13.2 Missing Firewall Configuration
**Risk**: No active firewall rules; all ports accessible from any IP.

**Remediation**:
```bash
# Install and configure UFW
apt update && apt install ufw -y
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow 22/tcp comment 'SSH'
ufw allow 3000/tcp comment 'Gitea'
# Optional: Restrict to specific IP ranges if possible
# ufw allow from 192.168.1.0/24 to any port 22
ufw status verbose
```

### 13.3 SSH Hardening Needed
**Risk**: SSH key-based only but no fail2ban protection.

**Remediation**:
```bash
# Install fail2ban
apt install fail2ban -y
cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Configure SSH protection
cat >> /etc/fail2ban/jail.local << EOF
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
EOF

systemctl enable fail2ban
systemctl start fail2ban
```

## 14. Next Technical Actions
1. **CRITICAL**: Configure firewall (ufw/iptables) with least-privilege rules
2. **CRITICAL**: Restrict unauthorized services (3002, 8880) to localhost or implement authentication
3. **HIGH**: Install and configure fail2ban for SSH protection
4. **MEDIUM**: Install and configure Forgejo runner or external CI alternative
5. **MEDIUM**: Automate backups via scripts in OPERATIONS.md
6. **MEDIUM**: Add swapfile (e.g., 2 GiB) for stability
7. **LOW**: Implement monitoring/alerting stack (Netdata, Prometheus, or lightweight scripts)

---

*Update this document after any infrastructure change, migration attempt, or significant hardware/network adjustment.*

## 15. Automation & Cron Inventory

| Name | Script | Schedule | Description |
|------|--------|----------|-------------|
| Daily Incremental Backup | `scripts/daily-backup.sh` | `0 2 * * *` | Rsync-based snapshot of Gitea data, configs, SSH keys with manifest + 7-day retention |
| Monthly Full Backup | `scripts/monthly-backup.sh` | `0 3 1 * *` | Stops Gitea, captures full tarball of infra artifacts, validates archive integrity, enforces 12-month retention |
| System Health Monitor | `scripts/system-health-monitor.sh` | `*/30 * * * *` | Polls CPU/RAM/disk, service status, ports, and SSH auth logs; escalates via log files / future webhooks |
| Security Hardening Suite | `scripts/security-hardening.sh` | Manual Execution Only | Comprehensive security hardening automation for Ubuntu 24.04 LTS - use with caution |

**Deployment notes**
1. Scripts live in-repo under `scripts/` and should be symlinked or copied to `/root/company-structure/scripts/`.
2. After modifying scripts, re-run `chmod +x scripts/*.sh` to preserve execute bits and redeploy to `/etc/crontab`.
3. Logs land in `/var/log/daily-backup.log`, `/var/log/monthly-backup.log`, `/var/log/system-health.log`, and `/var/log/system-alerts.log`.
4. Failed runs exit non-zero; monitor via `grep CRITICAL /var/log/system-alerts.log` during heartbeats.
5. When cron is unavailable (e.g., sandbox), scripts can be executed manually as root with `bash scripts/<name>.sh`.

## 16. Comprehensive Security Hardening Procedures

### 16.1 Security Hardening Script (`scripts/security-hardening.sh`)
This comprehensive script implements multiple security hardening measures for Ubuntu 24.04 LTS:

**Features**:
- UFW firewall installation and configuration
- Fail2Ban installation and SSH brute force protection
- SSH hardening with modern cryptography
- Enhanced system logging with auditd
- Security monitoring with logwatch
- System-wide hardening via sysctl
- Comprehensive backup plan creation

**Usage**:
```bash
# Run all hardening steps (requires root)
sudo bash scripts/security-hardening.sh --all

# Run individual components
sudo bash scripts/security-hardening.sh --install-firewall
sudo bash scripts/security-hardening.sh --harden-ssh
sudo bash scripts/security-hardening.sh --setup-logging
```

**Warning**: This script makes significant changes to system configuration. Review the script thoroughly before execution and test in a non-production environment first.

### 16.2 Comprehensive Backup Script (`scripts/comprehensive-backup.sh`)
Creates comprehensive system backups including:
- Company-structure repository
- Gitea data and configuration
- OpenClaw workspace
- System configurations (SSH, UFW, Fail2Ban)
- Recent system logs
- Rotates old backups automatically

**Backup Retention**:
- Daily backups: Keep 7 days
- Weekly backups: Keep 30 days
- Monthly backups: Keep 365 days

### 16.3 Incident Response Automation
The `incident-response-playbook.md` provides detailed procedures for:
- Incident classification and severity levels
- Response team roles and escalation chains
- Investigation and evidence collection procedures
- Containment, eradication, and recovery steps
- Post-incident activities and reporting templates

### 16.4 Security Implementation Priority

#### Critical (Immediate)
1. **UFW Firewall Configuration**
   ```bash
   sudo bash scripts/security-hardening.sh --install-firewall
   ```
2. **Fail2Ban SSH Protection**
   ```bash
   sudo bash scripts/security-hardening.sh --install-fail2ban
   ```
3. **Service Restriction** (Manual configuration required)
   - Restrict ports 3002 and 8880 to localhost only
   - Implement BasicAuth or reverse proxy

#### High (Next 48 Hours)
4. **SSH Hardening**
   ```bash
   sudo bash scripts/security-hardening.sh --harden-ssh
   ```
5. **Enhanced Logging**
   ```bash
   sudo bash scripts/security-hardening.sh --setup-logging
   ```
6. **System Hardening**
   ```bash
   sudo bash scripts/security-hardening.sh --harden-system
   ```

#### Medium (Next Week)
7. **Comprehensive Backups**
   ```bash
   sudo bash scripts/comprehensive-backup.sh
   ```
8. **Regular Security Monitoring**
   - Implement daily security scan cron job
   - Set up alerting for suspicious activity
9. **Certificate Management**
   - Implement SSL/TLS for all services
   - Automate certificate renewal

#### Low (Ongoing)
10. **Security Policy Updates**
    - Regular review of security policies
    - Employee security training updates
    - Penetration testing procedures
11. **Compliance Documentation**
    - Maintain compliance with industry standards
    - Regular security audit preparation
12. **Threat Intelligence Integration**
    - Subscribe to security bulletins
    - Implement threat intelligence feeds

### 16.5 Security Monitoring Dashboard
To be implemented:
```bash
# Daily security report generation
0 8 * * * root /usr/sbin/logwatch --output mail --mailto security@company.com

# Weekly security scan
0 2 * * 1 root /root/company-structure/scripts/security-scan.sh

# Real-time alerting (to be implemented)
*/5 * * * * root /root/company-structure/scripts/security-alert.sh
```

### 16.6 Incident Response Checklist Integration
The playbook includes automated checklists for:
- Phase 1: Detection & Analysis
- Phase 2: Containment
- Phase 3: Eradication
- Phase 4: Recovery
- Phase 5: Post-Incident Activities

Each checklist can be automated with appropriate monitoring tools.

### 16.7 Evidence Preservation Procedures
Automated evidence collection scripts will be created to:
1. Capture system state during incidents
2. Preserve logs and configuration files
3. Maintain chain of custody documentation
4. Archive evidence for regulatory compliance

---

*Update this document after implementing security hardening measures. Maintain regular security reviews and updates.*



