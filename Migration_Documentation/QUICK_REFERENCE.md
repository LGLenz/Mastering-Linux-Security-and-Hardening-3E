# Quick Reference Guide - Mainframe to Linux Migration

## Schnellstart / Quick Start

Diese Quick Reference Guide bietet einen Überblick über die wichtigsten Dokumente und Schritte für die Migration von Großrechner-Systemen (Adabas) zu gehärteten Linux-Servern gemäß BSI Grundschutz.

---

## 📚 Dokumentations-Übersicht

### 1. Einstiegspunkt
- **[README.md](./README.md)** - Haupteinstieg in die Dokumentation

### 2. Vor der Migration (Pre-Migration)
1. **[Voraussetzungen](./pre-migration/00_Prerequisites.md)**
   - Team, Rollen, Schulungen
   - Hardware, Software, Budget
   - Behördliche Anforderungen
   
2. **[Planung und Assessment](./pre-migration/01_Planning_and_Assessment.md)**
   - Legacy-System-Analyse
   - Zielarchitektur
   - Migrationsstrategien
   - Zeitplan
   
3. **[Risikoanalyse](./pre-migration/02_Risk_Assessment.md)**
   - BSI Grundschutz Gefährdungen
   - Migrationsrisiken
   - Maßnahmenplan
   
4. **[Security Baseline](./pre-migration/04_Security_Baseline.md)**
   - OS-Härtung
   - SELinux/AppArmor
   - Firewall
   - Monitoring und Logging

### 3. Während der Migration (During Migration)
1. **[Migration Execution](./during-migration/01_Migration_Execution.md)**
   - Phasenweise Migration
   - Datenexport/-import
   - Validierung
   - Rollback-Prozeduren

### 4. Nach der Migration (Post-Migration)
1. **[Operations & Maintenance](./post-migration/01_Operations_and_Maintenance.md)**
   - Monitoring (Prometheus, Grafana, Wazuh)
   - Patch Management
   - Backup & Disaster Recovery
   - Incident Response

### 5. BSI Grundschutz
1. **[Baustein-Mapping](./BSI_Grundschutz/Baustein_Mapping.md)**
   - Alle relevanten BSI-Bausteine
   - Compliance-Matrix
   - Audit-Vorbereitung

### 6. Praktische Hilfsmittel
1. **[Pre-Migration Checklist](./checklists/Pre_Migration_Checklist.md)**
   - Vollständige Checkliste vor Migration
   
2. **[Hardening-Script](./scripts/linux-server-hardening.sh)**
   - Automatisierte Server-Härtung
   
3. **[Projektplan-Template](./templates/Migration_Project_Plan.md)**
   - Vorlage für Projektplanung

---

## 🚀 Workflow in 5 Schritten

### Schritt 1: Vorbereitung (2-4 Monate)
```bash
# Checkliste durchgehen
cat checklists/Pre_Migration_Checklist.md

# Dokumentation lesen
- pre-migration/00_Prerequisites.md
- pre-migration/01_Planning_and_Assessment.md
- pre-migration/02_Risk_Assessment.md
```

**Ergebnis**: 
- ✅ Team aufgebaut
- ✅ Freigaben erhalten
- ✅ Risikoanalyse durchgeführt
- ✅ Hardware beschafft

### Schritt 2: Linux-Server-Setup (1-2 Monate)
```bash
# Server installieren (Ubuntu/RHEL)
# Danach: Härten
sudo ./scripts/linux-server-hardening.sh

# Security Baseline etablieren
# Siehe: pre-migration/04_Security_Baseline.md
```

**Ergebnis**:
- ✅ Gehärtete Linux-Server
- ✅ PostgreSQL installiert
- ✅ Monitoring aktiv
- ✅ Firewall konfiguriert

### Schritt 3: Test-Migration (2-3 Monate)
```bash
# Daten exportieren (Adabas)
# Daten importieren (PostgreSQL)
# Validierung durchführen

# Siehe: during-migration/01_Migration_Execution.md
```

**Ergebnis**:
- ✅ Testmigration erfolgreich
- ✅ Daten validiert
- ✅ Performance getestet

### Schritt 4: Security & Compliance (1 Monat)
```bash
# Vulnerability Scan
oscap xccdf eval --profile bsi ...

# Lynis Audit
lynis audit system

# Penetration Test (extern)
# BSI Compliance Check

# Siehe: BSI_Grundschutz/Baustein_Mapping.md
```

**Ergebnis**:
- ✅ Keine kritischen Vulnerabilities
- ✅ BSI-Compliance nachgewiesen
- ✅ Security-Freigabe erhalten

### Schritt 5: Produktiv-Migration (1-2 Monate)
```bash
# Go-Live durchführen
# Siehe: during-migration/01_Migration_Execution.md

# Post-Migration:
# Monitoring, Patches, Backups
# Siehe: post-migration/01_Operations_and_Maintenance.md
```

**Ergebnis**:
- ✅ Produktiv-System läuft
- ✅ Legacy-System abgeschaltet
- ✅ Betrieb etabliert

---

## 📋 Wichtigste Checklisten

### Vor Migrations-Start
- [ ] Alle Freigaben erhalten (IT-Sec, Datenschutz, Management)
- [ ] Team vollständig und geschult
- [ ] Hardware beschafft und installiert
- [ ] Test-Umgebung aufgebaut
- [ ] Backup-Strategie getestet
- [ ] Rollback-Plan dokumentiert

### Vor Go-Live
- [ ] Test-Migration erfolgreich
- [ ] Security-Scans ohne kritische Findings
- [ ] Performance-Tests bestanden
- [ ] BSI-Compliance nachgewiesen
- [ ] UAT abgeschlossen
- [ ] Wartungsfenster bestätigt

---

## 🛡️ BSI Grundschutz - Wichtigste Bausteine

| Baustein | Titel | Dokument |
|----------|-------|----------|
| **SYS.1.1** | Allgemeiner Server | [Security Baseline](./pre-migration/04_Security_Baseline.md) |
| **SYS.1.3** | Server unter Linux | [Security Baseline](./pre-migration/04_Security_Baseline.md) |
| **APP.4.3** | Relationale Datenbanken | [BSI Mapping](./BSI_Grundschutz/Baustein_Mapping.md) |
| **OPS.1.1.3** | Patch-Management | [Operations](./post-migration/01_Operations_and_Maintenance.md) |
| **OPS.1.1.5** | Datensicherung | [Operations](./post-migration/01_Operations_and_Maintenance.md) |
| **NET.3.2** | Firewall | [Security Baseline](./pre-migration/04_Security_Baseline.md) |
| **DER.1** | Detektion | [Operations](./post-migration/01_Operations_and_Maintenance.md) |
| **DER.2.1** | Incident Response | [Operations](./post-migration/01_Operations_and_Maintenance.md) |

**Vollständige Übersicht**: [BSI_Grundschutz/Baustein_Mapping.md](./BSI_Grundschutz/Baustein_Mapping.md)

---

## 🔧 Wichtigste Tools

### Security
- **OpenSCAP**: BSI-Profile scannen
- **Lynis**: Security-Audit
- **AIDE**: File Integrity Monitoring
- **ClamAV**: Antivirus
- **fail2ban**: Brute-Force-Schutz

### Monitoring
- **Prometheus**: Metriken
- **Grafana**: Dashboards
- **Wazuh**: SIEM
- **Auditd**: System-Auditing

### Backup
- **pg_basebackup**: PostgreSQL-Backup
- **rsync**: File-Backup
- **LUKS**: Disk-Verschlüsselung

---

## 📞 Support und Kontakte

### Interne Ansprechpartner
- **IT-Sicherheitsbeauftragter**: [Name], [E-Mail]
- **Datenschutzbeauftragter**: [Name], [E-Mail]
- **Projekt-Hotline**: [Telefon]

### Externe Ressourcen
- **BSI**: https://www.bsi.bund.de
- **LfDI Baden-Württemberg**: https://www.baden-wuerttemberg.datenschutz.de/
- **Project Issues**: https://github.com/LGLenz/Mastering-Linux-Security-and-Hardening-3E/issues

---

## 🎯 Erfolgs-Kriterien

Nach erfolgreicher Migration:
- ✅ Alle Daten vollständig und korrekt migriert
- ✅ Performance mindestens wie Legacy-System
- ✅ Keine kritischen Security-Issues
- ✅ BSI Grundschutz-konform
- ✅ DSGVO/LDSG BW-konform
- ✅ Team geschult und betriebsbereit
- ✅ Monitoring und Alerting funktionieren
- ✅ Backup und DR getestet

---

## 📖 Weiterführende Dokumentation

### Externe Referenzen
- [BSI Grundschutz-Kompendium](https://www.bsi.bund.de/DE/Themen/Unternehmen-und-Organisationen/Standards-und-Zertifizierung/IT-Grundschutz/IT-Grundschutz-Kompendium/it-grundschutz-kompendium_node.html)
- [CIS Benchmarks for Linux](https://www.cisecurity.org/cis-benchmarks/)
- [DISA STIG for RHEL](https://public.cyber.mil/stigs/)
- [PostgreSQL Security Best Practices](https://www.postgresql.org/docs/current/security.html)

### Buchempfehlungen
- Mastering Linux Security and Hardening (3rd Edition)
- Linux Firewalls
- PostgreSQL High Performance

---

## ⚠️ Wichtige Hinweise

1. **Backups**: Immer vor kritischen Änderungen Backup erstellen!
2. **Test-Umgebung**: Alle Änderungen erst in Test-Umgebung testen
3. **Rollback**: Rollback-Plan immer bereit haben
4. **Dokumentation**: Alle Änderungen dokumentieren
5. **Security**: Security-First-Ansatz in allen Phasen
6. **Compliance**: BSI Grundschutz und DSGVO/LDSG BW beachten

---

**Version**: 1.0.0  
**Letzte Aktualisierung**: 2026-02-07  
**Maintainer**: Migration Team
