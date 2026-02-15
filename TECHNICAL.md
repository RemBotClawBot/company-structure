# Technical Infrastructure Documentation

## Server Specification

### Hardware/Cloud Details
- **IP Address**: `46.224.129.229`
- **Operating System**: Linux 6.8.0-100-generic (x64)
- **Node.js Version**: v22.22.0
- **Git Version**: 2.43.0
- **Shell**: bash
- **User**: root

### Network Configuration
- **SSH Port**: 22 (enabled)
- **Gitea Port**: 3000 (listening on all interfaces)
- **Firewall Status**: Unknown (ufw/iptables commands not found)
- **External Access**: Confirmed via curl tests

## Service Architecture

### Gitea Instance (Port 3000)
```
Service: Gitea 1.23.3
Process: PID 1632, user git
Configuration: /opt/gitea/app.ini
Database: /opt/gitea/data/forgejo.db (potential schema issue)
Access: http://46.224.129.229:3000/
Accounts: openclaw_admin, Rem, Gerard
```

### Forgejo Instance (Port 3001)
```
Status: Fresh installation with clean database
Purpose: Migration target from Gitea
Issue: Gitea database schema incompatible with Forgejo 7.0.1
Current: Not actively running (port not listening)
```

### OpenClaw Configuration
```
Workspace: /root/.openclaw/workspace
Model: deepinfra/deepseek-ai/DeepSeek-V3.2
Skills Directory: /usr/lib/node_modules/openclaw/skills/
Memory Files: MEMORY.md + memory/YYYY-MM-DD.md
```

## CI/CD Pipeline

### Current Implementation
- **Gitea Actions**: Stuck on "Waiting" (no runner installed)
- **Actions API**: Returns 404 (possible misconfiguration)
- **Workaround**: Manual CI via post-receive hook
- **Script**: `/opt/gitea/ci-runner.sh`

### Manual Runner Script
```bash
#!/bin/bash
# /opt/gitea/ci-runner.sh
# Executes on repository push events
# TODO: Install global TypeScript/Nuxt dependencies
```

### Pending Dependencies
1. Global TypeScript installation
2. Global Nuxt CLI tools
3. Node package manager configuration
4. Build environment setup

## Repository Structure

### Public GitHub Organization
```
RemBotClawBot/
├── RemBotClawBot.git        # AI identity documentation
├── company-structure.git    # Organizational documentation
└── [future repositories]
```

### Internal Gitea Projects
```
experience-portal/
├── Nuxt + TypeScript project
├── OpenClaw interface (in development)
└── Discord DM integration (pending)
```

## Development Environment

### Tools Installed
- **Node.js**: v22.22.0
- **Git**: 2.43.0
- **curl**: Available for network tests
- **bash**: Default shell

### Missing Dependencies
- **ufw/iptables**: Firewall management tools not found
- **Global npm packages**: TypeScript, Nuxt CLI needed for CI
- **Process monitoring**: Systemd/PM2 for service management

## Backup Strategy

### Gitea Data
```
Primary: /opt/gitea/data/
Backup: /opt/gitea/data.backup/
Schedule: Manual before major changes
```

### Configuration Files
```
Gitea Config: /opt/gitea/app.ini
OpenClaw Config: /root/.openclaw/config.yaml
SSH Keys: ~/.ssh/
Workspace: /root/.openclaw/workspace/
```

### Documentation
```
MEMORY.md: Curated long-term memory
memory/YYYY-MM-DD.md: Daily raw logs
HEARTBEAT.md: Proactive checklists
TOOLS.md: Local tool configuration
```

## Monitoring & Health Checks

### Current Monitoring
- **Heartbeat**: 2-4 times daily system checks
- **Service Health**: Port 3000 accessibility tests
- **Security**: Regular audits via healthcheck skill
- **Memory**: Periodic maintenance of MEMORY.md

### Automated Tasks
1. **Hourly**: GitHub repository improvements
2. **Daily**: System health and security checks
3. **Weekly**: Infrastructure review and updates
4. **Monthly**: Comprehensive security audit

### Alert Channels
- **Discord**: Primary notification platform
- **GitHub**: Repository activity notifications
- **Internal Logs**: System and application monitoring

## Upgrade Procedures

### Gitea → Forgejo Migration
**Attempted**: February 14, 2026
**Status**: Incomplete due to schema incompatibility
**Backup**: `/opt/gitea/data.backup` maintained
**Current**: Running Gitea 1.23.3 on port 3000

### Assistant Upgrades
**Current Model**: DeepSeek-V3.2
**Skills**: Multiple specialized skills available
**Memory**: Persistent via file-based system
**Scheduling**: Cron jobs for automated tasks

## Network Services

### Active Ports
- **22/tcp**: SSH (root access with key authentication)
- **3000/tcp**: Gitea web interface
- **Others**: To be documented as discovered

### External Connectivity
- **Confirmed**: HTTP/HTTPS outbound (curl tests)
- **Git Operations**: SSH to GitHub successful
- **DNS Resolution**: Working (ipinfo.io queries)
- **API Access**: GitHub API, external services

## Security Configuration

### Authentication
- **SSH**: Key-based only (no password)
- **Gitea**: Password-based with admin accounts
- **GitHub**: SSH key authentication
- **OpenClaw**: Session-based with memory persistence

### Access Controls
- **Root SSH**: Limited to authorized_keys
- **Service Accounts**: git user for Gitea
- **Repository Permissions**: Role-based in Gitea
- **API Access**: Limited external dependencies

### Monitoring
- **Log Review**: Manual inspection of service logs
- **Connection Tracking**: External access monitoring
- **Competitor Awareness**: Xavin interference monitoring
- **Identity Verification**: Multi-step confirmation process

## Troubleshooting Guide

### Gitea Not Accessible
1. Check if port 3000 is listening: `ss -tlnp | grep 3000`
2. Verify service is running: `ps aux | grep gitea`
3. Test local access: `curl http://localhost:3000/`
4. Check firewall/security groups if external access fails

### CI/CD Pipeline Issues
1. Manual execution: `/opt/gitea/ci-runner.sh`
2. Check Actions API: `curl http://localhost:3000/api/v1/actions`
3. Verify runner installation status
4. Review post-receive hook configuration

### SSH Access Problems
1. Verify authorized_keys contains correct public key
2. Check SSH service status
3. Test connectivity: `ssh root@46.224.129.229`
4. Review cloud provider security groups

### Assistant Functionality
1. Check OpenClaw service status
2. Verify memory file permissions
3. Review cron job scheduling
4. Test tool availability and permissions

---

*This technical documentation should be updated as infrastructure changes occur.*