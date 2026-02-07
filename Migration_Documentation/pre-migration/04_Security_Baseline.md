# Security Baseline / Sicherheits-Grundkonfiguration

## Übersicht / Overview

Die Security Baseline definiert die Mindest-Sicherheitsanforderungen für alle Linux-Server gemäß BSI Grundschutz und ist vor der Migration zu implementieren.

## 1. Betriebssystem-Härtung / OS Hardening

### 1.1 Linux-Distribution Auswahl

**Empfohlene Distributionen für Behörden**:
1. **Red Hat Enterprise Linux (RHEL) 8/9** - Empfohlen
   - Kommerzielle Support
   - FIPS 140-2 zertifiziert
   - BSI-konforme Security Policies
   - Extended Update Support (EUS)

2. **Ubuntu Server 22.04 LTS**
   - Ubuntu Pro für Government
   - 10 Jahre Security Updates
   - FIPS-Certified Packages
   
3. **SUSE Linux Enterprise Server (SLES) 15**
   - German company, Government Support
   - BSI Grundschutz-konform

### 1.2 Minimale Installation

```bash
# Nur erforderliche Pakete installieren
# Beispiel für RHEL 8:

# Minimal Installation Group
dnf groupinstall "Minimal Install"

# Zusätzlich erforderliche Pakete:
dnf install -y \
    openssh-server \
    sudo \
    firewalld \
    aide \
    auditd \
    rsyslog \
    chrony \
    policycoreutils-python-utils \
    selinux-policy-targeted

# NICHT installieren:
# - X Window System
# - Desktop Environments
# - Development Tools (außer auf Build-Servern)
# - Unnötige Network Services
```

### 1.3 Kernel-Härtung

**`/etc/sysctl.d/99-security-hardening.conf`**:
```bash
# IP Forwarding deaktivieren (außer auf Routern)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Source Routing verbieten
net.ipv4.conf.all.accept_source_route = 0
net.ipv4.conf.default.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv6.conf.default.accept_source_route = 0

# ICMP Redirects ablehnen
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0

# Secure ICMP Redirects
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.default.secure_redirects = 0

# ICMP Redirect-Senden verbieten
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0

# Reverse Path Filtering
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# Ignore ICMP Ping
net.ipv4.icmp_echo_ignore_all = 0
net.ipv6.icmp.echo_ignore_all = 0

# Ignore Bogus ICMP Errors
net.ipv4.icmp_ignore_bogus_error_responses = 1

# TCP SYN Cookies aktivieren (DDoS-Schutz)
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 5

# Logging von Martian Packets
net.ipv4.conf.all.log_martians = 1
net.ipv4.conf.default.log_martians = 1

# IPv6 Router Advertisements ignorieren
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.default.accept_ra = 0

# Address Space Layout Randomization (ASLR)
kernel.randomize_va_space = 2

# Core Dumps einschränken
kernel.core_uses_pid = 1
fs.suid_dumpable = 0

# Restrict dmesg
kernel.dmesg_restrict = 1

# Restrict kernel pointer access
kernel.kptr_restrict = 2

# Ptrace scope (verhindert process injection)
kernel.yama.ptrace_scope = 1

# Anwenden:
sysctl -p /etc/sysctl.d/99-security-hardening.conf
```

### 1.4 SELinux Konfiguration (RHEL/CentOS)

```bash
# SELinux Status prüfen
getenforce
# Muss: Enforcing

# SELinux permanent aktivieren
# /etc/selinux/config:
SELINUX=enforcing
SELINUXTYPE=targeted

# SELinux Violations prüfen
ausearch -m avc -ts recent
sealert -a /var/log/audit/audit.log

# Booleans für PostgreSQL (Beispiel)
setsebool -P postgresql_can_rsync on
setsebool -P postgresql_selinux_transmit_client_label on

# SELinux-Kontext für Custom-Anwendungen
semanage fcontext -a -t httpd_sys_content_t "/var/www/myapp(/.*)?"
restorecon -Rv /var/www/myapp
```

### 1.5 AppArmor Konfiguration (Ubuntu/SUSE)

```bash
# AppArmor Status
aa-status

# AppArmor aktivieren
systemctl enable apparmor
systemctl start apparmor

# Profile für PostgreSQL
aa-enforce /etc/apparmor.d/usr.lib.postgresql.*

# Custom Profile erstellen (Beispiel)
cat > /etc/apparmor.d/usr.bin.myapp << 'EOF'
#include <tunables/global>

/usr/bin/myapp {
  #include <abstractions/base>
  #include <abstractions/nameservice>
  
  /usr/bin/myapp mr,
  /etc/myapp/* r,
  /var/lib/myapp/** rw,
  /var/log/myapp/* w,
  
  # PostgreSQL
  /run/postgresql/.s.PGSQL.5432 rw,
  
  deny /proc/sys/kernel/** w,
  deny /sys/** w,
}
EOF

aa-enforce /etc/apparmor.d/usr.bin.myapp
```

## 2. Zugriffskontrolle / Access Control

### 2.1 Benutzer- und Gruppenverwaltung

```bash
# Keine direkten Root-Logins
# /etc/ssh/sshd_config:
PermitRootLogin no

# Sudo konfigurieren
# /etc/sudoers.d/admins:
%wheel ALL=(ALL) ALL
Defaults timestamp_timeout=5
Defaults use_pty
Defaults logfile=/var/log/sudo.log

# Starke Passwort-Policies
# /etc/security/pwquality.conf:
minlen = 14
dcredit = -1
ucredit = -1
ocredit = -1
lcredit = -1
maxrepeat = 3
maxclassrepeat = 4
gecoscheck = 1

# Account-Lockout nach fehlgeschlagenen Logins
# /etc/security/faillock.conf:
deny = 5
unlock_time = 900
fail_interval = 900

# Passwort-Aging
# /etc/login.defs:
PASS_MAX_DAYS   90
PASS_MIN_DAYS   1
PASS_WARN_AGE   7
```

### 2.2 SSH-Härtung

**`/etc/ssh/sshd_config`**:
```bash
# Protokoll
Protocol 2

# Keine Root-Logins
PermitRootLogin no

# Nur Public-Key-Authentication
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM yes

# Kerberos/GSSAPI deaktivieren (falls nicht benötigt)
GSSAPIAuthentication no
KerberosAuthentication no

# Starke Krypto
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group18-sha512,diffie-hellman-group16-sha512
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Login-Timeouts
LoginGraceTime 30
ClientAliveInterval 300
ClientAliveCountMax 2

# Nur bestimmte Benutzer/Gruppen
AllowGroups ssh-users
# oder:
AllowUsers admin1 admin2

# X11 Forwarding deaktivieren
X11Forwarding no

# Banner
Banner /etc/issue.net

# Logging
SyslogFacility AUTHPRIV
LogLevel VERBOSE

# Restart SSH
systemctl restart sshd
```

**Multi-Faktor-Authentifizierung (MFA) mit Google Authenticator**:
```bash
# Installation
dnf install -y google-authenticator

# Für jeden User:
google-authenticator

# /etc/pam.d/sshd (am Anfang hinzufügen):
auth required pam_google_authenticator.so

# /etc/ssh/sshd_config:
ChallengeResponseAuthentication yes
AuthenticationMethods publickey,keyboard-interactive

systemctl restart sshd
```

### 2.3 Firewall-Konfiguration

**firewalld (RHEL/CentOS)**:
```bash
# Firewalld aktivieren
systemctl enable --now firewalld

# Default Zone: drop (alles verbieten)
firewall-cmd --set-default-zone=drop

# Trusted-Zone für Management-Netz
firewall-cmd --permanent --new-zone=management
firewall-cmd --permanent --zone=management --add-source=10.0.0.0/24
firewall-cmd --permanent --zone=management --add-service=ssh
firewall-cmd --permanent --zone=management --add-service=https

# Public-Zone für Applikations-Traffic
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --permanent --zone=public --add-service=https

# Internal-Zone für Datenbank
firewall-cmd --permanent --new-zone=database
firewall-cmd --permanent --zone=database --add-source=10.1.0.0/24
firewall-cmd --permanent --zone=database --add-port=5432/tcp

# Rate-Limiting gegen Brute-Force
firewall-cmd --permanent --zone=public --add-rich-rule='rule service name="ssh" accept limit value="3/m"'

# Reload
firewall-cmd --reload

# Status anzeigen
firewall-cmd --list-all-zones
```

**UFW (Ubuntu)**:
```bash
# UFW aktivieren
ufw enable

# Default Policies
ufw default deny incoming
ufw default allow outgoing

# SSH von Management-Netz
ufw allow from 10.0.0.0/24 to any port 22 proto tcp

# HTTP/HTTPS
ufw allow 80/tcp
ufw allow 443/tcp

# PostgreSQL nur intern
ufw allow from 10.1.0.0/24 to any port 5432 proto tcp

# Rate-Limiting
ufw limit ssh/tcp

# Status
ufw status verbose
```

## 3. Audit und Logging / Audit and Logging

### 3.1 Auditd Konfiguration

**`/etc/audit/rules.d/99-security.rules`**:
```bash
# Lösche alle Regeln
-D

# Buffer-Größe
-b 8192

# Failure Mode (1 = printk, 2 = panic)
-f 1

# Audit-Regeln unveränderlich (nur nach Reboot änderbar)
-e 2

## BSI Grundschutz Audit Rules ##

# 1. Änderungen an Account-Dateien
-w /etc/passwd -p wa -k identity
-w /etc/group -p wa -k identity
-w /etc/shadow -p wa -k identity
-w /etc/gshadow -p wa -k identity
-w /etc/security/opasswd -p wa -k identity

# 2. Änderungen an Sudoers
-w /etc/sudoers -p wa -k sudoers
-w /etc/sudoers.d/ -p wa -k sudoers

# 3. Änderungen an SSH-Konfiguration
-w /etc/ssh/sshd_config -p wa -k sshd_config

# 4. Privilegierte Kommandos
-a always,exit -F arch=b64 -S execve -F euid=0 -F auid>=1000 -F auid!=-1 -k privileged

# 5. Erfolgreiche/erfolglose Logins
-w /var/log/lastlog -p wa -k logins
-w /var/run/faillock/ -p wa -k logins

# 6. System-Neustarts und -Shutdowns
-w /sbin/shutdown -p x -k power
-w /sbin/reboot -p x -k power
-w /sbin/halt -p x -k power

# 7. Kernel-Modul-Änderungen
-w /sbin/insmod -p x -k modules
-w /sbin/rmmod -p x -k modules
-w /sbin/modprobe -p x -k modules
-a always,exit -F arch=b64 -S init_module,delete_module -k modules

# 8. Zeit-Änderungen
-a always,exit -F arch=b64 -S adjtimex,settimeofday -k time-change
-a always,exit -F arch=b64 -S clock_settime -F a0=0x0 -k time-change
-w /etc/localtime -p wa -k time-change

# 9. Datei-Löschungen
-a always,exit -F arch=b64 -S unlink,unlinkat,rename,renameat -F auid>=1000 -F auid!=-1 -k delete

# 10. Änderungen an Berechtigungen
-a always,exit -F arch=b64 -S chmod,fchmod,fchmodat -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S chown,fchown,fchownat,lchown -F auid>=1000 -F auid!=-1 -k perm_mod
-a always,exit -F arch=b64 -S setxattr,lsetxattr,fsetxattr,removexattr,lremovexattr,fremovexattr -F auid>=1000 -F auid!=-1 -k perm_mod

# 11. Netzwerk-Aktivitäten
-a always,exit -F arch=b64 -S socket -F a0=10 -k network
-a always,exit -F arch=b64 -S socket -F a0=2 -k network

# 12. Zugriff auf sensitive Dateien
-a always,exit -F path=/etc/shadow -F perm=r -F auid>=1000 -F auid!=-1 -k sensitive-file-access

# Service neustarten
systemctl restart auditd

# Audit-Log prüfen
ausearch -k identity -i
aureport --summary
```

### 3.2 Rsyslog Konfiguration

**`/etc/rsyslog.d/99-remote-logging.conf`**:
```bash
# TLS für Remote-Logging (zu SIEM)
$DefaultNetstreamDriver gtls
$DefaultNetstreamDriverCAFile /etc/pki/rsyslog/ca.pem
$DefaultNetstreamDriverCertFile /etc/pki/rsyslog/cert.pem
$DefaultNetstreamDriverKeyFile /etc/pki/rsyslog/key.pem
$ActionSendStreamDriverAuthMode x509/name
$ActionSendStreamDriverMode 1

# Zu SIEM-Server senden
*.* @@siem.example.de:6514

# Lokale Logs behalten
*.* /var/log/messages

# Permissions
$FileCreateMode 0600
$DirCreateMode 0700

systemctl restart rsyslog
```

### 3.3 Log-Rotation

**`/etc/logrotate.d/security`**:
```bash
/var/log/secure /var/log/messages /var/log/cron /var/log/maillog {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    create 0600 root root
    sharedscripts
    postrotate
        /usr/bin/systemctl reload rsyslog > /dev/null 2>&1 || true
    endscript
}

/var/log/audit/audit.log {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    create 0600 root root
    postrotate
        /usr/sbin/service auditd restart > /dev/null 2>&1 || true
    endscript
}
```

## 4. Integritätsüberwachung / Integrity Monitoring

### 4.1 AIDE Konfiguration

**`/etc/aide.conf`**:
```bash
# AIDE Configuration for BSI Grundschutz

# Datenbank-Pfad
database=file:/var/lib/aide/aide.db.gz
database_out=file:/var/lib/aide/aide.db.new.gz
database_new=file:/var/lib/aide/aide.db.new.gz

# Report
gzip_dbout=yes
verbose=5
report_url=stdout
report_url=file:/var/log/aide/aide.log

# Regeln
CONTENT = sha512+ftype+p+u+g+n+acl+selinux+xattrs
ALLXTRAHASHES = sha1+rmd160+sha256+sha512+tiger
EVERYTHING = R+ALLXTRAHASHES
NORMAL = R+sha512
DIR = p+i+n+u+g+acl+selinux+xattrs
PERMS = p+u+g+acl+selinux+xattrs
LOG = >
LSPP = R+sha512+ftype+p+u+g+n+acl+selinux+xattrs

# Verzeichnisse überwachen
/boot/   CONTENT
/bin/    CONTENT
/sbin/   CONTENT
/lib/    CONTENT
/lib64/  CONTENT
/usr/bin/    CONTENT
/usr/sbin/   CONTENT
/usr/lib/    CONTENT
/usr/lib64/  CONTENT
/etc/    PERMS

# Ausschlüsse
!/var/log/.*
!/var/cache/.*
!/var/tmp/.*
!/tmp/.*
!/proc/.*
!/sys/.*
!/dev/.*

# Initialisierung
aide --init
mv /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz

# Tägliche Prüfung via Cron
cat > /etc/cron.daily/aide << 'EOF'
#!/bin/bash
/usr/sbin/aide --check | mail -s "AIDE Check $(hostname)" security@example.de
EOF
chmod +x /etc/cron.daily/aide
```

## 5. Verschlüsselung / Encryption

### 5.1 Disk Encryption mit LUKS

```bash
# Während Installation: Full Disk Encryption aktivieren
# Manuell für zusätzliche Partitionen:

# Verschlüsseln
cryptsetup luksFormat /dev/sdb1
cryptsetup luksOpen /dev/sdb1 encrypted_data

# Filesystem erstellen
mkfs.ext4 /dev/mapper/encrypted_data

# /etc/crypttab:
encrypted_data /dev/sdb1 none luks,discard

# /etc/fstab:
/dev/mapper/encrypted_data /mnt/encrypted ext4 defaults 0 2
```

### 5.2 TLS/SSL Zertifikate

```bash
# Let's Encrypt für öffentliche Services
dnf install -y certbot
certbot certonly --standalone -d server.example.de

# Interne CA für interne Services
openssl genrsa -out ca-key.pem 4096
openssl req -new -x509 -days 3650 -key ca-key.pem -out ca.pem

# Server-Zertifikat
openssl genrsa -out server-key.pem 4096
openssl req -new -key server-key.pem -out server.csr
openssl x509 -req -days 365 -in server.csr -CA ca.pem -CAkey ca-key.pem -CAcreateserial -out server-cert.pem

# Berechtigungen
chmod 600 *-key.pem
chmod 644 *.pem
```

## 6. Härtungs-Validierung / Hardening Validation

### 6.1 OpenSCAP Scan

```bash
# Installation
dnf install -y openscap-scanner scap-security-guide

# Scan durchführen
oscap xccdf eval \
    --profile xccdf_org.ssgproject.content_profile_cis \
    --results results.xml \
    --report report.html \
    /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# Report analysieren
firefox report.html
```

### 6.2 Lynis Audit

```bash
# Installation
git clone https://github.com/CISOfy/lynis /opt/lynis

# Audit durchführen
cd /opt/lynis
./lynis audit system

# Empfehlungen umsetzen
cat /var/log/lynis.log
```

## Nächste Schritte / Next Steps

Nach Etablierung der Security Baseline:
1. [Migration Execution](../during-migration/01_Migration_Execution.md)
2. [Data Migration](../during-migration/02_Data_Migration.md)
3. [Testing and Validation](../during-migration/03_Testing_and_Validation.md)

## Referenzen / References

- BSI Grundschutz SYS.1.3
- CIS Benchmarks for Linux
- DISA STIG for RHEL
- NIST SP 800-123: Guide to General Server Security
