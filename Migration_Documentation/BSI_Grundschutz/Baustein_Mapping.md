# BSI Grundschutz Baustein-Mapping

## Übersicht / Overview

Diese Dokumentation mappt die Migrations- und Härtungsmaßnahmen auf die relevanten BSI Grundschutz-Bausteine für ein Landesamt in Baden-Württemberg.

## Anwendbare Bausteine / Applicable Modules

### Prozess-Bausteine (ISMS)

#### ISMS.1 Sicherheitsmanagement
**Anforderungen**:
- ISMS.1.A1 Übernahme der Gesamtverantwortung für Informationssicherheit durch die Leitungsebene
- ISMS.1.A2 Festlegung der Sicherheitsziele und -strategie
- ISMS.1.A3 Erstellung einer Leitlinie zur Informationssicherheit

**Umsetzung in der Migration**:
```markdown
✓ Dokumente:
  - IT-Sicherheitskonzept (siehe pre-migration/01_Planning_and_Assessment.md)
  - Sicherheitsleitlinie des Landesamts
  - Risikomanagement-Framework (siehe pre-migration/02_Risk_Assessment.md)

✓ Verantwortlichkeiten:
  - IT-Sicherheitsbeauftragter: Gesamtverantwortung
  - Projektleiter: Migrations-Sicherheit
  - Behördenleitung: Freigabe und Oversight
```

#### OPS.1.1.3 Patch- und Änderungsmanagement
**Anforderungen**:
- OPS.1.1.3.A1 Konzept für das Patch- und Änderungsmanagement
- OPS.1.1.3.A2 Festlegung verantwortlicher Personen
- OPS.1.1.3.A4 Planung von Änderungen
- OPS.1.1.3.A6 Einrichtung von Test- und Abnahmeumgebungen

**Umsetzung**:
```bash
# Patch Management konfiguriert
- Automatisches Security-Patching (dnf-automatic/unattended-upgrades)
- Test-Umgebung für Patch-Validierung
- Patch-Schedule: DEV → TEST → PROD mit Wartezeiten

# Change Management
- Change Request Tickets für alle Migrations-Phasen
- 4-Augen-Prinzip für kritische Änderungen
- Dokumentierte Rollback-Prozeduren

# Files:
- post-migration/01_Operations_and_Maintenance.md (Patch Management)
- during-migration/01_Migration_Execution.md (Change Process)
```

#### OPS.1.1.5 Datensicherung (Backup)
**Anforderungen**:
- OPS.1.1.5.A1 Erhebung der Einflussfaktoren der Datensicherung
- OPS.1.1.5.A2 Festlegung der Verfahrensweise für die Datensicherung
- OPS.1.1.5.A3 Ermittlung rechtlicher Einflussfaktoren auf die Datensicherung
- OPS.1.1.5.A7 Beschaffung geeigneter Datensicherungssysteme

**Umsetzung**:
```markdown
✓ Backup-Strategie:
  - 3-2-1 Regel implementiert
  - Tägliche Full-Backups
  - Stündliche Incremental Backups
  - Verschlüsselte Backups (AES-256)
  - Offsite-Backup-Storage
  - Quartalsweise DR-Tests

✓ Rechtliche Anforderungen:
  - DSGVO-konforme Backup-Aufbewahrung
  - LDSG BW Compliance
  - Aufbewahrungsfristen dokumentiert

# Files:
- post-migration/01_Operations_and_Maintenance.md (Backup Section)
- scripts/postgresql-backup.sh
```

#### CON.3 Datensicherungskonzept
**Anforderungen**:
- CON.3.A1 Erhebung der Einflussfaktoren der Datensicherung
- CON.3.A2 Festlegung der Verfahrensweise für die Datensicherung
- CON.3.A3 Ermittlung von rechtlichen Einflussfaktoren

**Umsetzung**: Siehe OPS.1.1.5

### System-Bausteine

#### SYS.1.1 Allgemeiner Server
**Anforderungen**:
- SYS.1.1.A1 Geeignete Aufstellung von Servern
- SYS.1.1.A2 Benutzerauthentisierung an Servern
- SYS.1.1.A3 Restriktive Rechtevergabe
- SYS.1.1.A5 Schutz der Administrationsoberflächen
- SYS.1.1.A8 Regelmäßige Datensicherung
- SYS.1.1.A9 Einsatz von Virenschutz-Programmen

**Umsetzung**:
```markdown
✓ SYS.1.1.A1: Physische Sicherheit
  - Server in Rechenzentrum mit Zugangskontrollen
  - Klimatisierung und USV
  - Brandschutz

✓ SYS.1.1.A2: Authentifizierung
  - Public-Key-Authentication für SSH
  - Multi-Faktor-Authentifizierung (Google Authenticator)
  - Keine Passwort-basierte SSH-Logins
  - Starke Passwort-Policies

✓ SYS.1.1.A3: Rechtevergabe
  - Least Privilege Prinzip
  - Sudo statt direktem Root-Zugang
  - SELinux/AppArmor Mandatory Access Control

✓ SYS.1.1.A5: Administration
  - SSH-Härtung (TLS 1.3, starke Ciphers)
  - Zugriff nur aus Management-Netzwerk
  - Jump-Server/Bastion-Host

✓ SYS.1.1.A8: Backup
  - Siehe OPS.1.1.5

✓ SYS.1.1.A9: Virenschutz
  - ClamAV installiert und konfiguriert
  - Tägliche Scans
  - Automatische Signature-Updates

# Files:
- pre-migration/04_Security_Baseline.md
```

#### SYS.1.3 Server unter Linux und Unix
**Anforderungen**:
- SYS.1.3.A1 Authentisierung von Administratoren und Benutzern
- SYS.1.3.A2 Sorgfältige Vergabe von IDs
- SYS.1.3.A3 Automatisches Einbinden von Wechseldatenträgern deaktivieren
- SYS.1.3.A4 Schutz der Anmeldeinformationen
- SYS.1.3.A5 Kein automatisches Einbinden von Wechseldatenträgern
- SYS.1.3.A6 Kein Anlegen von Benutzern mit UID 0
- SYS.1.3.A8 Verschlüsselter Zugriff über Secure Shell
- SYS.1.3.A11 Einsatz von Quotas
- SYS.1.3.A13 Einsatz von AppArmor oder SELinux

**Umsetzung**:
```bash
# SYS.1.3.A1: Authentifizierung
# /etc/ssh/sshd_config
PermitRootLogin no
PubkeyAuthentication yes
PasswordAuthentication no
ChallengeResponseAuthentication yes  # für MFA

# SYS.1.3.A2: UID-Vergabe
# Nur System-User mit UID < 1000
# Normale User ab UID 1000
# Keine zusätzlichen UIDs = 0

# SYS.1.3.A3: Automount deaktiviert
systemctl mask udisks2.service

# SYS.1.3.A4: Credential Protection
# /etc/login.defs
PASS_MAX_DAYS 90
PASS_MIN_DAYS 1
PASS_WARN_AGE 7
ENCRYPT_METHOD SHA512

# SYS.1.3.A8: SSH-Verschlüsselung
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# SYS.1.3.A11: Quotas
# /etc/fstab
/dev/mapper/vg-home /home ext4 defaults,usrquota,grpquota 0 2

# SYS.1.3.A13: SELinux/AppArmor
getenforce  # muss "Enforcing" sein
# oder
aa-status   # Profile müssen enforced sein

# Files:
- pre-migration/04_Security_Baseline.md (OS Hardening)
```

**Erweiterte Anforderungen (für erhöhten Schutzbedarf)**:
- SYS.1.3.A14 Verhinderung der Ausbreitung von Prozessen
- SYS.1.3.A15 Zusätzlicher Schutz von privilegierten Anmeldeinformationen
- SYS.1.3.A19 Festplattenverschlüsselung
- SYS.1.3.A22 Verhinderung des Ausspähens von Systemzuständen

**Umsetzung**:
```bash
# SYS.1.3.A14: Process Isolation
# Kernel Hardening in /etc/sysctl.d/99-security.conf
kernel.yama.ptrace_scope = 1
kernel.kptr_restrict = 2

# SYS.1.3.A15: Privileged Credentials
# Separate Accounts für Admin-Tätigkeiten
# Keine shared accounts

# SYS.1.3.A19: Disk Encryption
# LUKS full-disk encryption bei Installation
cryptsetup luksFormat /dev/sda2

# SYS.1.3.A22: System State Protection
kernel.dmesg_restrict = 1
kernel.perf_event_paranoid = 3
```

### Anwendungs-Bausteine

#### APP.4.3 Relationale Datenbanken (PostgreSQL)
**Anforderungen**:
- APP.4.3.A1 Erstellung einer Sicherheitsrichtlinie für Datenbanken
- APP.4.3.A2 Installation des DBMS
- APP.4.3.A3 Basishärtung des DBMS
- APP.4.3.A4 Geregeltes Anlegen neuer Datenbanken
- APP.4.3.A5 Benutzer- und Berechtigungskonzept
- APP.4.3.A7 Datensicherung eines DBMS
- APP.4.3.A11 Überwachung des DBMS

**Umsetzung**:
```sql
-- APP.4.3.A3: PostgreSQL Härtung
-- postgresql.conf

-- Netzwerk nur über TLS
ssl = on
ssl_cert_file = '/etc/ssl/certs/server.crt'
ssl_key_file = '/etc/ssl/private/server.key'
ssl_min_protocol_version = 'TLSv1.3'

-- Starke Passwörter
password_encryption = 'scram-sha-256'

-- Logging
log_connections = on
log_disconnections = on
log_duration = on
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_statement = 'ddl'

-- APP.4.3.A5: Berechtigungskonzept
-- Separate Rollen für verschiedene Anwendungen
CREATE ROLE app_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO app_readonly;

CREATE ROLE app_readwrite;
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO app_readwrite;

-- APP.4.3.A7: Backup
-- Siehe OPS.1.1.5 und postgresql-backup.sh

-- APP.4.3.A11: Monitoring
-- pg_stat_statements Extension
CREATE EXTENSION pg_stat_statements;

-- Prometheus Exporter
# postgres_exporter auf Port 9187

# Files:
- scripts/postgresql-security.sql
- post-migration/01_Operations_and_Maintenance.md (PostgreSQL Monitoring)
```

### Netzwerk-Bausteine

#### NET.1.1 Netzarchitektur und -design
**Anforderungen**:
- NET.1.1.A1 Sicherheitsrichtlinie für das Netz
- NET.1.1.A2 Dokumentation des Netzes
- NET.1.1.A3 Anforderungsspezifikation für das Netz
- NET.1.1.A4 Netztrennung in Sicherheitszonen

**Umsetzung**:
```markdown
✓ NET.1.1.A1-A3: Netzwerk-Dokumentation
  - Netzwerk-Topologie dokumentiert
  - Security Zones definiert (DMZ, Internal, Management)
  - Firewall-Regeln dokumentiert

✓ NET.1.1.A4: Security Zones
  - DMZ: Reverse Proxy, Bastion Host
  - Internal: Application Server, Datenbank
  - Management: Jump Server, Monitoring
  - Logging: SIEM, Log-Aggregation

# Files:
- pre-migration/01_Planning_and_Assessment.md (Network Architecture)
```

#### NET.3.2 Firewall
**Anforderungen**:
- NET.3.2.A1 Erstellung einer Sicherheitsrichtlinie
- NET.3.2.A2 Festlegung der Firewall-Regeln
- NET.3.2.A3 Einrichtung geeigneter Filterregeln
- NET.3.2.A9 Betriebsdokumenta tion
- NET.3.2.A11 Durchführung von Penetrationstests

**Umsetzung**:
```bash
# Firewalld-Konfiguration dokumentiert
# Default-Deny-Policy
firewall-cmd --set-default-zone=drop

# Whitelist-Ansatz für alle Regeln
# Siehe pre-migration/04_Security_Baseline.md (Firewall Section)

# Penetration Tests quartalsweise
# Files:
- pre-migration/04_Security_Baseline.md
- templates/Penetration_Test_Report.md
```

### Detektion und Reaktion

#### DER.1 Detektion von sicherheitsrelevanten Ereignissen
**Anforderungen**:
- DER.1.A1 Erstellung einer Sicherheitsrichtlinie zur Detektion
- DER.1.A2 Kontinuierliche Überwachung und Auswertung von Logging-Daten
- DER.1.A4 Einsatz von Detektionssystemen nach Schutzbedarfen

**Umsetzung**:
```markdown
✓ DER.1.A2: Logging und Monitoring
  - Zentralisiertes Logging (rsyslog zu SIEM)
  - Wazuh SIEM mit BSI-Regeln
  - 24/7 SOC (Security Operations Center)
  - Prometheus/Grafana Monitoring

✓ DER.1.A4: Detektionssysteme
  - HIDS: Wazuh, AIDE
  - NIDS: Suricata (optional)
  - Log-Analyse: ELK Stack
  - Anomalie-Detektion: Custom Rules

# Files:
- post-migration/01_Operations_and_Maintenance.md (Monitoring)
- BSI_Grundschutz/wazuh-bsi-rules.xml
```

#### DER.2.1 Behandlung von Sicherheitsvorfällen
**Anforderungen**:
- DER.2.1.A1 Definition eines Sicherheitsvorfalls
- DER.2.1.A2 Erstellung einer Richtlinie zur Behandlung von Sicherheitsvorfällen
- DER.2.1.A3 Festlegung von Verantwortlichkeiten
- DER.2.1.A4 Etablierung von Meldewegen für Sicherheitsvorfälle
- DER.2.1.A5 Einrichtung einer zentralen Anlaufstelle

**Umsetzung**:
```markdown
✓ Incident Response Plan etabliert
  - Incident-Kategorisierung: Low/Medium/High/Critical
  - Eskalations-Pfade definiert
  - IR-Team: 24/7 Bereitschaft
  - Meldepflichten (z.B. BSI, LfDI BW)

✓ Incident Response Workflow
  1. Detection & Analysis
  2. Containment
  3. Eradication
  4. Recovery
  5. Post-Incident Review

# Files:
- post-migration/01_Operations_and_Maintenance.md (Incident Response)
- templates/Incident_Response_Playbook.md
```

## Compliance-Matrix / Konformitäts-Matrix

| BSI Baustein | Anforderung | Status | Dokumentation | Verantwortlich |
|--------------|-------------|--------|---------------|----------------|
| SYS.1.3 | A1-A13 (Basis) | ✅ Implementiert | pre-migration/04_Security_Baseline.md | Sys-Admin |
| SYS.1.3 | A14-A22 (Erhöht) | ✅ Implementiert | pre-migration/04_Security_Baseline.md | Sys-Admin |
| APP.4.3 | A1-A11 (Basis) | ✅ Implementiert | scripts/postgresql-security.sql | DB-Admin |
| OPS.1.1.3 | A1-A6 (Basis) | ✅ Implementiert | post-migration/01_Operations_and_Maintenance.md | Patch-Mgmt |
| OPS.1.1.5 | A1-A7 (Basis) | ✅ Implementiert | post-migration/01_Operations_and_Maintenance.md | Backup-Admin |
| NET.3.2 | A1-A11 (Basis) | ✅ Implementiert | pre-migration/04_Security_Baseline.md | Network-Admin |
| DER.1 | A1-A4 (Basis) | ✅ Implementiert | post-migration/01_Operations_and_Maintenance.md | Security-Team |
| DER.2.1 | A1-A5 (Basis) | ✅ Implementiert | templates/Incident_Response_Playbook.md | IR-Team |

## Nachweise / Evidence

Für BSI-Audits erforderliche Nachweise:

### Dokumentations-Nachweise
- [ ] IT-Sicherheitskonzept
- [ ] Risikoanalyse-Dokumentation
- [ ] Datenschutz-Folgenabschätzung (DSFA)
- [ ] Netzwerk-Topologie-Diagramme
- [ ] Backup-Konzept
- [ ] Patch-Management-Prozess
- [ ] Incident-Response-Plan
- [ ] Betriebshandbuch

### Technische Nachweise
- [ ] OpenSCAP Scan-Reports
- [ ] Lynis Audit-Reports
- [ ] Penetration-Test-Reports
- [ ] Backup-Restore-Test-Protokolle
- [ ] Audit-Logs (auditd)
- [ ] SIEM-Reports (Wazuh)
- [ ] Vulnerability-Scan-Reports

### Prozess-Nachweise
- [ ] Change-Tickets für alle Änderungen
- [ ] Incident-Tickets und Post-Mortems
- [ ] Schulungsnachweise für Team
- [ ] Unterschriften auf kritischen Dokumenten
- [ ] Review-Protokolle

## Audit-Vorbereitung / Audit Preparation

```bash
#!/bin/bash
# prepare-bsi-audit.sh

AUDIT_DIR="/var/audit-evidence/$(date +%Y%m%d)"
mkdir -p "$AUDIT_DIR"

# Technische Nachweise sammeln
oscap xccdf eval --profile bsi /usr/share/xml/scap/ssg/content/ssg-*.ds.xml \
    --results "$AUDIT_DIR/oscap-results.xml" \
    --report "$AUDIT_DIR/oscap-report.html"

lynis audit system --quick > "$AUDIT_DIR/lynis-report.txt"

# Konfigurationsdateien
cp /etc/ssh/sshd_config "$AUDIT_DIR/"
cp /etc/sysctl.d/99-security.conf "$AUDIT_DIR/"
cp /etc/audit/rules.d/99-security.rules "$AUDIT_DIR/"

# Logs
journalctl -u auditd --since "30 days ago" > "$AUDIT_DIR/audit-logs.txt"

# Backup-Status
find /backup -type f -mtime -30 > "$AUDIT_DIR/backup-files.txt"

# Patch-Status
dnf updateinfo list security > "$AUDIT_DIR/security-patches.txt"

# Archive erstellen
tar czf "/var/audit-evidence/bsi-audit-$(date +%Y%m%d).tar.gz" "$AUDIT_DIR"
```

## Referenzen / References

- [BSI Grundschutz-Kompendium](https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/IT-Grundschutz/IT-Grundschutz-Kompendium/it-grundschutz-kompendium_node.html)
- [BSI IT-Grundschutz-Profile für Linux](https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/IT-Grundschutz/IT-Grundschutz-Kataloge/IT-Grundschutz-Profile/it-grundschutz-profile_node.html)
- [LfDI Baden-Württemberg](https://www.baden-wuerttemberg.datenschutz.de/)
