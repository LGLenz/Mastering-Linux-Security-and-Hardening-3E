# Traditional Linux Servers (On-Premises) Migration Guide

## Übersicht (Overview)

Dieser Leitfaden richtet sich an die Migration von Fördersystemen vom Großrechner auf traditionelle On-Premises Linux-Server. Der Fokus liegt auf der sicheren Integration von Legacy-Anwendungen wie Adabas in gehärteten Linux-Umgebungen.

This guide covers migration from mainframe to traditional on-premises Linux servers, focusing on secure integration of legacy applications like Adabas in hardened Linux environments.

## Pre-Configuration Review (BITBW)

### What BITBW Typically Pre-Configures

Before beginning additional hardening, review the following BITBW pre-configurations:

#### 1. Base System Security
- [ ] SELinux/AppArmor enforcement mode
- [ ] Firewall baseline rules
- [ ] System user accounts and groups
- [ ] SSH configuration and key management
- [ ] Audit daemon (auditd) configuration
- [ ] Time synchronization (NTP/chrony)

#### 2. Network Configuration
- [ ] Network interfaces and VLANs
- [ ] DNS and name resolution
- [ ] Network security groups/zones
- [ ] Internal routing tables
- [ ] Proxy configuration (if applicable)

#### 3. Storage and Filesystem
- [ ] Disk partitioning scheme
- [ ] LVM configuration
- [ ] Encrypted volumes (LUKS)
- [ ] Mount options (noexec, nosuid, nodev)
- [ ] Backup integration

#### 4. Monitoring and Logging
- [ ] Centralized logging (rsyslog/syslog-ng)
- [ ] Log rotation policies
- [ ] SIEM integration points
- [ ] Performance monitoring agents

**Action Items:**
1. Request BITBW configuration documentation
2. Verify each pre-configured item
3. Document any missing configurations
4. Identify customization needs

## Legacy Application Integration

### Adabas Database Hardening

#### Installation Verification
```bash
# Verify Adabas installation
ls -la /opt/softwareag/Adabas/
systemctl status adabas

# Check running processes
ps aux | grep -i adabas
```

#### Security Configuration

1. **File System Permissions**
```bash
# Set appropriate ownership
chown -R adabas:adabas /opt/softwareag/Adabas/
chmod 750 /opt/softwareag/Adabas/bin/
chmod 640 /opt/softwareag/Adabas/config/*
```

2. **SELinux Policy for Adabas**
```bash
# Create custom SELinux policy
semanage fcontext -a -t adabas_exec_t "/opt/softwareag/Adabas/bin/(.*)"
restorecon -Rv /opt/softwareag/Adabas/

# Generate custom policy if needed
ausearch -m avc -ts recent | audit2allow -M adabas_custom
semodule -i adabas_custom.pp
```

3. **Network Access Control**
```bash
# Restrict Adabas network ports (typically 8080, 48080)
firewall-cmd --permanent --zone=internal --add-port=48080/tcp
firewall-cmd --permanent --zone=internal --add-rich-rule='rule family="ipv4" source address="10.0.0.0/8" port port="48080" protocol="tcp" accept'
firewall-cmd --reload
```

4. **Resource Limits**
```bash
# Add to /etc/security/limits.conf
adabas soft nofile 65536
adabas hard nofile 65536
adabas soft nproc 4096
adabas hard nproc 4096
```

### COBOL Application Runtime

#### Natural/COBOL Environment Setup
```bash
# Verify Natural installation
ls -la /opt/softwareag/Natural/

# Set environment variables securely
cat > /etc/profile.d/natural.sh << 'EOF'
export NATDIR=/opt/softwareag/Natural
export PATH=$NATDIR/bin:$PATH
export LD_LIBRARY_PATH=$NATDIR/lib:$LD_LIBRARY_PATH
EOF
chmod 644 /etc/profile.d/natural.sh
```

## Additional Hardening Steps

### 1. Kernel Hardening
```bash
# Apply kernel security parameters
cat > /etc/sysctl.d/99-hardening.conf << 'EOF'
# Network security
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0

# Kernel hardening
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.yama.ptrace_scope = 1
EOF

sysctl --system
```

### 2. User Access Management
```bash
# Create service accounts for Fördersystem components
useradd -r -s /sbin/nologin -d /opt/foerdersystem foerder-app
useradd -r -s /sbin/nologin -d /var/lib/adabas adabas

# Configure sudo access
cat > /etc/sudoers.d/foerdersystem << 'EOF'
%foerder-admins ALL=(foerder-app) NOPASSWD: /usr/bin/systemctl restart foerdersystem
%foerder-admins ALL=(adabas) NOPASSWD: /opt/softwareag/Adabas/bin/adactl
EOF
chmod 440 /etc/sudoers.d/foerdersystem
```

### 3. Application Firewall Rules
```bash
# Configure specific rules for Fördersystem
# Allow only internal network access
firewall-cmd --permanent --new-zone=foerdersystem
firewall-cmd --permanent --zone=foerdersystem --add-source=10.0.0.0/8
firewall-cmd --permanent --zone=foerdersystem --add-port=8080/tcp
firewall-cmd --permanent --zone=foerdersystem --add-port=48080/tcp
firewall-cmd --reload
```

### 4. Compliance Scanning
```bash
# Run SCAP compliance scan
oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard \
  --results /tmp/scap-results.xml \
  --report /tmp/scap-report.html \
  /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml

# Review results
firefox /tmp/scap-report.html
```

## Monitoring and Maintenance

### Log Monitoring
```bash
# Monitor Adabas logs
tail -f /opt/softwareag/Adabas/log/adabas.log

# Monitor system authentication
tail -f /var/log/auth.log

# Monitor audit logs
ausearch -ts today -m avc
```

### Regular Security Audits
- Weekly: Review authentication logs
- Monthly: Run SCAP compliance scans
- Quarterly: Vulnerability assessments
- Annually: Penetration testing

## Troubleshooting

### Common Issues

#### SELinux Denials
```bash
# Check recent denials
ausearch -m avc -ts recent

# Generate allow policy
ausearch -m avc -ts recent | audit2allow -M my_policy
semodule -i my_policy.pp
```

#### Network Connectivity
```bash
# Test Adabas connectivity
telnet localhost 48080
nc -zv localhost 48080

# Check firewall rules
firewall-cmd --list-all-zones
```

## Support Contacts

- **BITBW Infrastructure**: [Contact BITBW]
- **LGL BW IT Security**: [Contact LGL]
- **Adabas Support**: Software AG support portal

---

**Languages Available**: Deutsch (Sie) | English | عربي | Türkçe
