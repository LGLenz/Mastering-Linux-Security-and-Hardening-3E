# Voraussetzungen für die Migration / Prerequisites for Migration

## Übersicht / Overview

Bevor mit der Migration von Großrechner-Systemen (z.B. Adabas) zu Linux-Servern begonnen werden kann, müssen bestimmte Voraussetzungen erfüllt sein.

## Technische Voraussetzungen / Technical Prerequisites

### Hardware-Anforderungen / Hardware Requirements

#### Ziel-Linux-Server / Target Linux Server
- **CPU**: Minimum 8 Cores (empfohlen: 16+ Cores)
- **RAM**: Minimum 32 GB (empfohlen: 64+ GB)
- **Storage**: 
  - System: Minimum 500 GB SSD
  - Daten: Abhängig von Legacy-System (empfohlen: RAID 10)
  - Backup: 3x Datengröße
- **Netzwerk**: Redundante Gigabit-Ethernet (empfohlen: 10 GbE)

#### Backup-Infrastruktur
- Dedizierte Backup-Server
- Offline-Backup-Speicher
- Verschlüsselte Backup-Medien

### Software-Anforderungen / Software Requirements

#### Linux-Distribution
- **Empfohlen**: 
  - Red Hat Enterprise Linux (RHEL) 8/9
  - Ubuntu Server 22.04 LTS
  - SUSE Linux Enterprise Server (SLES) 15
  
- **Mindestanforderungen**:
  - Kernel Version: 5.15+
  - systemd-basiert
  - SELinux/AppArmor-Unterstützung
  - FIPS 140-2 zertifizierte Kryptographie

#### Datenbank-Migration (für Adabas)
- PostgreSQL 14+ (empfohlen für Adabas-Migration)
- MySQL/MariaDB 10.6+ (alternativ)
- Datenbank-Migrationswerkzeuge:
  - pgloader
  - AWS Database Migration Service
  - Software AG's Natural/Adabas Bridge

#### Sicherheits-Tools
- **Mandatory**:
  - OpenSCAP / SCAP Security Guide
  - Lynis Security Auditing Tool
  - AIDE (Advanced Intrusion Detection Environment)
  - rkhunter (Rootkit Hunter)
  - ClamAV (Antivirus)
  
- **Optional aber empfohlen**:
  - Wazuh (SIEM)
  - Suricata/Snort (IDS/IPS)
  - Tripwire
  - OSSEC

## Organisatorische Voraussetzungen / Organizational Prerequisites

### Team und Rollen / Team and Roles

#### Pflicht-Rollen / Mandatory Roles
1. **Projektleiter** (Project Manager)
   - Gesamtverantwortung für Migration
   - Stakeholder-Management
   
2. **IT-Sicherheitsbeauftragter** (IT Security Officer)
   - BSI Grundschutz-Compliance
   - Sicherheitskonzept und -freigabe
   
3. **System-Architekt** (System Architect)
   - Technische Architektur
   - Systemdesign und -integration
   
4. **Datenschutzbeauftragter** (Data Protection Officer)
   - DSGVO/LDSG-Compliance
   - Datenschutz-Folgenabschätzung
   
5. **Linux-Systemadministratoren** (2-3 Personen)
   - Systeminstallation und -konfiguration
   - Security Hardening
   
6. **Datenbank-Administrator**
   - Datenbank-Migration
   - Datenintegrität
   
7. **Anwendungsentwickler** (falls Anpassungen nötig)
   - Anwendungs-Migration/-Anpassung
   - Testing

#### Optional-Rollen / Optional Roles
- Change-Manager
- Qualitätssicherung/Testing-Team
- Netzwerk-Administrator
- BSI-zertifizierter Berater

### Schulungen / Training

Alle Teammitglieder müssen folgende Schulungen absolvieren:

1. **BSI Grundschutz-Schulung** (Pflicht für alle)
   - BSI-Baustein-Verständnis
   - Risikoanalyse-Methodik
   
2. **Linux Security Hardening** (für Admins)
   - SELinux/AppArmor
   - Firewall-Konfiguration
   - Audit-Logging
   
3. **Datenschutz-Schulung** (Pflicht für alle)
   - DSGVO/LDSG BW
   - Datenschutz-Grundlagen
   
4. **Adabas/Legacy-System-Schulung** (für relevante Teammitglieder)
   - Legacy-System-Verständnis
   - Datenstrukturen

### Budget und Ressourcen / Budget and Resources

#### Kostenplanung / Cost Planning
- Hardware-Kosten (Server, Storage, Netzwerk)
- Software-Lizenzen (RHEL, kommerzielle Tools)
- Externe Berater (BSI-Zertifizierte, falls nötig)
- Schulungskosten
- Betriebskosten für Paralleltest-Zeitraum

#### Zeitplanung / Time Planning
- **Planungsphase**: 2-3 Monate
- **Vorbereitungsphase**: 2-4 Monate
- **Migrationsphase**: 3-6 Monate (abhängig von Komplexität)
- **Stabilisierungsphase**: 2-3 Monate
- **Gesamt**: 9-16 Monate

## Behördliche Anforderungen / Government Requirements

### Freigaben und Genehmigungen / Approvals and Permissions

1. **IT-Sicherheitsfreigabe**
   - IT-Sicherheitsbeauftragter
   - Behördenleitung
   
2. **Datenschutz-Freigabe**
   - Datenschutzbeauftragter
   - Datenschutz-Folgenabschätzung (DSFA)
   
3. **Budget-Freigabe**
   - Finanzabteilung
   - Behördenleitung
   
4. **Change-Management-Freigabe**
   - Change Advisory Board (falls vorhanden)

### Dokumentationspflichten / Documentation Requirements

1. **IT-Sicherheitskonzept** (nach BSI Grundschutz)
2. **Datenschutz-Folgenabschätzung** (DSFA)
3. **Risikoanalyse-Dokumentation**
4. **Migrationsplan**
5. **Notfallplan / Rollback-Plan**
6. **Test- und Validierungsplan**
7. **Betriebshandbuch**

## Technische Vorbereitungen / Technical Preparations

### Inventarisierung / Inventory

1. **Legacy-System-Inventar**
   ```bash
   # Dokumentieren Sie:
   - Alle Anwendungen auf dem Großrechner
   - Datenbank-Strukturen und -Größen
   - Schnittstellen zu anderen Systemen
   - Batch-Jobs und Cronjobs
   - Benutzer und Berechtigungen
   - Netzwerk-Verbindungen
   ```

2. **Datenanalyse**
   - Datenvolumen
   - Datentypen und -strukturen
   - Abhängigkeiten
   - Historische Daten (Aufbewahrungspflichten)

3. **Netzwerk-Topologie**
   - Aktuelle Netzwerkstruktur
   - Firewall-Regeln
   - VPN-Verbindungen
   - Load Balancer

### Test-Umgebung / Test Environment

Vor der eigentlichen Migration muss eine vollständige Test-Umgebung aufgebaut werden:

1. **Entwicklungs-/Test-Linux-Server**
   - Identische Konfiguration wie Produktiv-System
   - Isoliertes Netzwerk
   
2. **Test-Daten**
   - Anonymisierte Produktiv-Daten
   - Synthetische Test-Daten
   
3. **Test-Skripte**
   - Funktionale Tests
   - Performance-Tests
   - Sicherheits-Tests

## Checkliste / Checklist

### Vor Beginn der Migration / Before Starting Migration

- [ ] **Hardware beschafft und installiert**
- [ ] **Linux-Distribution ausgewählt und installiert**
- [ ] **Team zusammengestellt und Rollen definiert**
- [ ] **Alle Schulungen absolviert**
- [ ] **Budget genehmigt**
- [ ] **Zeitplan erstellt und genehmigt**
- [ ] **IT-Sicherheitskonzept erstellt**
- [ ] **Datenschutz-Folgenabschätzung durchgeführt**
- [ ] **Risikoanalyse durchgeführt**
- [ ] **Alle behördlichen Freigaben eingeholt**
- [ ] **Legacy-System inventarisiert**
- [ ] **Test-Umgebung aufgebaut**
- [ ] **Backup-Strategie definiert**
- [ ] **Notfall-/Rollback-Plan erstellt**
- [ ] **Kommunikationsplan erstellt (Stakeholder)**

## Nächste Schritte / Next Steps

Nach Erfüllung aller Voraussetzungen:
1. [Planungs- und Assessment-Phase](./01_Planning_and_Assessment.md)
2. [Risikoanalyse](./02_Risk_Assessment.md)
3. [Migrationsplanung](./03_Migration_Planning.md)

## Referenzen / References

- BSI Grundschutz-Baustein SYS.1.3: Server unter Linux und Unix
- BSI Grundschutz-Baustein OPS.1.1.3: Patch- und Änderungsmanagement
- LDSG Baden-Württemberg
- IT-Sicherheitsrichtlinien Baden-Württemberg
