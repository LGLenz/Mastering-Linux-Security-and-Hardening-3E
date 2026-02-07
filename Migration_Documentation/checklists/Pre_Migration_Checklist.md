# Pre-Migration Checklist / Vor-Migrations-Checkliste

## Executive Summary

Diese Checkliste stellt sicher, dass alle Voraussetzungen für eine sichere Migration von Großrechner-Systemen (Adabas) zu Linux-Servern erfüllt sind, gemäß BSI Grundschutz-Anforderungen.

**Projekt**: ____________________  
**Datum**: ____________________  
**Verantwortlich**: ____________________  
**Unterschrift IT-Sicherheitsbeauftragter**: ____________________  

---

## 1. Organisatorische Voraussetzungen

### 1.1 Team und Rollen
- [ ] **Projektleiter** benannt und verfügbar
- [ ] **IT-Sicherheitsbeauftragter** involviert
- [ ] **Datenschutzbeauftragter** konsultiert
- [ ] **System-Architekt** im Team
- [ ] **Linux-Systemadministratoren** (min. 2) verfügbar
- [ ] **Datenbank-Administrator** verfügbar
- [ ] **Backup-/Storage-Admin** verfügbar
- [ ] **Netzwerk-Administrator** verfügbar
- [ ] **Change-Manager** (falls erforderlich)
- [ ] Externe Berater (falls erforderlich) beauftragt

**Kommentare**: ____________________

### 1.2 Schulungen und Qualifikationen
- [ ] BSI Grundschutz-Schulung absolviert (alle Team-Mitglieder)
- [ ] Linux Security Hardening Training (Admins)
- [ ] SELinux/AppArmor Training (Admins)
- [ ] PostgreSQL Administration Training (DB-Admin)
- [ ] Datenschutz-Schulung DSGVO/LDSG BW (alle)
- [ ] Adabas/Natural Kenntnisse vorhanden
- [ ] Incident Response Training (Security-Team)

**Kommentare**: ____________________

### 1.3 Freigaben und Genehmigungen
- [ ] **Budget-Freigabe** erhalten (Unterschrift: ____)
- [ ] **IT-Sicherheitsfreigabe** erhalten (Unterschrift: ____)
- [ ] **Datenschutz-Freigabe** erhalten (Unterschrift: ____)
- [ ] **Behördenleitung** informiert und freigegeben
- [ ] **Change-Advisory-Board** (CAB) Freigabe (falls erforderlich)
- [ ] **Betriebsrat** informiert (falls Personaländerungen)

**Kommentare**: ____________________

### 1.4 Dokumentation
- [ ] **IT-Sicherheitskonzept** erstellt und genehmigt
- [ ] **Datenschutz-Folgenabschätzung** (DSFA) durchgeführt
- [ ] **Risikoanalyse** dokumentiert
- [ ] **Migrationsplan** erstellt
- [ ] **Notfall-/Rollback-Plan** dokumentiert
- [ ] **Test- und Validierungsplan** erstellt
- [ ] **Betriebshandbuch** vorbereitet
- [ ] **Kommunikationsplan** erstellt (Stakeholder)

**Kommentare**: ____________________

---

## 2. Technische Voraussetzungen

### 2.1 Hardware-Beschaffung
- [ ] **Produktions-Server** beschafft und geliefert
  - Anzahl: ____
  - Modell: ____________________
  - CPU: ____ Cores
  - RAM: ____ GB
  - Storage: ____ TB
- [ ] **Test-/Dev-Server** beschafft
- [ ] **Backup-Server** beschafft
- [ ] **Netzwerk-Equipment** (Switches, Router)
- [ ] **Storage-System** (SAN/NAS)
- [ ] **USV** (Unterbrechungsfreie Stromversorgung)
- [ ] **Hardware-Wartungsverträge** abgeschlossen

**Kommentare**: ____________________

### 2.2 Software-Lizenzen
- [ ] **Linux-Distribution** Lizenzen
  - Distribution: ____________________
  - Version: ____________________
  - Support-Level: ____________________
- [ ] **PostgreSQL** (Enterprise Edition, falls kommerziell)
- [ ] **Monitoring-Tools** (Prometheus, Grafana, Wazuh)
- [ ] **Backup-Software** Lizenzen
- [ ] **Security-Tools** Lizenzen (falls kommerziell)
- [ ] **Migrations-Tools** Lizenzen (Software AG Tools, etc.)

**Kommentare**: ____________________

### 2.3 Netzwerk-Vorbereitung
- [ ] **IP-Adressen** allokiert
  - Produktions-Server: ____________________
  - Test-Server: ____________________
  - Management-Interface: ____________________
- [ ] **DNS-Einträge** vorbereitet (nicht aktiviert)
- [ ] **Firewall-Regeln** dokumentiert (nicht aktiviert)
- [ ] **VLAN-Konfiguration** geplant
  - Management VLAN: ____
  - Produktions-VLAN: ____
  - DMZ VLAN: ____
- [ ] **Load-Balancer** konfiguriert (falls erforderlich)
- [ ] **VPN-Zugang** für Remote-Team (falls erforderlich)
- [ ] **Netzwerk-Monitoring** vorbereitet

**Kommentare**: ____________________

### 2.4 Zertifikate und Kryptographie
- [ ] **SSL/TLS-Zertifikate** beschafft
  - Zertifikats-Typ: ____________________ (Let's Encrypt, Commercial CA)
  - Gültigkeitsdauer: ____________________
- [ ] **Interne CA** aufgesetzt (falls erforderlich)
- [ ] **SSH-Keys** generiert für alle Admins
- [ ] **GPG-Keys** für Paket-Signatur-Verifikation
- [ ] **Verschlüsselungs-Keys** für Backups generiert
- [ ] **Key-Management-System** (KMS) konfiguriert

**Kommentare**: ____________________

---

## 3. Legacy-System-Analyse

### 3.1 Adabas-System-Inventar
- [ ] **Adabas-Version** dokumentiert: ____________________
- [ ] **Anzahl der Datenbanken**: ____
- [ ] **Gesamtgröße der Daten**: ____ GB/TB
- [ ] **Anzahl der Files**: ____
- [ ] **Records gesamt**: ____ Millionen
- [ ] **Performance-Baseline** gemessen
  - Durchschn. Response Time: ____ ms
  - Transactions/Sekunde: ____
  - Batch-Laufzeiten: ____________________
- [ ] **Backup-Größe und -Dauer**: ____________________

**Kommentare**: ____________________

### 3.2 Anwendungs-Inventar
- [ ] **Natural-Programme** inventarisiert
  - Anzahl: ____
  - Zeilen Code: ____
  - Kritikalität bewertet: ____________________
- [ ] **COBOL-Programme** inventarisiert (falls vorhanden)
- [ ] **Batch-Jobs** dokumentiert
  - Anzahl: ____
  - Kritische Jobs identifiziert: ____________________
- [ ] **Schnittstellen** zu anderen Systemen dokumentiert
  - Anzahl: ____
  - Protokolle: ____________________
- [ ] **Benutzer und Berechtigungen** exportiert

**Kommentare**: ____________________

### 3.3 Daten-Analyse
- [ ] **Datenstrukturen** analysiert (DDMs, FDTs)
- [ ] **Periodische Gruppen** (PE) identifiziert
- [ ] **Multiple-Value Fields** (MU) identifiziert
- [ ] **Descriptors** und **Super-Descriptors** dokumentiert
- [ ] **Referentielle Integrität** analysiert
- [ ] **Datenqualität** geprüft
  - NULL-Werte: ____________________
  - Duplikate: ____________________
  - Inkonsistenzen: ____________________
- [ ] **Aufbewahrungsfristen** dokumentiert (rechtlich)

**Kommentare**: ____________________

---

## 4. Ziel-Linux-System-Vorbereitung

### 4.1 Linux-Installation
- [ ] **Distribution installiert**: ____________________
- [ ] **Kernel-Version**: ____________________
- [ ] **Minimale Installation** durchgeführt (keine unnötigen Pakete)
- [ ] **System-Updates** eingespielt
- [ ] **Partitionierung** gemäß Best Practices:
  - [ ] `/boot` separate Partition
  - [ ] `/home` separate Partition
  - [ ] `/var` separate Partition
  - [ ] `/tmp` separate Partition (noexec)
- [ ] **Disk-Verschlüsselung** (LUKS) aktiviert

**Kommentare**: ____________________

### 4.2 Security-Baseline
- [ ] **SELinux/AppArmor** aktiviert und in Enforcing-Mode
  - Typ: ____________________ (SELinux/AppArmor)
  - Mode: ____________________ (Enforcing/Complain)
- [ ] **Firewall** konfiguriert (firewalld/UFW)
  - Default-Policy: ____________________ (Drop/Reject)
- [ ] **SSH-Härtung** implementiert:
  - [ ] PermitRootLogin no
  - [ ] PasswordAuthentication no
  - [ ] PubkeyAuthentication yes
  - [ ] Multi-Faktor-Authentifizierung (MFA)
  - [ ] Starke Ciphers konfiguriert
- [ ] **Kernel-Härtung** (sysctl.conf):
  - [ ] IP Forwarding deaktiviert
  - [ ] SYN Cookies aktiviert
  - [ ] ICMP Redirects deaktiviert
  - [ ] ASLR aktiviert
- [ ] **Passwort-Policies** konfiguriert:
  - [ ] Minimale Länge: ____ Zeichen
  - [ ] Komplexität: ____________________
  - [ ] Passwort-Aging: ____ Tage
- [ ] **Sudo** konfiguriert (kein direkter Root-Login)
- [ ] **fail2ban** oder **faillock** konfiguriert

**Kommentare**: ____________________

### 4.3 Monitoring und Logging
- [ ] **Auditd** installiert und konfiguriert
- [ ] **Rsyslog** konfiguriert (zentrale Log-Sammlung)
- [ ] **Log-Rotation** konfiguriert
- [ ] **SIEM** (Wazuh) Agent installiert
- [ ] **Prometheus Node-Exporter** installiert
- [ ] **AIDE** (File Integrity Monitoring) initialisiert
- [ ] **Rootkit-Hunter** installiert
- [ ] **ClamAV** (Antivirus) installiert

**Kommentare**: ____________________

### 4.4 PostgreSQL-Installation
- [ ] **PostgreSQL** installiert
  - Version: ____________________
- [ ] **PostgreSQL** gehärtet:
  - [ ] SSL/TLS aktiviert
  - [ ] Listen nur auf internem Interface
  - [ ] Strong Authentication (scram-sha-256)
  - [ ] Logging konfiguriert
- [ ] **PostgreSQL-Cluster** aufgebaut (falls HA erforderlich)
  - Primary: ____________________
  - Standby: ____________________
  - Replication: ____________________ (Streaming/Logical)
- [ ] **Performance-Tuning** durchgeführt:
  - [ ] shared_buffers: ____________________
  - [ ] work_mem: ____________________
  - [ ] maintenance_work_mem: ____________________
- [ ] **pg_stat_statements** Extension aktiviert
- [ ] **Postgres Exporter** für Prometheus installiert

**Kommentare**: ____________________

---

## 5. Test-Umgebung

### 5.1 Test-Infrastruktur
- [ ] **Test-Server** identisch zu Produktions-Servern konfiguriert
- [ ] **Test-Datenbank** mit anonymisierten Produktiv-Daten geladen
- [ ] **Test-Netzwerk** isoliert vom Produktiv-Netzwerk
- [ ] **Migrations-Tools** auf Test-Umgebung installiert
- [ ] **Test-Skripte** entwickelt:
  - [ ] Funktionale Tests
  - [ ] Performance-Tests
  - [ ] Security-Tests
  - [ ] Integration-Tests
- [ ] **Automatisierung** für Tests (CI/CD, Ansible)

**Kommentare**: ____________________

### 5.2 Test-Durchführung
- [ ] **Migrations-Test** durchgeführt (Dry-Run)
- [ ] **Daten-Validierung** erfolgreich
- [ ] **Performance-Test** durchgeführt und Baseline erreicht
- [ ] **Security-Scan** durchgeführt (keine kritischen Findings)
- [ ] **Rollback-Test** erfolgreich
- [ ] **Lessons Learned** aus Test dokumentiert

**Kommentare**: ____________________

---

## 6. Backup und Disaster Recovery

### 6.1 Backup-Strategie
- [ ] **Backup-Methode** definiert: ____________________
  - 3-2-1 Regel befolgt?  ☐ Ja  ☐ Nein
- [ ] **Backup-Schedule** definiert:
  - Full Backup: ____________________ (täglich/wöchentlich)
  - Incremental: ____________________ (stündlich/täglich)
- [ ] **Backup-Verschlüsselung** konfiguriert (AES-256)
- [ ] **Backup-Storage** konfiguriert:
  - Primär: ____________________
  - Sekundär: ____________________
  - Offsite: ____________________
- [ ] **Backup-Retention** definiert: ____ Tage/Monate
- [ ] **Backup-Monitoring** konfiguriert (Alerts bei Fehler)

**Kommentare**: ____________________

### 6.2 Disaster Recovery
- [ ] **Recovery Time Objective (RTO)**: ____ Stunden
- [ ] **Recovery Point Objective (RPO)**: ____ Stunden
- [ ] **DR-Plan** dokumentiert
- [ ] **DR-Site** vorbereitet (falls erforderlich)
- [ ] **Restore-Test** durchgeführt und erfolgreich
  - Letzte Test-Datum: ____________________
  - Restore-Dauer: ____ Stunden
- [ ] **Failover-Prozedur** dokumentiert
- [ ] **Kommunikationsplan** für DR-Situation

**Kommentare**: ____________________

---

## 7. Sicherheit und Compliance

### 7.1 BSI Grundschutz
- [ ] **BSI Grundschutz-Modellierung** durchgeführt
- [ ] **Schutzbedarfsfeststellung** dokumentiert:
  - Vertraulichkeit: ____________________ (Normal/Hoch/Sehr Hoch)
  - Integrität: ____________________ (Normal/Hoch/Sehr Hoch)
  - Verfügbarkeit: ____________________ (Normal/Hoch/Sehr Hoch)
- [ ] **Relevante Bausteine** identifiziert und zugeordnet
- [ ] **Basis-Absicherung** implementiert
- [ ] **IT-Grundschutz-Check** durchgeführt
- [ ] **Gap-Analyse** durchgeführt
- [ ] **Maßnahmenplan** für Gaps erstellt

**Kommentare**: ____________________

### 7.2 Datenschutz (DSGVO/LDSG BW)
- [ ] **Datenschutz-Folgenabschätzung** (DSFA) durchgeführt
- [ ] **Datenschutz-Verantwortlicher** konsultiert
- [ ] **Verarbeitungsverzeichnis** aktualisiert
- [ ] **Technische und organisatorische Maßnahmen** (TOMs) dokumentiert
- [ ] **Betroffenenrechte** berücksichtigt (Auskunft, Löschung, etc.)
- [ ] **Auftragsverarbeitung** geregelt (falls Cloud/Externe)
- [ ] **Data-Breach-Meldeprozess** etabliert

**Kommentare**: ____________________

### 7.3 Security-Assessments
- [ ] **Vulnerability-Scan** durchgeführt:
  - Tool: ____________________ (OpenVAS/Nessus)
  - Datum: ____________________
  - Kritische Findings: ____ (alle behoben?)
- [ ] **Penetration-Test** durchgeführt (optional):
  - Datum: ____________________
  - Tester: ____________________
  - Findings: ____________________
- [ ] **OpenSCAP-Scan** durchgeführt:
  - Profile: ____________________
  - Compliance-Rate: _____%
- [ ] **Lynis-Audit** durchgeführt:
  - Hardening-Index: ____

**Kommentare**: ____________________

---

## 8. Operations-Vorbereitung

### 8.1 Runbooks und Dokumentation
- [ ] **Runbook** für normale Operations erstellt
- [ ] **Runbook** für Incident Response erstellt
- [ ] **Kontaktlisten** aktualisiert (Bereitschaftsdienst)
- [ ] **Eskalations-Matrix** definiert
- [ ] **SLA/SLO** definiert und dokumentiert
- [ ] **KPIs** für Post-Migration definiert

**Kommentare**: ____________________

### 8.2 Change Management
- [ ] **Change-Tickets** für Migration erstellt
- [ ] **Change-Advisory-Board** (CAB) Freigabe (falls erforderlich)
- [ ] **Wartungsfenster** vereinbart:
  - Start: ____________________
  - Ende: ____________________
  - Dauer: ____ Stunden
- [ ] **Communication-Plan** für Downtime:
  - [ ] Benutzer informiert
  - [ ] Stakeholder informiert
  - [ ] Management informiert

**Kommentare**: ____________________

---

## 9. Go/No-Go Decision Criteria

### 9.1 Go-Kriterien
- [ ] Alle P1-Checklist-Items abgehakt
- [ ] Alle behördlichen Freigaben erhalten
- [ ] Test-Migration erfolgreich
- [ ] Security-Scans ohne kritische Findings
- [ ] Team vollständig und bereit
- [ ] Rollback-Plan getestet
- [ ] Wartungsfenster bestätigt
- [ ] Backup aktuell und validiert

### 9.2 No-Go-Kriterien
- [ ] Kritische Hardware-Probleme
- [ ] Security-Vulnerabilities ungepatch
- [ ] Test-Migration fehlgeschlagen
- [ ] Team nicht verfügbar
- [ ] Fehlende Freigaben
- [ ] Backup-Probleme

**Go/No-Go Decision**: ☐ Go  ☐ No-Go

**Entscheidung getroffen von**: ____________________  
**Datum**: ____________________  
**Unterschrift**: ____________________

---

## 10. Final Sign-Off

**Ich bestätige, dass alle relevanten Checklist-Items überprüft und abgehakt wurden und dass das System bereit für die Migration ist.**

| Rolle | Name | Unterschrift | Datum |
|-------|------|--------------|-------|
| Projektleiter | | | |
| IT-Sicherheitsbeauftragter | | | |
| Datenschutzbeauftragter | | | |
| System-Architekt | | | |
| Behördenleitung | | | |

---

**Ende der Pre-Migration Checklist**

**Nächster Schritt**: [Migration Execution](../during-migration/01_Migration_Execution.md)
