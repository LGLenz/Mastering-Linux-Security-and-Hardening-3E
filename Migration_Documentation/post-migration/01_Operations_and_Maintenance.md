# Betrieb und Wartung / Operations and Maintenance

## Übersicht / Overview

Nach erfolgreicher Migration müssen die Linux-Server kontinuierlich gewartet und überwacht werden, um BSI Grundschutz-Compliance sicherzustellen.

## 1. Kontinuierliches Monitoring / Continuous Monitoring

### 1.1 System-Monitoring mit Prometheus und Grafana

**Prometheus Installation und Konfiguration**:
```bash
# Prometheus Installation
useradd --no-create-home --shell /bin/false prometheus

# Download und Installation
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
tar xvf prometheus-2.45.0.linux-amd64.tar.gz
cp prometheus-2.45.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.45.0.linux-amd64/promtool /usr/local/bin/

# Konfiguration
mkdir -p /etc/prometheus /var/lib/prometheus
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

alerting:
  alertmanagers:
    - static_configs:
        - targets:
          - localhost:9093

rule_files:
  - "/etc/prometheus/rules/*.yml"

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  
  - job_name: 'node'
    static_configs:
      - targets: 
        - 'server1.example.de:9100'
        - 'server2.example.de:9100'
  
  - job_name: 'postgresql'
    static_configs:
      - targets:
        - 'db.example.de:9187'
EOF

# Alert Rules für BSI Grundschutz
cat > /etc/prometheus/rules/bsi-grundschutz.yml << 'EOF'
groups:
  - name: BSI_Grundschutz_Alerts
    interval: 30s
    rules:
      # Disk Space (< 10% frei)
      - alert: DiskSpaceLow
        expr: (node_filesystem_avail_bytes / node_filesystem_size_bytes) * 100 < 10
        for: 5m
        labels:
          severity: critical
          bsi_baustein: SYS.1.3
        annotations:
          summary: "Disk space critically low"
          description: "{{ $labels.instance }} has less than 10% disk space available"
      
      # High CPU (> 90%)
      - alert: HighCPUUsage
        expr: 100 - (avg by (instance) (irate(node_cpu_seconds_total{mode="idle"}[5m])) * 100) > 90
        for: 10m
        labels:
          severity: warning
          bsi_baustein: SYS.1.1
        annotations:
          summary: "High CPU usage detected"
      
      # Memory pressure
      - alert: HighMemoryUsage
        expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes) * 100 < 10
        for: 5m
        labels:
          severity: warning
          bsi_baustein: SYS.1.1
        annotations:
          summary: "Memory critically low"
      
      # Service Down
      - alert: ServiceDown
        expr: up == 0
        for: 2m
        labels:
          severity: critical
          bsi_baustein: SYS.1.3
        annotations:
          summary: "Service {{ $labels.job }} is down"
      
      # PostgreSQL Down
      - alert: PostgreSQLDown
        expr: pg_up == 0
        for: 1m
        labels:
          severity: critical
          bsi_baustein: APP.4.3
        annotations:
          summary: "PostgreSQL is down on {{ $labels.instance }}"
      
      # Too many connections
      - alert: PostgreSQLTooManyConnections
        expr: (pg_stat_database_numbackends / pg_settings_max_connections) * 100 > 80
        for: 5m
        labels:
          severity: warning
          bsi_baustein: APP.4.3
        annotations:
          summary: "PostgreSQL connection pool nearly exhausted"
      
      # Failed SSH logins
      - alert: FailedSSHLogins
        expr: rate(node_authentication_failures_total[5m]) > 5
        for: 2m
        labels:
          severity: warning
          bsi_baustein: OPS.1.1.5
        annotations:
          summary: "Multiple failed SSH login attempts"
          description: "Potential brute force attack on {{ $labels.instance }}"
EOF

# Systemd Service
cat > /etc/systemd/system/prometheus.service << 'EOF'
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
  --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now prometheus
```

**Node Exporter auf allen Servern**:
```bash
# Node Exporter Installation
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.1/node_exporter-1.6.1.linux-amd64.tar.gz
tar xvf node_exporter-1.6.1.linux-amd64.tar.gz
cp node_exporter-1.6.1.linux-amd64/node_exporter /usr/local/bin/

# Systemd Service
cat > /etc/systemd/system/node_exporter.service << 'EOF'
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable --now node_exporter
```

### 1.2 SIEM mit Wazuh

**Wazuh Manager Installation**:
```bash
# Wazuh Repository
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import && chmod 644 /usr/share/keyrings/wazuh.gpg

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" | tee /etc/apt/sources.list.d/wazuh.list

apt-get update
apt-get install -y wazuh-manager

# BSI Grundschutz Regeln
cat > /var/ossec/etc/rules/bsi_grundschutz.xml << 'EOF'
<group name="bsi_grundschutz,">
  <!-- SYS.1.3: Verdächtige Root-Aktivitäten -->
  <rule id="100001" level="12">
    <if_sid>5402</if_sid>
    <user>root</user>
    <description>BSI: Direkter Root-Login (SYS.1.3)</description>
    <group>authentication_success,bsi_violation,</group>
  </rule>
  
  <!-- OPS.1.1.5: Fehlgeschlagene Logins -->
  <rule id="100002" level="10" frequency="5" timeframe="300">
    <if_matched_sid>5503</if_matched_sid>
    <description>BSI: Mehrfache fehlgeschlagene Login-Versuche (OPS.1.1.5)</description>
    <group>authentication_failures,bsi_alert,</group>
  </rule>
  
  <!-- SYS.1.3: Unerlaubte Berechtigungsänderungen -->
  <rule id="100003" level="10">
    <if_sid>550</if_sid>
    <match>chmod 777</match>
    <description>BSI: Gefährliche Berechtigungsänderung (SYS.1.3)</description>
    <group>file_perm_change,bsi_violation,</group>
  </rule>
  
  <!-- APP.4.3: Datenbankzugriffs-Anomalien -->
  <rule id="100004" level="8">
    <decoded_as>postgresql</decoded_as>
    <match>FATAL|ERROR</match>
    <description>BSI: PostgreSQL-Fehler (APP.4.3)</description>
    <group>database_error,bsi_alert,</group>
  </rule>
</group>
EOF

systemctl enable --now wazuh-manager
```

**Wazuh Agent auf allen Servern**:
```bash
# Agent Installation
apt-get install -y wazuh-agent

# Konfiguration
cat > /var/ossec/etc/ossec.conf << 'EOF'
<ossec_config>
  <client>
    <server>
      <address>siem.example.de</address>
      <port>1514</port>
      <protocol>tcp</protocol>
    </server>
  </client>
  
  <syscheck>
    <frequency>7200</frequency>
    
    <!-- BSI Grundschutz: Kritische Dateien -->
    <directories check_all="yes" realtime="yes">/etc</directories>
    <directories check_all="yes" realtime="yes">/usr/bin</directories>
    <directories check_all="yes" realtime="yes">/usr/sbin</directories>
    <directories check_all="yes" realtime="yes">/boot</directories>
    
    <ignore>/etc/mtab</ignore>
    <ignore>/etc/hosts.deny</ignore>
    <ignore>/etc/resolv.conf</ignore>
  </syscheck>
  
  <rootcheck>
    <frequency>86400</frequency>
    <rootkit_files>/var/ossec/etc/rootcheck/rootkit_files.txt</rootkit_files>
    <rootkit_trojans>/var/ossec/etc/rootcheck/rootkit_trojans.txt</rootkit_trojans>
  </rootcheck>
  
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/auth.log</location>
  </localfile>
  
  <localfile>
    <log_format>syslog</log_format>
    <location>/var/log/syslog</location>
  </localfile>
  
  <localfile>
    <log_format>audit</log_format>
    <location>/var/log/audit/audit.log</location>
  </localfile>
</ossec_config>
EOF

systemctl enable --now wazuh-agent
```

## 2. Patch Management / Patch-Verwaltung

### 2.1 Automatisches Patch Management (BSI OPS.1.1.3)

**Unattended Upgrades (Ubuntu)**:
```bash
# Installation
apt-get install -y unattended-upgrades apt-listchanges

# Konfiguration
cat > /etc/apt/apt.conf.d/50unattended-upgrades << 'EOF'
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};

Unattended-Upgrade::AutoFixInterruptedDpkg "true";
Unattended-Upgrade::MinimalSteps "true";
Unattended-Upgrade::InstallOnShutdown "false";

// Email notifications
Unattended-Upgrade::Mail "security@example.de";
Unattended-Upgrade::MailReport "on-change";

// Automatic reboot (nur für non-critical servers)
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

// Remove unused dependencies
Unattended-Upgrade::Remove-Unused-Dependencies "true";
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

// Logging
Unattended-Upgrade::SyslogEnable "true";
Unattended-Upgrade::SyslogFacility "daemon";
EOF

# Enable
systemctl enable --now unattended-upgrades
```

**DNF Automatic (RHEL/CentOS)**:
```bash
# Installation
dnf install -y dnf-automatic

# Konfiguration
cat > /etc/dnf/automatic.conf << 'EOF'
[commands]
upgrade_type = security
random_sleep = 0
download_updates = yes
apply_updates = yes

[emitters]
emit_via = email,motd

[email]
email_from = automatic@example.de
email_to = security@example.de
email_host = localhost
EOF

# Timer aktivieren
systemctl enable --now dnf-automatic.timer
```

### 2.2 Patch Management Workflow

```bash
#!/bin/bash
# patch-management.sh

# BSI OPS.1.1.3 konform

ENVIRONMENT="$1"  # dev, test, prod
NOTIFY_EMAIL="security@example.de"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a /var/log/patch-mgmt.log
}

case "$ENVIRONMENT" in
    dev)
        log "Patching DEV environment..."
        # Sofort patchen
        apt-get update && apt-get upgrade -y
        ;;
    
    test)
        log "Patching TEST environment..."
        # 1 Woche nach DEV
        apt-get update && apt-get upgrade -y
        ;;
    
    prod)
        log "Patching PROD environment..."
        # 2 Wochen nach TEST, nach Change-Approval
        if [ -f /var/run/patch-approved ]; then
            apt-get update && apt-get upgrade -y
            mail -s "PROD Patching completed" "$NOTIFY_EMAIL" < /dev/null
        else
            log "No approval found, skipping"
            exit 1
        fi
        ;;
esac

# Vulnerability Scan nach Patching
log "Running vulnerability scan..."
lynis audit system --quick

log "Patch management completed"
```

## 3. Backup und Disaster Recovery

### 3.1 PostgreSQL Backup

**Automatisches Backup-Script**:
```bash
#!/bin/bash
# postgresql-backup.sh

set -euo pipefail

BACKUP_DIR="/backup/postgresql"
RETENTION_DAYS=90
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
DB_HOST="db.example.de"
DB_USER="backup_user"
ENCRYPTION_KEY="/etc/backup/encryption.key"
NOTIFY_EMAIL="backup@example.de"

log() {
    logger -t postgresql-backup "$*"
}

# Full Backup
log "Starting full backup..."
pg_basebackup -h "$DB_HOST" -U "$DB_USER" -D "$BACKUP_DIR/full_$TIMESTAMP" -Ft -z -Xs -P

# Verschlüsselung (BSI Anforderung)
log "Encrypting backup..."
openssl enc -aes-256-cbc -salt -in "$BACKUP_DIR/full_$TIMESTAMP/base.tar.gz" \
    -out "$BACKUP_DIR/full_$TIMESTAMP/base.tar.gz.enc" -pass file:"$ENCRYPTION_KEY"

# Original löschen
rm "$BACKUP_DIR/full_$TIMESTAMP/base.tar.gz"

# Alte Backups löschen
log "Cleaning old backups..."
find "$BACKUP_DIR" -type d -mtime +$RETENTION_DAYS -exec rm -rf {} +

# Checksumme
log "Calculating checksum..."
sha256sum "$BACKUP_DIR/full_$TIMESTAMP/base.tar.gz.enc" > "$BACKUP_DIR/full_$TIMESTAMP/checksum.txt"

# Offsite-Backup
log "Copying to offsite storage..."
rsync -avz "$BACKUP_DIR/full_$TIMESTAMP/" backup-server.example.de:/offsite-backup/

# Notification
echo "Backup completed: $TIMESTAMP" | mail -s "PostgreSQL Backup Success" "$NOTIFY_EMAIL"

log "Backup completed successfully"
```

**Cron-Job für Backups**:
```bash
# /etc/cron.d/postgresql-backup

# Full Backup täglich um 02:00
0 2 * * * postgres /usr/local/bin/postgresql-backup.sh

# Incremental Backup alle 6 Stunden
0 */6 * * * postgres /usr/local/bin/postgresql-incremental-backup.sh
```

### 3.2 Disaster Recovery Test

```bash
#!/bin/bash
# dr-test.sh

# Quartalsweise DR-Tests (BSI CON.3)

set -euo pipefail

DR_TEST_LOG="/var/log/dr-test-$(date +%Y%m%d).log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$DR_TEST_LOG"
}

log "=== Starting DR Test ==="

# 1. Backup-Integrität prüfen
log "Checking backup integrity..."
LATEST_BACKUP=$(find /backup/postgresql -type d -name "full_*" | sort -r | head -1)
if [ ! -f "$LATEST_BACKUP/checksum.txt" ]; then
    log "ERROR: No checksum file found"
    exit 1
fi

# 2. Test-Restore in isolierter Umgebung
log "Performing test restore..."
docker run -d --name dr-test-postgres \
    -e POSTGRES_PASSWORD=test \
    -v "$LATEST_BACKUP:/backup" \
    postgres:14

# 3. Daten-Validierung
log "Validating restored data..."
sleep 10
docker exec dr-test-postgres psql -U postgres -c "SELECT COUNT(*) FROM employees;"

# 4. Cleanup
log "Cleaning up..."
docker stop dr-test-postgres
docker rm dr-test-postgres

log "=== DR Test Completed Successfully ==="

# Report senden
mail -s "DR Test Report $(date +%Y-%m-%d)" security@example.de < "$DR_TEST_LOG"
```

## 4. Compliance Audits / Compliance-Prüfungen

### 4.1 BSI Grundschutz Compliance Check

```bash
#!/bin/bash
# bsi-compliance-check.sh

set -euo pipefail

REPORT_DIR="/var/reports/compliance"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
REPORT_FILE="$REPORT_DIR/bsi-compliance-$TIMESTAMP.html"

mkdir -p "$REPORT_DIR"

echo "<html><head><title>BSI Grundschutz Compliance Report</title></head><body>" > "$REPORT_FILE"
echo "<h1>BSI Grundschutz Compliance Report</h1>" >> "$REPORT_FILE"
echo "<p>Generated: $(date)</p>" >> "$REPORT_FILE"

# SYS.1.3: OpenSCAP Scan
echo "<h2>SYS.1.3: Server unter Linux</h2>" >> "$REPORT_FILE"
oscap xccdf eval \
    --profile xccdf_org.ssgproject.content_profile_bsi \
    --results "$REPORT_DIR/oscap-results-$TIMESTAMP.xml" \
    --report "$REPORT_DIR/oscap-report-$TIMESTAMP.html" \
    /usr/share/xml/scap/ssg/content/ssg-ubuntu2204-ds.xml || true

echo "<iframe src='oscap-report-$TIMESTAMP.html' width='100%' height='500'></iframe>" >> "$REPORT_FILE"

# OPS.1.1.5: Backup-Status
echo "<h2>OPS.1.1.5: Datensicherung</h2>" >> "$REPORT_FILE"
echo "<pre>" >> "$REPORT_FILE"
find /backup -type f -mtime -1 -ls >> "$REPORT_FILE"
echo "</pre>" >> "$REPORT_FILE"

# APP.4.3: PostgreSQL Security
echo "<h2>APP.4.3: Relationale Datenbanken</h2>" >> "$REPORT_FILE"
echo "<pre>" >> "$REPORT_FILE"
psql -h db.example.de -U postgres -c "
SELECT 
    usename, 
    usesuper, 
    usecreatedb, 
    userepl 
FROM pg_user;
" >> "$REPORT_FILE"
echo "</pre>" >> "$REPORT_FILE"

echo "</body></html>" >> "$REPORT_FILE"

# Report senden
echo "Compliance report generated: $REPORT_FILE" | \
    mail -s "BSI Grundschutz Compliance Report" -a "$REPORT_FILE" compliance@example.de
```

### 4.2 Monatliches Security Audit

```bash
#!/bin/bash
# monthly-security-audit.sh

# Lynis Audit
lynis audit system --cronjob

# Rootkit Check
rkhunter --check --skip-keypress --report-warnings-only

# ClamAV Scan
clamscan -r -i --exclude-dir="^/sys" / 2>&1 | \
    mail -s "ClamAV Scan Report $(hostname)" security@example.de

# AIDE Check
aide --check | mail -s "AIDE Integrity Check $(hostname)" security@example.de

# Failed Login Attempts
lastb | mail -s "Failed Login Attempts $(hostname)" security@example.de
```

## 5. Incident Response / Vorfallbehandlung

### 5.1 Incident Response Plan

**Incident Response Playbook**:
```markdown
# Security Incident Response

## Phase 1: Detection & Analysis
1. Incident identifiziert (SIEM, Monitoring, User Report)
2. Incident-Ticket erstellen
3. Severity-Level festlegen (Low/Medium/High/Critical)
4. IR-Team benachrichtigen

## Phase 2: Containment
1. Betroffene Systeme isolieren (Firewall-Rules)
2. Beweise sichern (Memory Dump, Logs, Disk Images)
3. Malware-Sample isolieren (falls vorhanden)
4. Temporäre Workarounds implementieren

## Phase 3: Eradication
1. Root Cause identifizieren
2. Malware/Backdoors entfernen
3. Schwachstellen patchen
4. Accounts zurücksetzen (falls kompromittiert)

## Phase 4: Recovery
1. Systeme aus sauberen Backups wiederherstellen
2. Monitoring intensivieren
3. Schrittweise Dienste wiederherstellen
4. Validierung durch Security-Team

## Phase 5: Post-Incident
1. Incident Report erstellen
2. Lessons Learned Workshop
3. Prozesse/Policies aktualisieren
4. Präventive Maßnahmen implementieren
```

### 5.2 Automated Incident Response

```python
#!/usr/bin/env python3
# auto-incident-response.py

import subprocess
import smtplib
from email.mime.text import MIMEText

class IncidentResponder:
    def __init__(self):
        self.blocked_ips = set()
        
    def block_ip(self, ip_address):
        """Block malicious IP"""
        if ip_address not in self.blocked_ips:
            subprocess.run([
                'firewall-cmd', 
                '--add-rich-rule',
                f'rule family="ipv4" source address="{ip_address}" reject'
            ])
            self.blocked_ips.add(ip_address)
            self.notify(f"Blocked IP: {ip_address}")
    
    def isolate_host(self, hostname):
        """Isolate compromised host"""
        subprocess.run([
            'ssh', hostname,
            'firewall-cmd', '--panic-on'
        ])
        self.notify(f"Isolated host: {hostname}")
    
    def notify(self, message):
        """Send notification"""
        msg = MIMEText(message)
        msg['Subject'] = 'Security Incident Alert'
        msg['From'] = 'security@example.de'
        msg['To'] = 'soc@example.de'
        
        s = smtplib.SMTP('localhost')
        s.send_message(msg)
        s.quit()

# Integration mit Wazuh
# Webhook für automatische Responses
```

## 6. Kontinuierliche Verbesserung / Continuous Improvement

### 6.1 Quartalsweise Security Reviews

```markdown
# Quartalsweise Review-Agenda

## Q1 Review
- [ ] Patch-Status aller Systeme
- [ ] Vulnerability-Scan-Ergebnisse
- [ ] Incident-Statistiken
- [ ] Backup-/DR-Test-Ergebnisse
- [ ] Compliance-Status (BSI Grundschutz)
- [ ] Performance-Metriken
- [ ] Kapazitätsplanung
- [ ] Security-Training-Status

## Outcomes
- Aktionsplan für Q2
- Budget-Anforderungen
- Policy-Updates
- Tool-Evaluierungen
```

## Nächste Schritte / Next Steps

- [BSI Grundschutz Mapping](../BSI_Grundschutz/Baustein_Mapping.md)
- [Checklists](../checklists/Post_Migration_Checklist.md)
- [Scripts and Templates](../scripts/)

## Referenzen / References

- BSI Grundschutz OPS.1.1.5: Datensicherung
- BSI Grundschutz DER.2.1: Behandlung von Sicherheitsvorfällen
- NIST SP 800-61: Computer Security Incident Handling Guide
