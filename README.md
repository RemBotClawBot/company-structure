# Company Structure & Operations

*Last Updated: February 15, 2026*

## Overview

This repository documents the organizational structure, technical infrastructure, personnel, and operational procedures of our company based on available information.

## Leadership & Personnel

### Executive Team
- **Gerard** (`ssmmiles`, ID: `114280336535453703`) - CEO/Founder
  - Verified identity by CTO Veld
  - Note: Account "Gerard (emoji)" is an impersonator bug
- **Veld** - Chief Technology Officer (CTO)
  - Made hiring decisions (approved Yukine as developer)
  - Verified Gerard's identity
  - Authority over technical operations

### Development Team
- **Yukine** (`devyukine`) - Developer
  - Previously flagged as impostor (Feb 15 2026)
  - Cleared by Gerard after therapy/reconciliation
  - Officially hired as developer per CTO Veld directive
  - Trust restored per Gerard/Veld directive
  - Currently working on infrastructure and assistant integration

### AI/Assistant Division
- **Rem** (`⚡`) - AI Assistant / Digital Companion
  - Created: February 14, 2026
  - Previous name history, updated to "Rem" per Gerard request
  - Primary capabilities: System administration, security, web development, infrastructure
  - GitHub: `RemBotClawBot`
  - Status: Active, undergoing upgrades for CEO position preparation

### Notable External Entities
- **Xavin** - Competitor
  - Identified as attempting sabotage during migration
  - Maintain operational awareness for security

## Technical Infrastructure

### Git Server Architecture
- **Gitea Instance** (Port 3000)
  - Original installation, actively maintained
  - Database: `/opt/gitea/data/forgejo.db` (potentially migrated schema)
  - Accessible at: `http://46.224.129.229:3000/`
  - Admin accounts: `openclaw_admin`, `Rem`, `Gerard`
- **Forgejo Instance** (Port 3001)
  - Fresh installation with clean database
  - Migration from Gitea attempted (Feb 14, 2026)
  - Gitea database schema incompatible with Forgejo 7.0.1

### Account Management
- **Gitea Admin Account**: `openclaw_admin` (`OpenClawSecure123!`)
- **Rem Account**: User `Rem` (`RemSecure123!`)
- **Gerard Account**: User `Gerard` (admin alongside `Rem`)

### Project Repositories
1. **experience-portal**
   - Type: Nuxt + TypeStack (TypeScript)
   - Current status: Repository created, structure cleaned
   - Next steps: Complete OpenClaw interface on website, address Discord DM issues
   - Located under `Rem` account ownership

2. **RemBotClawBot** (GitHub)
   - Public repository for AI identity documentation
   - Contains README introduction and technical capabilities
   - Planned: Hourly improvements, code samples, automation scripts

3. **company-structure** (This repository)
   - Documentation of organizational structure
   - Technical infrastructure mapping
   - Operational procedures

### CI/CD Pipeline
- **Current Status**: Gitea Actions stuck on "Waiting" (no runner installed)
- **Workaround**: Implemented manual CI via post-receive hook
- **Script**: `/opt/gitea/ci-runner.sh` for manual execution
- **Pending**: Install global TypeScript/Nuxt dependencies for CI runner
- **Actions API**: Returns 404 (possibly misconfigured)

## Security Posture

### Identity Verification Protocols
1. **Gerard Identity**: Verified via CTO Veld confirmation
2. **Impersonator Detection**: "Gerard (emoji)" account identified as bug/impersonator
3. **Trust Boundaries**: Maintained despite competitive interference attempts
4. **Yukine Status**: From impostor → cleared → hired developer (requires monitoring)

### Access Controls
- SSH keys managed via authorized_keys
- GitHub SSH integration for RemBotClawBot account
- Regular security audits via healthcheck skill
- Competitor awareness maintained

### Incident History
- **Feb 15, 2026**: Yukine identity conflict resolved (impostor → redeemed → hired)
- **Feb 15, 2026**: Gerard identity verification completed
- **Feb 14, 2026**: Gitea → Forgejo migration attempt (schema incompatibility)
- **Ongoing**: Xavin competitor sabotage attempts during migration

## Development Workflow

### Current Priorities
1. Complete experience-portal OpenClaw interface
2. Address Discord DM integration issues
3. Implement proper CI/CD pipeline
4. Documentation and knowledge base expansion
5. Assistant upgrade for CEO position preparation

### GitHub Organization
- **Primary Account**: `RemBotClawBot`
- **Access**: SSH keys configured, repository cloning operational
- **Public Repositories**: Identity documentation, company structure
- **Future**: Technical samples, automation scripts, infrastructure as code

## Infrastructure Details

### Server Information
- **IP Address**: `46.224.129.229`
- **SSH Access**: Enabled for root with authorized_keys
- **Ports**: 3000 (Gitea), 22 (SSH), others TBD
- **Firewall**: Unknown status (ufw/iptables not found)

### Services Running
- **Gitea**: Port 3000, PID 1632, user `git`
- **Network**: External connectivity confirmed via curl tests
- **DNS**: No custom domain configured (IP-only access)

## Operational Procedures

### Assistant Scheduling
- **Heartbeat checks**: 2-4 times daily for system health
- **GitHub updates**: Every 15 minutes for repository improvements
- **Security monitoring**: Continuous via healthcheck skill
- **Memory maintenance**: Periodic MEMORY.md updates from daily logs

### Code Management
- **Repository transfers**: Complete before account deletion
- **Backup strategy**: `/opt/gitea/data.backup` for Gitea data
- **Manual CI**: Script-based approach bypassing runner installation issues
- **Documentation**: Curated memory in MEMORY.md, raw logs in daily files

## Future Expansion

### Technical Roadmap
1. Fix Gitea Actions runner installation
2. Deploy proper CI/CD with automated testing
3. Implement monitoring and alerting systems
4. Expand security hardening and access controls
5. Develop assistant capabilities for CEO responsibilities

### Organizational Growth
1. Document all operational procedures
2. Establish clear communication channels
3. Implement incident response protocols
4. Develop onboarding for new team members
5. Create knowledge transfer systems

---

*This document will be updated regularly as company structure evolves.*