# Security Policy & Procedures

## Identity Verification Protocol

### Personnel Authentication
1. **Gerard (CEO)**
   - Primary ID: `114280336535453703` (ssmmiles)
   - Verification: Confirmed by CTO Veld
   - Impersonator: "Gerard (emoji)" account is a bug/impostor
   - Action: Trust but verify critical decisions via secondary confirmation

2. **Yukine (Developer)**
   - Status: Previously flagged impostor → cleared → hired developer
   - Verification: Approved by Gerard after therapy/reconciliation
   - Authority: Technical operations under Veld supervision
   - Monitoring: Maintain operational awareness due to history

3. **Veld (CTO)**
   - Status: Verified authority figure
   - Authority: Hiring decisions, technical oversight
   - Verification: Consistent decision-making pattern

### Competitor Awareness
- **Xavin**: Identified as attempting sabotage during migration
- **Action**: Maintain operational continuity despite interference
- **Monitoring**: Regular security audits via healthcheck skill

## Access Controls

### SSH Access
- **Authorized Keys**: Managed via `~/.ssh/authorized_keys`
- **Current Access**: Gerard (GitHub SSH key added)
- **Protocol**: Root access via SSH key authentication only
- **Rotation**: Review quarterly or after security incidents

### Git Server Access
- **Gitea Port**: 3000 (external access enabled)
- **Admin Accounts**: `openclaw_admin`, `Rem`, `Gerard`
- **Password Policy**: Strong passwords for all accounts
- **Repository Ownership**: Transfer before account deletion

### GitHub Integration
- **Account**: `RemBotClawBot`
- **SSH Key**: ED25519 key generated for automation
- **Public Repositories**: Identity and structure documentation only
- **Private Data**: Never commit secrets or internal configuration

## Incident Response

### Identity Conflicts
1. **Detection**: Multiple accounts claiming same identity
2. **Verification**: Cross-reference with trusted authority (Veld)
3. **Resolution**: Temporary suspension until verification complete
4. **Documentation**: Update MEMORY.md with resolution details

### Competitor Interference
1. **Detection**: Unusual migration failures or system instability
2. **Assessment**: Determine scope and impact
3. **Containment**: Isolate affected systems if possible
4. **Recovery**: Restore from backups, verify integrity
5. **Documentation**: Log incident for future reference

### Security Breaches
1. **Immediate Action**: Disconnect affected systems
2. **Assessment**: Determine breach vectors and scope
3. **Containment**: Isolate compromised components
4. **Eradication**: Remove malicious access/software
5. **Recovery**: Restore from clean backups
6. **Post-mortem**: Document lessons learned

## Operational Security

### Data Handling
- **Backups**: Maintain `/opt/gitea/data.backup` for Gitea
- **Secrets**: Never store in version control
- **Logs**: Regular review of system and application logs
- **Memory**: Curated MEMORY.md for significant security events

### Network Security
- **Port Management**: Only essential ports exposed (22, 3000)
- **Firewall**: Status unknown (ufw/iptables not found)
- **External Access**: IP-based with SSH key authentication
- **Monitoring**: Regular connectivity and service health checks

### Code Security
- **Repository Transfers**: Complete before account deletion
- **CI/CD**: Manual runner script as temporary workaround
- **Dependencies**: Review for vulnerabilities
- **Updates**: Regular security patches applied

## Communication Security

### Internal Channels
- **Discord**: Primary communication platform
- **Verification**: Cross-reference critical decisions
- **Impersonation**: Awareness of "Gerard (emoji)" impersonator
- **Trust Boundaries**: Maintain despite competitive pressure

### External Communications
- **GitHub**: Public repositories for documentation only
- **No Secrets**: Never share internal configuration
- **Professional Boundaries**: Clear identity verification required
- **Transparency**: Document all external interactions

## Regular Security Tasks

### Daily
- Review system logs for unusual activity
- Check service health and accessibility
- Verify backup integrity
- Update security documentation as needed

### Weekly
- Review authorized SSH keys
- Check for system updates and security patches
- Verify competitor awareness status
- Update incident response procedures

### Monthly
- Comprehensive security audit via healthcheck skill
- Review access controls and permissions
- Test backup restoration procedures
- Update security policy based on new threats

## Emergency Contacts

### Priority 1 (Immediate Response)
- **Gerard**: CEO - Final authority on all matters
- **Veld**: CTO - Technical authority and verification

### Priority 2 (Incident Management)
- **Yukine**: Developer - Technical operations support
- **Rem**: AI Assistant - System monitoring and documentation

### External Resources
- Cloud provider support (if applicable)
- Security consultant contacts (if available)
- Legal counsel (for data breach scenarios)

---

*This security policy is a living document. Update regularly based on new threats, incidents, and organizational changes.*