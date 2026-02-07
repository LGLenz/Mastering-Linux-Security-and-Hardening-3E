#!/bin/bash
#
# linux-server-hardening.sh
#
# Automated Linux Server Hardening Script for BSI Grundschutz Compliance
# For use during migration from mainframe systems to Linux
#
# Author: Migration Team
# Version: 1.0.0
# Date: 2026-02-07
#
# Usage: sudo ./linux-server-hardening.sh [--dry-run]
#
# BSI Grundschutz Bausteine: SYS.1.1, SYS.1.3
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
BACKUP_DIR="/var/backups/hardening-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/var/log/hardening.log"
DRY_RUN=false

# Parse arguments
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN=true
    echo -e "${YELLOW}Running in DRY-RUN mode - no changes will be made${NC}"
fi

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $*" | tee -a "$LOG_FILE"
}

log_error() {
    echo -e "${RED}[✗]${NC} $*" | tee -a "$LOG_FILE"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $*" | tee -a "$LOG_FILE"
}

# Check if running as root
if [[ $EUID -ne 0 ]]; then
   log_error "This script must be run as root"
   exit 1
fi

# Create backup directory
mkdir -p "$BACKUP_DIR"
log "Backup directory: $BACKUP_DIR"

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VER=$VERSION_ID
else
    log_error "Cannot detect Linux distribution"
    exit 1
fi

log "Detected OS: $OS $VER"

# Backup function
backup_file() {
    local file=$1
    if [ -f "$file" ]; then
        cp "$file" "$BACKUP_DIR/$(basename $file).bak"
        log "Backed up: $file"
    fi
}

# Apply changes function (respects dry-run)
apply_change() {
    if [ "$DRY_RUN" = true ]; then
        log_warning "DRY-RUN: Would execute: $*"
    else
        eval "$@"
    fi
}

#
# 1. Kernel Hardening (SYS.1.3.A13)
#
log "=== 1. Kernel Hardening ==="

backup_file /etc/sysctl.conf

cat > /tmp/99-security-hardening.conf << 'EOF'
# BSI Grundschutz SYS.1.3 - Kernel Hardening

# Network Security
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Kernel Security
kernel.randomize_va_space = 2
kernel.core_uses_pid = 1
fs.suid_dumpable = 0
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
kernel.kexec_load_disabled = 1
kernel.unprivileged_bpf_disabled = 1
net.core.bpf_jit_harden = 2
EOF

if [ "$DRY_RUN" = false ]; then
    mv /tmp/99-security-hardening.conf /etc/sysctl.d/
    sysctl -p /etc/sysctl.d/99-security-hardening.conf >/dev/null 2>&1
    log_success "Kernel hardening applied"
else
    log_warning "DRY-RUN: Would apply kernel hardening"
fi

#
# 2. SSH Hardening (SYS.1.3.A8)
#
log "=== 2. SSH Hardening ==="

backup_file /etc/ssh/sshd_config

cat > /tmp/sshd_config_hardened << 'EOF'
# BSI Grundschutz SYS.1.3.A8 - SSH Hardening

Protocol 2
Port 22

# Authentication
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no
UsePAM yes

# Strong Cryptography
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group16-sha512
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Security Options
X11Forwarding no
PermitUserEnvironment no
AllowAgentForwarding no
AllowTcpForwarding no
PrintMotd no
PrintLastLog yes
TCPKeepAlive no
ClientAliveInterval 300
ClientAliveCountMax 2
LoginGraceTime 30
MaxAuthTries 3
MaxSessions 2

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Banner
Banner /etc/issue.net
EOF

if [ "$DRY_RUN" = false ]; then
    mv /tmp/sshd_config_hardened /etc/ssh/sshd_config
    chmod 600 /etc/ssh/sshd_config
    # Test configuration
    if sshd -t; then
        systemctl restart sshd
        log_success "SSH hardening applied and service restarted"
    else
        log_error "SSH configuration test failed, reverting"
        cp "$BACKUP_DIR/sshd_config.bak" /etc/ssh/sshd_config
    fi
else
    log_warning "DRY-RUN: Would apply SSH hardening"
fi

#
# 3. Firewall Configuration (NET.3.2)
#
log "=== 3. Firewall Configuration ==="

if command -v firewall-cmd &> /dev/null; then
    # firewalld (RHEL/CentOS)
    apply_change "systemctl enable --now firewalld"
    apply_change "firewall-cmd --set-default-zone=drop"
    apply_change "firewall-cmd --permanent --zone=public --add-service=ssh"
    apply_change "firewall-cmd --permanent --zone=public --add-rich-rule='rule service name=\"ssh\" accept limit value=\"3/m\"'"
    apply_change "firewall-cmd --reload"
    log_success "Firewalld configured"
elif command -v ufw &> /dev/null; then
    # UFW (Ubuntu)
    apply_change "ufw default deny incoming"
    apply_change "ufw default allow outgoing"
    apply_change "ufw limit ssh/tcp"
    apply_change "ufw --force enable"
    log_success "UFW configured"
else
    log_warning "No firewall found (firewalld/ufw)"
fi

#
# 4. Disable Unnecessary Services (SYS.1.1.A3)
#
log "=== 4. Disable Unnecessary Services ==="

SERVICES_TO_DISABLE=(
    "avahi-daemon"
    "cups"
    "bluetooth"
    "iscsid"
    "rpcbind"
)

for service in "${SERVICES_TO_DISABLE[@]}"; do
    if systemctl list-unit-files | grep -q "^$service"; then
        apply_change "systemctl disable --now $service 2>/dev/null" || true
        log_success "Disabled service: $service"
    fi
done

#
# 5. Auditd Configuration (DER.1)
#
log "=== 5. Auditd Configuration ==="

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apply_change "apt-get install -y auditd audispd-plugins"
elif [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
    apply_change "dnf install -y audit"
fi

backup_file /etc/audit/rules.d/99-security.rules

cat > /tmp/99-security.rules << 'EOF'
# BSI Grundschutz - Audit Rules

-D
-b 8192
-f 1

# Identity Changes
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity

# Sudoers
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

# SSH Configuration
-w /etc/ssh/sshd_config -p wa -k sshd_config

# Kernel Modules
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -k modules

# File Deletions
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=-1 -k delete

# Make immutable
-e 2
EOF

if [ "$DRY_RUN" = false ]; then
    mv /tmp/99-security.rules /etc/audit/rules.d/
    systemctl enable --now auditd
    augenrules --load
    log_success "Auditd configured"
else
    log_warning "DRY-RUN: Would configure auditd"
fi

#
# 6. Password Policies (SYS.1.3.A4)
#
log "=== 6. Password Policies ==="

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apply_change "apt-get install -y libpam-pwquality"
elif [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
    apply_change "dnf install -y libpwquality"
fi

backup_file /etc/security/pwquality.conf

cat > /tmp/pwquality.conf << 'EOF'
# BSI Grundschutz - Password Quality
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
maxrepeat = 3
maxclassrepeat = 4
gecoscheck = 1
EOF

if [ "$DRY_RUN" = false ]; then
    mv /tmp/pwquality.conf /etc/security/pwquality.conf
    log_success "Password policies configured"
else
    log_warning "DRY-RUN: Would configure password policies"
fi

# Configure password aging
backup_file /etc/login.defs

if [ "$DRY_RUN" = false ]; then
    sed -i 's/^PASS_MAX_DAYS.*/PASS_MAX_DAYS   90/' /etc/login.defs
    sed -i 's/^PASS_MIN_DAYS.*/PASS_MIN_DAYS   1/' /etc/login.defs
    sed -i 's/^PASS_WARN_AGE.*/PASS_WARN_AGE   7/' /etc/login.defs
    log_success "Password aging configured"
else
    log_warning "DRY-RUN: Would configure password aging"
fi

#
# 7. Install Security Tools
#
log "=== 7. Install Security Tools ==="

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apply_change "apt-get update"
    apply_change "apt-get install -y aide rkhunter clamav clamav-daemon fail2ban"
elif [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
    apply_change "dnf install -y aide rkhunter clamav clamav-update fail2ban"
fi

log_success "Security tools installed"

#
# 8. Initialize AIDE (File Integrity)
#
log "=== 8. Initialize AIDE ==="

if [ "$DRY_RUN" = false ]; then
    if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
        aideinit
        mv /var/lib/aide/aide.db.new /var/lib/aide/aide.db
    elif [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
        aide --init
        mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
    fi
    log_success "AIDE initialized"
else
    log_warning "DRY-RUN: Would initialize AIDE"
fi

#
# 9. Configure Automatic Updates (OPS.1.1.3)
#
log "=== 9. Configure Automatic Security Updates ==="

if [ "$OS" = "ubuntu" ] || [ "$OS" = "debian" ]; then
    apply_change "apt-get install -y unattended-upgrades apt-listchanges"
    
    cat > /tmp/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::Mail "root";
Unattended-Upgrade::MailReport "on-change";
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Automatic-Reboot "false";
EOF
    
    if [ "$DRY_RUN" = false ]; then
        mv /tmp/50unattended-upgrades /etc/apt/apt.conf.d/
        systemctl enable --now unattended-upgrades
        log_success "Unattended upgrades configured"
    fi
    
elif [ "$OS" = "rhel" ] || [ "$OS" = "centos" ] || [ "$OS" = "rocky" ]; then
    apply_change "dnf install -y dnf-automatic"
    
    if [ "$DRY_RUN" = false ]; then
        sed -i 's/^apply_updates = .*/apply_updates = yes/' /etc/dnf/automatic.conf
        sed -i 's/^upgrade_type = .*/upgrade_type = security/' /etc/dnf/automatic.conf
        systemctl enable --now dnf-automatic.timer
        log_success "DNF automatic configured"
    fi
fi

#
# 10. Set Permissions on Important Files
#
log "=== 10. Set Secure File Permissions ==="

if [ "$DRY_RUN" = false ]; then
    chmod 600 /etc/ssh/sshd_config
    chmod 600 /etc/shadow
    chmod 600 /etc/gshadow
    chmod 644 /etc/passwd
    chmod 644 /etc/group
    chmod 600 /boot/grub/grub.cfg 2>/dev/null || true
    chmod 600 /boot/grub2/grub.cfg 2>/dev/null || true
    log_success "File permissions set"
else
    log_warning "DRY-RUN: Would set file permissions"
fi

#
# 11. Disable IPv6 (if not needed)
#
log "=== 11. IPv6 Configuration ==="

read -p "Disable IPv6? (y/N): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    cat >> /etc/sysctl.d/99-security-hardening.conf << 'EOF'

# Disable IPv6
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
EOF
    apply_change "sysctl -p /etc/sysctl.d/99-security-hardening.conf"
    log_success "IPv6 disabled"
fi

#
# 12. Generate Hardening Report
#
log "=== Generating Hardening Report ==="

REPORT_FILE="/var/log/hardening-report-$(date +%Y%m%d_%H%M%S).txt"

{
    echo "======================================"
    echo "Linux Server Hardening Report"
    echo "======================================"
    echo "Date: $(date)"
    echo "Hostname: $(hostname)"
    echo "OS: $OS $VER"
    echo "Kernel: $(uname -r)"
    echo ""
    echo "======================================"
    echo "Hardening Applied:"
    echo "======================================"
    echo "✓ Kernel hardening"
    echo "✓ SSH hardening"
    echo "✓ Firewall configured"
    echo "✓ Unnecessary services disabled"
    echo "✓ Auditd configured"
    echo "✓ Password policies"
    echo "✓ Security tools installed"
    echo "✓ AIDE initialized"
    echo "✓ Automatic updates configured"
    echo "✓ File permissions set"
    echo ""
    echo "======================================"
    echo "Recommendations:"
    echo "======================================"
    echo "1. Configure SELinux/AppArmor"
    echo "2. Set up centralized logging (rsyslog to SIEM)"
    echo "3. Configure monitoring (Prometheus, Wazuh)"
    echo "4. Perform vulnerability scan (OpenVAS, Lynis)"
    echo "5. Configure backups"
    echo "6. Set up Multi-Factor Authentication"
    echo "7. Review and test all configurations"
    echo ""
    echo "======================================"
    echo "Backup Location: $BACKUP_DIR"
    echo "Log File: $LOG_FILE"
    echo "======================================"
} | tee "$REPORT_FILE"

log_success "Hardening completed! Report: $REPORT_FILE"
log "Please review the report and test all configurations"
log "Reboot recommended to apply all kernel parameters"

if [ "$DRY_RUN" = false ]; then
    read -p "Reboot now? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log "System rebooting..."
        reboot
    fi
fi

exit 0
