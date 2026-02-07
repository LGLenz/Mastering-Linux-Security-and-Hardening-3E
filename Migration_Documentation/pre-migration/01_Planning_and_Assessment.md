# Planung und Assessment / Planning and Assessment

## Übersicht / Overview

Diese Phase etabliert die Grundlage für eine erfolgreiche Migration durch umfassende Analyse des bestehenden Systems und Planung der Zielarchitektur.

## 1. Legacy-System-Analyse / Legacy System Analysis

### 1.1 Großrechner-System-Assessment

#### Technische Bestandsaufnahme / Technical Inventory

**Hardware-Konfiguration**
```bash
# Dokumentieren Sie folgende Parameter:
- CPU-Typ und -Kapazität
- Speicher (RAM)
- Storage-Systeme (DASD, etc.)
- I/O-Subsysteme
- Netzwerk-Verbindungen
```

**Software-Inventar**
```
# Betriebssystem
- z/OS, z/VSE, z/VM, BS2000, oder andere
- Version und Patch-Level
- Installierte Komponenten

# Middleware
- CICS, IMS, MQ Series
- Version und Konfiguration

# Datenbanken
- Adabas (Version, Datenbank-Größe)
- DB2, IMS DB
- Andere Datenbanksysteme

# Anwendungen
- Natural-Programme
- COBOL-Programme
- Assembler-Code
- Batch-Jobs
```

### 1.2 Adabas-Datenbank-Analyse

#### Datenbank-Strukturen
```bash
# Analyse-Checkliste für Adabas:

1. Datenbank-Größe und Anzahl:
   - Anzahl der Datenbanken
   - Größe pro Datenbank
   - Anzahl der Files
   - Records pro File

2. Datenstrukturen:
   - DDMs (Data Definition Modules)
   - FDTs (Field Definition Tables)
   - Periodische Gruppen
   - Multiple-Value Fields

3. Performance-Parameter:
   - Buffer Pool Größen
   - ASSO/DATA/WORK Datasets
   - Index-Strukturen (Descriptors, Super-Descriptors)

4. Sicherheit und Zugriff:
   - Natural Security
   - Adabas Security
   - Benutzer und Rollen
   - Zugriffsrechte
```

#### Datenvolumen-Schätzung
```sql
-- Beispiel: Datenvolumen-Analyse
-- Dokumentieren Sie:

Datenbank-Name: EMPLOYEES
Anzahl Files: 15
Gesamtgröße: 500 GB
Durchschn. Datensatzgröße: 2 KB
Anzahl Records: 250 Millionen
Wachstumsrate: 10% pro Jahr
```

### 1.3 Anwendungs-Analyse

#### Natural-Programme
```natural
* Inventarisieren Sie alle Natural-Programme:
*   - Anzahl der Programme
*   - Zeilen Code
*   - Abhängigkeiten
*   - Verwendete Adabas-Files
*   - Verwendete externe Schnittstellen
```

**Migrations-Optionen für Natural:**
1. **Re-Implementation**: Neu-Entwicklung in modernen Sprachen (Python, Java)
2. **Natural für Linux**: Natural Runtime Environment auf Linux
3. **Web-Service-Wrapper**: Natural-Programme als Services kapseln

#### Batch-Jobs
```bash
# Dokumentation aller Batch-Jobs:
- Job-Name und -Beschreibung
- Zeitplan (täglich, wöchentlich, monatlich)
- Abhängigkeiten
- Input-/Output-Dateien
- Laufzeit
- Ressourcenverbrauch
```

### 1.4 Schnittstellen-Analyse

**Externe Systeme**
```
┌─────────────────┐       ┌──────────────┐
│  Großrechner    │──────▶│  System A    │
│  (Adabas)       │       └──────────────┘
│                 │       ┌──────────────┐
│                 │──────▶│  System B    │
└─────────────────┘       └──────────────┘
        │
        ▼
  ┌──────────────┐
  │  System C    │
  └──────────────┘

# Dokumentieren Sie:
- Protokolle (MQ, File Transfer, TCP/IP)
- Datenformate
- Frequenz der Datenübertragung
- Sicherheitsanforderungen (Verschlüsselung)
```

## 2. Anforderungsanalyse / Requirements Analysis

### 2.1 Funktionale Anforderungen

**Business Requirements**
- [ ] Alle Geschäftsprozesse identifiziert
- [ ] Kritische Funktionen priorisiert
- [ ] SLAs (Service Level Agreements) definiert
- [ ] Verfügbarkeitsanforderungen dokumentiert

**Technische Anforderungen**
- [ ] Performance-Anforderungen (Response Time, Throughput)
- [ ] Kapazitätsanforderungen (Storage, CPU, RAM)
- [ ] Skalierbarkeitsanforderungen
- [ ] Integrations-Anforderungen

### 2.2 Nicht-funktionale Anforderungen

#### Sicherheitsanforderungen (BSI Grundschutz)

**SYS.1.1 Allgemeiner Server**
- [ ] Planung des Server-Einsatzes
- [ ] Sichere Installation und Konfiguration
- [ ] Sichere Administration
- [ ] Protokollierung
- [ ] Aktualisierung

**SYS.1.3 Server unter Linux und Unix**
- [ ] Auswahl einer geeigneten Distribution
- [ ] Planung der Partitionierung
- [ ] Sichere Installation
- [ ] Kernel-Härtung
- [ ] Restriktive Rechtevergabe

**APP.4.3 Relationale Datenbanken**
- [ ] Planung des Einsatzes
- [ ] Sichere Installation und Konfiguration
- [ ] Berechtigungsverwaltung
- [ ] Datensicherung
- [ ] Verschlüsselung

#### Datenschutzanforderungen

**DSGVO/LDSG BW Compliance**
```markdown
1. Datenschutz-Folgenabschätzung (DSFA):
   - Identifikation personenbezogener Daten
   - Risikoanalyse für Betroffene
   - Technische und organisatorische Maßnahmen

2. Datenschutz-Grundsätze:
   - Rechtmäßigkeit der Verarbeitung
   - Zweckbindung
   - Datenminimierung
   - Richtigkeit
   - Speicherbegrenzung
   - Integrität und Vertraulichkeit

3. Betroffenenrechte:
   - Auskunftsrecht
   - Recht auf Berichtigung
   - Recht auf Löschung
   - Recht auf Datenübertragbarkeit
```

### 2.3 Compliance-Anforderungen

**BSI Grundschutz-Modellierung**
```
Schritt 1: Strukturanalyse
├── IT-Verbund definieren
├── Assets identifizieren
└── Netzplan erstellen

Schritt 2: Schutzbedarfsfeststellung
├── Vertraulichkeit (normal/hoch/sehr hoch)
├── Integrität (normal/hoch/sehr hoch)
└── Verfügbarkeit (normal/hoch/sehr hoch)

Schritt 3: Modellierung
├── Bausteine zuordnen
├── Anforderungen prüfen
└── Basis-Absicherung dokumentieren

Schritt 4: IT-Grundschutz-Check
├── Soll-Ist-Vergleich
├── Gap-Analyse
└── Maßnahmenplan
```

## 3. Zielarchitektur-Definition / Target Architecture Definition

### 3.1 Linux-Server-Architektur

#### High-Level-Architektur
```
┌─────────────────────────────────────────────┐
│         Load Balancer / Reverse Proxy       │
│            (HAProxy / nginx)                │
└──────────────┬──────────────────────────────┘
               │
    ┌──────────┴──────────┐
    ▼                     ▼
┌─────────┐         ┌─────────┐
│ Linux   │         │ Linux   │
│ Server  │         │ Server  │
│ (App 1) │         │ (App 2) │
└────┬────┘         └────┬────┘
     │                   │
     └──────────┬────────┘
                ▼
    ┌───────────────────────┐
    │  PostgreSQL Cluster   │
    │  (Primary + Replica)  │
    └───────────────────────┘
                │
                ▼
    ┌───────────────────────┐
    │   Backup Server       │
    │   (Encrypted)         │
    └───────────────────────┘
```

#### Security Zones
```
DMZ (Demilitarized Zone):
├── Reverse Proxy
└── Bastion Host

Internal Zone:
├── Application Servers
├── Database Servers
└── Monitoring Servers

Management Zone:
├── Jump Server
├── Patch Management
└── Backup Server

Logging Zone:
└── SIEM / Log Aggregation
```

### 3.2 Datenbank-Architektur (PostgreSQL)

#### Adabas zu PostgreSQL Mapping
```sql
-- Beispiel: Mapping-Strategie

Adabas File → PostgreSQL Table
Adabas Field → PostgreSQL Column
Adabas MU-Field → Separate Table mit Foreign Key
Adabas PE-Group → JSON Column oder separate Table
Adabas Descriptor → PostgreSQL Index
Adabas Super-Descriptor → Multi-column Index

-- Schema-Design:
CREATE TABLE employees (
    employee_id BIGSERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    hire_date DATE NOT NULL,
    department_id INTEGER REFERENCES departments(department_id),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Index-Strategie:
CREATE INDEX idx_employees_last_name ON employees(last_name);
CREATE INDEX idx_employees_department ON employees(department_id);
CREATE INDEX idx_employees_hire_date ON employees(hire_date);
```

### 3.3 Netzwerk-Architektur

#### Firewall-Konzept
```bash
# Netzwerk-Segmentierung nach BSI Grundschutz

# External Firewall
- Internet ↔ DMZ
- Nur HTTPS (443), SSH (22 von spez. IPs)

# Internal Firewall  
- DMZ ↔ Internal
- Nur erforderliche Ports
- Application-Level Gateway

# Management Firewall
- Management ↔ All Zones
- Nur von Jump Server
- Multi-Faktor-Authentifizierung
```

## 4. Gap-Analyse / Gap Analysis

### 4.1 Technische Lücken
```markdown
| Bereich | Ist-Zustand | Soll-Zustand | Gap | Priorität |
|---------|-------------|--------------|-----|-----------|
| OS Security | Mainframe Security | SELinux/AppArmor | Hoch | P1 |
| Encryption | z/OS Encryption | LUKS, TLS 1.3 | Mittel | P1 |
| Monitoring | SYSLOG | ELK Stack, Wazuh | Hoch | P2 |
| Backup | Mainframe Backup | Bacula, rsync | Mittel | P1 |
| HA/DR | Mainframe HA | Pacemaker, DRBD | Hoch | P2 |
```

### 4.2 Skills-Gap
```markdown
| Skill | Erforderlich | Vorhanden | Training nötig |
|-------|--------------|-----------|----------------|
| Linux Admin | Ja | Teilweise | Ja |
| PostgreSQL | Ja | Nein | Ja |
| SELinux | Ja | Nein | Ja |
| Docker/Kubernetes | Optional | Nein | Optional |
| Ansible/Terraform | Optional | Nein | Optional |
```

## 5. Migrationsstrategien / Migration Strategies

### 5.1 Strategieoptionen

**1. Big Bang Migration**
- Komplette Migration an einem Termin
- Hohes Risiko, aber schnell
- Geeignet für: Kleine Systeme, klare Abhängigkeiten

**2. Phasenweise Migration (Empfohlen)**
- Migration in mehreren Phasen
- Pro Phase: Ein Modul/Subsystem
- Geeignet für: Komplexe Systeme, reduziertes Risiko

**3. Parallelbetrieb**
- Alte und neue Systeme parallel
- Schrittweise Umstellung
- Geeignet für: Kritische Systeme, maximale Sicherheit

### 5.2 Empfohlener Ansatz: Hybrid

```
Phase 1: Nicht-kritische Batch-Jobs
├── Daten-Extraktion aus Adabas
├── Daten-Import in PostgreSQL
├── Batch-Jobs neu implementieren
└── Testing und Validierung

Phase 2: Lese-Zugriffe (Read-Only Apps)
├── Datenreplikation Adabas → PostgreSQL
├── Read-Only Apps migrieren
├── Parallelbetrieb (dual read)
└── Cutover nach Validierung

Phase 3: Schreib-Zugriffe (Critical Apps)
├── Kritische Anwendungen migrieren
├── Dual-Write (Adabas + PostgreSQL)
├── Validierung Datenintegrität
└── Cutover zu PostgreSQL

Phase 4: Legacy-System-Abschaltung
├── Datenarchivierung
├── Adabas-System stilllegen
└── Ressourcen freigeben
```

## 6. Zeitplan und Meilensteine / Timeline and Milestones

### 6.1 Projekt-Phasen

```gantt
Phase               | Dauer    | Abhängigkeiten
--------------------|----------|------------------
Planung & Assessment| 2 Monate | -
Infrastruktur-Setup | 2 Monate | Planung
Security Baseline   | 1 Monat  | Infrastruktur
Daten-Migration Test| 2 Monate | Security Baseline
App-Migration Test  | 3 Monate | Daten-Migration
Integration Testing | 2 Monate | App-Migration
Produktiv-Migration | 2 Monate | Integration
Stabilisierung      | 2 Monate | Produktiv-Mig.
```

### 6.2 Kritische Meilensteine

- [ ] **M1**: Planung abgeschlossen, Freigaben erhalten (Monat 2)
- [ ] **M2**: Test-Umgebung aufgebaut (Monat 4)
- [ ] **M3**: Security Baseline etabliert (Monat 5)
- [ ] **M4**: Erste Testmigration erfolgreich (Monat 7)
- [ ] **M5**: Alle Tests bestanden (Monat 12)
- [ ] **M6**: Go-Live Entscheidung (Monat 13)
- [ ] **M7**: Produktiv-Migration abgeschlossen (Monat 14)
- [ ] **M8**: Stabilisierung und Optimierung (Monat 16)

## 7. Risikoregister / Risk Register

| Risiko-ID | Beschreibung | Wahrscheinlichkeit | Impact | Mitigation |
|-----------|--------------|-------------------|--------|------------|
| R-001 | Datenverlust während Migration | Mittel | Sehr Hoch | Multiple Backups, Validierung |
| R-002 | Performance-Probleme | Hoch | Hoch | Performance-Tests, Tuning |
| R-003 | Inkompatibilität Natural-Code | Mittel | Hoch | Proof of Concept, Alternativen |
| R-004 | Verzögerungen im Zeitplan | Hoch | Mittel | Buffer einplanen, Phasenweise |
| R-005 | Skills-Gap im Team | Mittel | Hoch | Training, externe Berater |
| R-006 | Security-Vulnerabilities | Mittel | Sehr Hoch | Security Audits, Penetration Tests |

## Nächste Schritte / Next Steps

1. [Risikoanalyse durchführen](./02_Risk_Assessment.md)
2. [Detaillierte Migrationsplanung](./03_Migration_Planning.md)
3. [Security Baseline etablieren](./04_Security_Baseline.md)

## Referenzen / References

- BSI Grundschutz-Baustein SYS.1.3
- BSI Grundschutz-Baustein APP.4.3
- Software AG Adabas Documentation
- PostgreSQL Migration Best Practices
