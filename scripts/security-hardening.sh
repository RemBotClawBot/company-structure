#!/bin/bash
#
# Security Hardening Script
# Version: 1.0
# Date: February 15, 2026
#
# Purpose: Implement comprehensive security hardening for Ubuntu 24.04 LTS
# Use with caution - review before executing in production environments

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

check_root() {
    if [ "$EUID" -ne 0 ]; then 
        log_error "Please run as root"
        exit 1
    fi
}

check_ubuntu() {
    if [ ! -f /etc/os-release ]; then
        log_error "Cannot detect OS version"
        exit 1
    fi
    
    source /etc/os-release
    if [ "$ID" != "ubuntu" ] || [ "$VERSION_ID" != "24.04" ]; then
        log_warning "This script is designed for Ubuntu 24.04. Detected: $ID $VERSION_ID"
        read -p "Continue anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
}

# Main hardening functions
install_firewall() {
    log_info "Installing and configuring UFW firewall..."
    
    # Install UFW if not present
    if ! command -v ufw &> /dev/null; then
        apt update
        apt install -y ufw
    fi
    
    # Reset to default deny
    ufw --force reset
    
    # Set default policies
    ufw default deny incoming
    ufw default allow outgoing
    
    # Allow SSH on port 22
    ufw allow 22/tcp comment 'SSH'
    
    # Allow Git servers (optional - customize based on needs)
    ufw allow 3000/tcp comment 'Gitea'
    ufw allow 3001/tcp comment 'Forgejo'
    
    # Allow essential services
    ufw allow 80/tcp comment 'HTTP'
    ufw allow 443/tcp comment 'HTTPS'
    
    # Enable UFW
    ufw --force enable
    
    # Show status
    ufw status verbose
    
    log_success "Firewall installed and configured"
}

install_fail2ban() {
    log_info "Installing and configuring Fail2Ban..."
    
    # Install Fail2Ban
    apt update
    apt install -y fail2ban
    
    # Create configuration for SSH
    cat > /etc/fail2ban/jail.local << EOF
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5
ignoreip = 127.0.0.1/8 ::1

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 86400
EOF
    
    # Start and enable service
    systemctl restart fail2ban
    systemctl enable fail2ban
    
    # Check status
    fail2ban-client status sshd
    
    log_success "Fail2Ban installed and configured"
}

harden_ssh() {
    log_info "Hardening SSH configuration..."
    
    SSH_CONFIG="/etc/ssh/sshd_config"
    SSH_BACKUP="/etc/ssh/sshd_config.backup.$(date +%Y%m%d)"
    
    # Backup original config
    cp "$SSH_CONFIG" "$SSH_BACKUP"
    
    # Apply hardening changes
    cat > "$SSH_CONFIG" << EOF
# SSH Hardening Configuration
Port 22
Protocol 2
ListenAddress 0.0.0.0

# Authentication
PermitRootLogin prohibit-password
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Security Features
X11Forwarding no
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Network
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no

# Rate Limiting
MaxAuthTries 3
MaxSessions 10
ClientAliveInterval 300
ClientAliveCountMax 2

# Cryptography
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
KexAlgorithms curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
EOF
    
    # Restart SSH service
    systemctl restart ssh
    
    log_success "SSH hardened (backup saved to $SSH_BACKUP)"
}

restrict_services() {
    log_info "Restricting unauthorized services to localhost..."
    
    # Check for running services on problematic ports
    log_info "Checking services on exposed ports..."
    netstat -tulpn | grep -E ":(3002|8880)" || true
    
    # Create systemd override for vulnerable services
    # This is a template - customize based on actual services
    
    log_warning "Service restriction requires manual configuration"
    log_warning "Please review running services and configure appropriately"
}

setup_logging() {
    log_info "Setting up enhanced system logging..."
    
    # Configure auditd
    apt install -y auditd audispd-plugins
    
    # Important audit rules
    cat > /etc/audit/rules.d/50-company-structure.rules << EOF
# Monitor user logins
-w /var/log/auth.log -p wa -k authentication

# Monitor sudo usage
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d -p wa -k sudoers

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd

# Monitor critical directories
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity

# Monitor system binaries
-w /bin -p wa -k system_binaries
-w /usr/bin -p wa -k system_binaries
-w /usr/sbin -p wa -k system_binaries

# Monitor Git server
-w /opt/gitea -p wa -k gitea
-w /opt/gitea/app.ini -p wa -k gitea_config

# Monitor company documentation
-w /root/company-structure -p wa -k company_docs
EOF
    
    # Enable auditd
    systemctl enable auditd
    systemctl restart auditd
    
    log_success "Enhanced logging configured"
}

setup_monitoring() {
    log_info "Setting up security monitoring..."
    
    # Install and configure logwatch
    apt install -y logwatch
    
    # Configure daily security report
    cat > /etc/logwatch/conf/logwatch.conf << EOF
LogDir = /var/log
TmpDir = /var/cache/logwatch
Output = mail
Format = html
MailTo = root
MailFrom = logwatch@$(hostname -f)
Detail = High
Service = All
EOF
    
    log_success "Monitoring configured"
}

harden_system() {
    log_info "Applying system-wide hardening..."
    
    # Update system
    apt update
    apt upgrade -y
    
    # Install security updates automatically
    apt install -y unattended-upgrades
    dpkg-reconfigure -plow unattended-upgrades
    
    # Disable unnecessary services
    systemctl disable apache2.service || true
    systemctl disable nginx.service || true
    systemctl disable mysql.service || true
    
    # Set secure permissions on critical files
    chmod 600 /etc/shadow
    chmod 600 /etc/gshadow
    chmod 644 /etc/passwd
    chmod 644 /etc/group
    chmod 644 /etc/sudoers
    
    # Configure sysctl security parameters
    cat > /etc/sysctl.d/99-security.conf << EOF
# IP Spoofing protection
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP redirects
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0

# Ignore send redirects
net.ipv4.conf.all.send_redirects = 0

# Disable IPv6 if not needed
# net.ipv6.conf.all.disable_ipv6 = 1

# Log Martians
net.ipv4.conf.all.log_martians = 1

# Ignore directed pings
net.ipv4.icmp_echo_ignore_all = 1

# SYN Flood Protection
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2

# Disable IP source routing
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
EOF
    
    sysctl -p /etc/sysctl.d/99-security.conf
    
    log_success "System hardening applied"
}

create_backup_plan() {
    log_info "Creating comprehensive backup plan..."
    
    # Create backup directory structure
    mkdir -p /var/backups/company-structure/{daily,weekly,monthly}
    
    # Create backup script template
    cat > /root/company-structure/scripts/comprehensive-backup.sh << 'EOF'
#!/bin/bash
#
# Comprehensive Backup Script
# Backs up critical system and company data

BACKUP_ROOT="/var/backups/company-structure"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$BACKUP_ROOT/daily/$DATE"

# Create backup directory
mkdir -p "$BACKUP_DIR"

log_info() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] INFO: $1"
}

log_error() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] ERROR: $1" >&2
}

# Backup company-structure repository
log_info "Backing up company-structure repository..."
tar czf "$BACKUP_DIR/company-structure.tar.gz" -C /root company-structure

# Backup Gitea data
log_info "Backing up Gitea data..."
tar czf "$BACKUP_DIR/gitea-data.tar.gz" -C /opt gitea/data

# Backup Gitea configuration
log_info "Backing up Gitea configuration..."
cp /opt/gitea/app.ini "$BACKUP_DIR/app.ini"

# Backup OpenClaw workspace
log_info "Backing up OpenClaw workspace..."
tar czf "$BACKUP_DIR/openclaw-workspace.tar.gz" -C /root .openclaw/workspace

# Backup system configurations
log_info "Backing up system configurations..."
tar czf "$BACKUP_DIR/etc-configs.tar.gz" \
    /etc/ssh/sshd_config \
    /etc/ufw/ \
    /etc/fail2ban/ \
    /etc/sudoers \
    /etc/sudoers.d/

# Backup log files
log_info "Backing up recent logs..."
journalctl --since "24 hours ago" > "$BACKUP_DIR/journal.log"
tail -1000 /var/log/syslog > "$BACKUP_DIR/syslog.tail"
tail -1000 /var/log/auth.log > "$BACKUP_DIR/auth.log.tail"

# Create backup manifest
log_info "Creating backup manifest..."
cat > "$BACKUP_DIR/manifest.txt" << MANIFEST
Backup Date: $DATE
System: $(uname -a)
Disk Usage: $(df -h /)
Backup Contents:
- Company Structure Repository
- Gitea Data and Configuration
- OpenClaw Workspace
- System Configurations (SSH, UFW, Fail2Ban)
- Recent System Logs
MANIFEST

# Cleanup old backups (keep last 7 days)
log_info "Cleaning up old backups..."
find "$BACKUP_ROOT/daily/" -type d -mtime +7 -exec rm -rf {} \;
find "$BACKUP_ROOT/weekly/" -type d -mtime +30 -exec rm -rf {} \;
find "$BACKUP_ROOT/monthly/" -type d -mtime +365 -exec rm -rf {} \;

log_info "Backup completed: $BACKUP_DIR"
EOF
    
    chmod +x /root/company-structure/scripts/comprehensive-backup.sh
    
    log_success "Backup plan created"
}

main() {
    log_info "Starting security hardening process..."
    
    check_root
    check_ubuntu
    
    # Execute hardening steps
    install_firewall
    install_fail2ban
    harden_ssh
    restrict_services
    setup_logging
    setup_monitoring
    harden_system
    create_backup_plan
    
    log_info "Security hardening complete!"
    log_info "Summary of changes:"
    echo "1. UFW firewall installed and configured"
    echo "2. Fail2Ban installed for SSH protection"
    echo "3. SSH configuration hardened"
    echo "4. Enhanced system logging configured"
    echo "5. Security monitoring set up"
    echo "6. System-wide hardening applied"
    echo "7. Comprehensive backup plan created"
    echo ""
    log_warning "Manual configuration required for service restriction"
    log_warning "Review each step and test thoroughly"
}

# Parse command line arguments
case "$1" in
    --install-firewall)
        install_firewall
        ;;
    --install-fail2ban)
        install_fail2ban
        ;;
    --harden-ssh)
        harden_ssh
        ;;
    --setup-logging)
        setup_logging
        ;;
    --harden-system)
        harden_system
        ;;
    --all)
        main
        ;;
    --help)
        echo "Usage: $0 [OPTION]"
        echo "Options:"
        echo "  --install-firewall   Install and configure UFW"
        echo "  --install-fail2ban   Install and configure Fail2Ban"
        echo "  --harden-ssh         Harden SSH configuration"
        echo "  --setup-logging      Set up enhanced logging"
        echo "  --harden-system      Apply system-wide hardening"
        echo "  --all                Run all hardening steps"
        echo "  --help               Display this help"
        ;;
    *)
        if [ $# -eq 0 ]; then
            main
        else
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
        fi
        ;;
esac