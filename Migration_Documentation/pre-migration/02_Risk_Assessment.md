# Risikoanalyse / Risk Assessment

## Übersicht / Overview

Eine umfassende Risikoanalyse ist essentiell für eine erfolgreiche und sichere Migration von Großrechner-Systemen zu Linux. Diese Analyse folgt den BSI Grundschutz-Methoden.

## 1. Schutzbedarfsfeststellung / Protection Requirements Assessment

### 1.1 BSI Grundschutz-Methodik

Nach BSI Grundschutz werden drei Schutzbedarfskategorien unterschieden:

| Kategorie | Vertraulichkeit | Integrität | Verfügbarkeit |
|-----------|-----------------|------------|---------------|
| **Normal** | Interne Dokumente | Statistische Daten | < 24h Ausfall tolerierbar |
| **Hoch** | Personenbezogene Daten | Finanzdaten | < 4h Ausfall tolerierbar |
| **Sehr Hoch** | Verschlusssachen | Kritische Infrastruktur | < 1h Ausfall tolerierbar |

### 1.2 Asset-Klassifizierung für Landesamt

#### Daten-Assets
```markdown
| Asset | Vertraulichkeit | Integrität | Verfügbarkeit | Begründung |
|-------|-----------------|------------|---------------|------------|
| Bürgerdaten (Personenbez.) | Sehr Hoch | Sehr Hoch | Hoch | DSGVO, LDSG BW |
| Finanzdaten | Hoch | Sehr Hoch | Hoch | Haushalt, Revision |
| Verwaltungsdaten | Hoch | Hoch | Normal | Operative Daten |
| Öffentliche Informationen | Normal | Hoch | Normal | Transparenz |
| Backup-Daten | Sehr Hoch | Sehr Hoch | Hoch | Wie Produktivdaten |
| Protokolldaten | Hoch | Sehr Hoch | Normal | Forensik, Audit |
```

#### System-Assets
```markdown
| Asset | Vertraulichkeit | Integrität | Verfügbarkeit | Begründung |
|-------|-----------------|------------|---------------|------------|
| Datenbank-Server | Sehr Hoch | Sehr Hoch | Sehr Hoch | Zentrale Datenhaltung |
| Applikations-Server | Hoch | Sehr Hoch | Hoch | Geschäftsprozesse |
| Web-Server (DMZ) | Normal | Hoch | Hoch | Öffentlicher Zugang |
| Backup-Server | Sehr Hoch | Sehr Hoch | Hoch | Disaster Recovery |
| SIEM/Logging | Hoch | Sehr Hoch | Normal | Sicherheitsüberwachung |
| Netzwerk-Infrastruktur | Hoch | Sehr Hoch | Sehr Hoch | Grundinfrastruktur |
```

## 2. Gefährdungsanalyse / Threat Analysis

### 2.1 Gefährdungen nach BSI Grundschutz

#### G 0.14 Ausspähen von Informationen (Spionage)
**Relevanz**: Sehr Hoch (Behördendaten)

**Szenarien**:
- Unbefugter Zugriff auf Bürgerdaten während Migration
- Datenlecks durch unsichere Datenübertragung
- Insider-Threats

**Maßnahmen**:
- [ ] Ende-zu-Ende-Verschlüsselung aller Datenübertragungen
- [ ] Verschlüsselung ruhender Daten (LUKS, dm-crypt)
- [ ] Strikte Zugangskontrollen (Least Privilege)
- [ ] Background-Checks für Migrationsteam
- [ ] Logging und Monitoring aller Datenzugriffe

#### G 0.18 Fehlplanung oder fehlende Anpassung
**Relevanz**: Hoch

**Szenarien**:
- Unzureichende Ressourcen-Planung
- Fehlende Skills im Team
- Unterschätzung der Komplexität

**Maßnahmen**:
- [ ] Detaillierte Kapazitätsplanung
- [ ] Skills-Assessment und Training
- [ ] Buffer in Zeitplanung (20-30%)
- [ ] Externe Expertise einbinden
- [ ] Regelmäßige Reviews und Anpassungen

#### G 0.19 Offenlegung schützenswerter Informationen
**Relevanz**: Sehr Hoch

**Szenarien**:
- Datenbank-Dumps ohne Verschlüsselung
- Unverschlüsselte Backup-Medien
- Logs mit sensitiven Daten

**Maßnahmen**:
- [ ] Datenklassifizierung und -markierung
- [ ] Verschlüsselung aller Backups
- [ ] Log-Sanitization (PII entfernen)
- [ ] Sichere Löschung von Testdaten
- [ ] Data Loss Prevention (DLP) Tools

#### G 0.21 Manipulation von Hard- oder Software
**Relevanz**: Hoch

**Szenarien**:
- Kompromittierte Software-Pakete
- Rootkits auf neuen Servern
- Manipulierte Firmware

**Maßnahmen**:
- [ ] Nur vertrauenswürdige Software-Quellen
- [ ] GPG-Signatur-Verifikation
- [ ] AIDE/Tripwire für Integritätsprüfung
- [ ] Regelmäßige Rootkit-Scans
- [ ] Secure Boot / UEFI mit Signed Kernels

#### G 0.23 Unbefugtes Eindringen in IT-Systeme
**Relevanz**: Sehr Hoch

**Szenarien**:
- Exploitation ungepatchter Systeme
- Brute-Force auf SSH
- Privilege Escalation

**Maßnahmen**:
- [ ] Härtung nach CIS/DISA-STIG Benchmarks
- [ ] SELinux/AppArmor im Enforcing-Mode
- [ ] Automatisches Patch-Management
- [ ] Multi-Faktor-Authentifizierung
- [ ] IDS/IPS (Suricata/Snort)
- [ ] Regular Penetration Testing

#### G 0.25 Ausfall von Geräten oder Systemen
**Relevanz**: Sehr Hoch (Migration-kritisch)

**Szenarien**:
- Hardware-Ausfall während Migration
- Netzwerk-Ausfall
- Storage-Ausfall

**Maßnahmen**:
- [ ] Redundante Hardware (RAID, Redundant PSU)
- [ ] High-Availability-Cluster
- [ ] Netzwerk-Redundanz (Bonding, Redundante Switches)
- [ ] UPS und Generator
- [ ] Disaster Recovery Plan mit RTO < 4h

#### G 0.26 Fehlfunktion von Geräten oder Systemen
**Relevanz**: Hoch

**Szenarien**:
- Inkompatibilitäten Linux-Kernel mit Hardware
- Storage-Controller-Probleme
- Netzwerk-Performance-Issues

**Maßnahmen**:
- [ ] Hardware Compatibility List (HCL) prüfen
- [ ] Umfangreiche Tests in Test-Umgebung
- [ ] Performance-Benchmarks
- [ ] Monitoring und Alerting
- [ ] Wartungsverträge mit Herstellern

#### G 0.27 Ressourcenmangel
**Relevanz**: Hoch

**Szenarien**:
- Unzureichende CPU/RAM während Migration
- Storage-Kapazität erschöpft
- Netzwerk-Bandwidth erschöpft

**Maßnahmen**:
- [ ] Kapazitätsplanung mit 50% Buffer
- [ ] Monitoring von Ressourcen
- [ ] Elastische Ressourcen (Cloud-Burst)
- [ ] Storage-Erweiterung vorbereiten
- [ ] QoS für kritische Datenströme

#### G 0.28 Software-Schwachstellen oder -Fehler
**Relevanz**: Sehr Hoch

**Szenarien**:
- Zero-Day-Exploits
- Ungepatchte Vulnerabilities
- Bug in Migrations-Tools

**Maßnahmen**:
- [ ] Vulnerability Scanning (OpenVAS, Nessus)
- [ ] Automatisches Patching
- [ ] Security Mailing Lists abonnieren
- [ ] Web Application Firewall (ModSecurity)
- [ ] Code Reviews für Custom-Code

#### G 0.30 Unberechtigte Nutzung oder Administration
**Relevanz**: Sehr Hoch

**Szenarien**:
- Privilegien-Missbrauch
- Unbefugte Admin-Zugriffe
- Lateral Movement nach Kompromittierung

**Maßnahmen**:
- [ ] Rollenbasierte Zugriffskontrolle (RBAC)
- [ ] Privilege Access Management (PAM)
- [ ] Sudo-Logging
- [ ] 4-Augen-Prinzip für kritische Operationen
- [ ] Session-Recording für Admin-Zugriffe

#### G 0.39 Schadprogramme
**Relevanz**: Hoch

**Szenarien**:
- Malware-Infektion über kompromittierte Pakete
- Ransomware
- Crypto-Miner

**Maßnahmen**:
- [ ] Antivirus (ClamAV) auf allen Systemen
- [ ] Application Whitelisting
- [ ] Netzwerk-Segmentierung
- [ ] HIDS (OSSEC/Wazuh)
- [ ] Regelmäßige Malware-Scans

#### G 0.45 Datenverlust
**Relevanz**: Sehr Hoch

**Szenarien**:
- Fehler bei Daten-Migration
- Versehentliches Löschen
- Storage-Corruption

**Maßnahmen**:
- [ ] 3-2-1 Backup-Strategie
- [ ] Datenbank-Replikation
- [ ] Snapshots vor kritischen Operationen
- [ ] Immutable Backups
- [ ] Regelmäßige Restore-Tests

#### G 0.46 Integritätsverlust schützenswerter Informationen
**Relevanz**: Sehr Hoch (Behörde)

**Szenarien**:
- Daten-Korruption während Migration
- Manipulation von Datensätzen
- Inkonsistenzen durch Race Conditions

**Maßnahmen**:
- [ ] Checksummen für alle Datentransfers
- [ ] Transactional Data Migration
- [ ] Datenbank-Constraints und Triggers
- [ ] Regelmäßige Integritätsprüfungen
- [ ] Digitale Signaturen für kritische Daten

## 3. Migrationsrisiken / Migration Risks

### 3.1 Technische Risiken

#### R-TECH-001: Datenbank-Migrations-Fehler
```markdown
**Beschreibung**: Fehler bei Konvertierung Adabas → PostgreSQL
**Wahrscheinlichkeit**: Mittel
**Impact**: Sehr Hoch
**Risikostufe**: HOCH

**Szenarien**:
- Datentyp-Inkompatibilitäten
- Daten-Truncation
- Zeichensatz-Probleme (EBCDIC → UTF-8)
- PE/MU-Felder fehlerhaft migriert

**Mitigation**:
- Umfassende Konvertierungs-Tests
- Automatisierte Validierungs-Scripts
- Manuelle Stichproben
- Rollback-Plan
```

#### R-TECH-002: Performance-Degradation
```markdown
**Beschreibung**: Schlechtere Performance auf Linux
**Wahrscheinlichkeit**: Hoch
**Impact**: Hoch
**Risikostufe**: HOCH

**Szenarien**:
- Unoptimierte Queries
- Fehlende Indizes
- I/O-Bottlenecks
- Netzwerk-Latenz

**Mitigation**:
- Performance-Benchmarks vor/nach Migration
- Query-Optimierung
- Index-Tuning
- Storage-Optimierung (SSD, RAID)
- Load-Testing
```

#### R-TECH-003: Anwendungs-Inkompatibilität
```markdown
**Beschreibung**: Natural-Programme nicht migrierbar
**Wahrscheinlichkeit**: Mittel
**Impact**: Sehr Hoch
**Risikostufe**: HOCH

**Szenarien**:
- Natural-Code zu komplex für Konvertierung
- Mainframe-spezifische Features verwendet
- Drittanbieter-Tools nicht verfügbar

**Mitigation**:
- Proof of Concept für kritische Anwendungen
- Natural für Linux evaluieren
- Schrittweise Re-Implementation
- Web-Service-Wrapper als Alternative
```

### 3.2 Organisatorische Risiken

#### R-ORG-001: Unzureichende Ressourcen
```markdown
**Beschreibung**: Budget/Personal nicht ausreichend
**Wahrscheinlichkeit**: Mittel
**Impact**: Hoch
**Risikostufe**: MITTEL

**Mitigation**:
- Detaillierte Ressourcen-Planung
- Eskalations-Prozess etablieren
- Externe Berater als Backup
```

#### R-ORG-002: Widerstand gegen Veränderung
```markdown
**Beschreibung**: Mitarbeiter-Widerstand, fehlende Akzeptanz
**Wahrscheinlichkeit**: Hoch
**Impact**: Mittel
**Risikostufe**: MITTEL

**Mitigation**:
- Change-Management-Programm
- Frühzeitige Einbindung Stakeholder
- Schulungen und Workshops
- Quick Wins kommunizieren
```

### 3.3 Compliance-Risiken

#### R-COMP-001: BSI Grundschutz Nicht-Compliance
```markdown
**Beschreibung**: Anforderungen nicht erfüllt
**Wahrscheinlichkeit**: Mittel
**Impact**: Sehr Hoch
**Risikostufe**: HOCH

**Mitigation**:
- BSI-Zertifizierter Berater
- Regelmäßige Audits
- Compliance-Checklisten
- Dokumentation aller Maßnahmen
```

#### R-COMP-002: DSGVO/LDSG-Verstöße
```markdown
**Beschreibung**: Datenschutz-Anforderungen nicht eingehalten
**Wahrscheinlichkeit**: Niedrig
**Impact**: Sehr Hoch
**Risikostufe**: MITTEL

**Mitigation**:
- Datenschutz-Folgenabschätzung
- Datenschutzbeauftragten einbinden
- Privacy by Design
- Regelmäßige Privacy Audits
```

## 4. Risikomatrix / Risk Matrix

### 4.1 Gesamt-Risikobewertung

```
           IMPACT
           │ L   M   H   VH
    ───────┼────────────────
    VH  P  │     R-004
           │         R-TECH-001
    H      │         R-TECH-002
           │         R-TECH-003
    M   W  │ R-ORG-002   R-ORG-001
           │     R-COMP-002
    L      │         R-COMP-001
           │
    N      │

Legende:
VH = Sehr Hoch, H = Hoch, M = Mittel, L = Niedrig, N = Negligible
P = Probability, W = Wahrscheinlichkeit
```

### 4.2 Top-10 Risiken mit Priorität

| Rang | Risiko-ID | Beschreibung | Risiko-Level | Priorität |
|------|-----------|--------------|--------------|-----------|
| 1 | R-TECH-001 | Datenbank-Migration Fehler | HOCH | P1 |
| 2 | R-TECH-002 | Performance-Degradation | HOCH | P1 |
| 3 | R-TECH-003 | Anwendungs-Inkompatibilität | HOCH | P1 |
| 4 | R-COMP-001 | BSI Grundschutz Non-Compliance | HOCH | P1 |
| 5 | G 0.45 | Datenverlust | HOCH | P1 |
| 6 | G 0.46 | Integritätsverlust | HOCH | P1 |
| 7 | G 0.23 | Unbefugtes Eindringen | HOCH | P2 |
| 8 | R-ORG-001 | Ressourcenmangel | MITTEL | P2 |
| 9 | R-ORG-002 | Change Resistance | MITTEL | P3 |
| 10 | R-COMP-002 | DSGVO-Verstöße | MITTEL | P2 |

## 5. Maßnahmenplan / Action Plan

### 5.1 Sofort-Maßnahmen (vor Migration-Start)

```markdown
✓ Priority 1 (P1) - Kritisch
─────────────────────────────
□ Backup-Strategie etablieren und testen
□ Verschlüsselung für alle Daten implementieren
□ Zugangskontrollen und MFA einrichten
□ Test-Umgebung mit Produktions-ähnlichen Daten
□ Automatisierte Validierungs-Scripts entwickeln
□ Disaster Recovery Plan dokumentieren und testen
□ BSI Grundschutz-Compliance-Check durchführen
□ DSFA (Datenschutz-Folgenabschätzung) durchführen

✓ Priority 2 (P2) - Hoch
────────────────────────
□ Performance-Benchmarks etablieren
□ IDS/IPS installieren und konfigurieren
□ SIEM-System aufsetzen
□ Penetration Testing beauftragen
□ Skills-Assessment und Training-Plan
□ Change-Management-Programm starten

✓ Priority 3 (P3) - Mittel
──────────────────────────
□ Application Whitelisting evaluieren
□ DLP-Tools evaluieren
□ Automation mit Ansible/Terraform
```

### 5.2 Laufende Maßnahmen (während Migration)

```markdown
□ Tägliche Backups
□ Kontinuierliches Monitoring
□ Wöchentliche Risiko-Reviews
□ Zweiwöchentliche Security Scans
□ Monatliche Compliance-Audits
□ Kontinuierliche Validierung
```

### 5.3 Kontroll-Maßnahmen (nach Migration)

```markdown
□ Post-Migration-Audit
□ Penetration Testing
□ Performance-Validierung
□ Compliance-Zertifizierung
□ Lessons Learned Workshop
□ Aktualisierung Risiko-Register
```

## 6. Restrisiken / Residual Risks

Nach Implementierung aller Maßnahmen verbleiben folgende Restrisiken:

| Risiko | Restrisiko-Level | Akzeptanz | Begründung |
|--------|------------------|-----------|------------|
| R-TECH-002 | NIEDRIG | Akzeptiert | Performance-Tuning kontinuierlich |
| R-ORG-002 | NIEDRIG | Akzeptiert | Change Management etabliert |
| G 0.28 | NIEDRIG | Akzeptiert | Zero-Days nicht vermeidbar |

**Freigabe erforderlich durch**:
- [ ] IT-Sicherheitsbeauftragter
- [ ] Datenschutzbeauftragter
- [ ] Behördenleitung

## 7. Monitoring und Review

### 7.1 Risiko-Monitoring

```bash
# Risiko-Status wöchentlich überprüfen:
- Neue Risiken identifiziert?
- Bestehende Risiken verändert?
- Maßnahmen wirksam?
- Eskalation erforderlich?
```

### 7.2 Review-Zyklen

- **Täglich**: Monitoring-Alerts
- **Wöchentlich**: Risiko-Status-Meeting
- **Monatlich**: Compliance-Review
- **Quartalsweise**: Gesamt-Risiko-Assessment

## Nächste Schritte / Next Steps

1. [Detaillierte Migrationsplanung](./03_Migration_Planning.md)
2. [Security Baseline etablieren](./04_Security_Baseline.md)
3. [Migrations-Execution](../during-migration/01_Migration_Execution.md)

## Referenzen / References

- BSI Grundschutz-Kompendium 2023
- BSI Standard 200-3: Risikoanalyse
- ISO/IEC 27005: Information Security Risk Management
- NIST SP 800-30: Guide for Conducting Risk Assessments
