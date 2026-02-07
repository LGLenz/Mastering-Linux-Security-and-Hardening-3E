# Landwirt Helfer 35 - README

## Übersicht / Overview

**Landwirt Helfer 35** ist ein spezialisierter KI-Assistent für die Dokumentation und Einrichtung von Server-Kommunikation in Baden-Württemberg, Deutschland.

**Landwirt Helfer 35** is a specialized AI assistant for documenting and setting up server communication in Baden-Württemberg, Germany.

---

## Hauptfunktionen / Main Features

### Deutsch

1. **Server-Kommunikation einrichten**
   - Verbindungen zu HIT, Data Experts, BITBW, Ministerien und Ämtern
   - Schritt-für-Schritt-Anleitungen
   - Sicherheits-Best-Practices nach BSI Grundschutz

2. **Confluence-Dokumentation erstellen**
   - Vorlagen für technische Dokumentation
   - Mehrsprachige Übersetzungen
   - Compliance-Checklisten (DSGVO, BSI)

3. **Technische Unterstützung**
   - Firewall-Konfiguration (nftables/iptables)
   - SSL/TLS-Zertifikate
   - VPN-Einrichtung
   - Monitoring und Logging

4. **Intelligente Fehlertoleranz**
   - Erkennt Tippfehler automatisch
   - Versteht Kontext und Absicht
   - Unterstützt verschiedene Schreibweisen

5. **Höfliche Kommunikation**
   - Bietet Sie/Du-Wahl an
   - Professioneller Sprachstil
   - Behördengerechte Terminologie

### English

1. **Server Communication Setup**
   - Connections to HIT, Data Experts, BITBW, ministries and departments
   - Step-by-step guides
   - Security best practices following BSI standards

2. **Confluence Documentation**
   - Templates for technical documentation
   - Multilingual translations
   - Compliance checklists (GDPR, BSI)

3. **Technical Support**
   - Firewall configuration (nftables/iptables)
   - SSL/TLS certificates
   - VPN setup
   - Monitoring and logging

4. **Intelligent Error Tolerance**
   - Automatically recognizes typos
   - Understands context and intent
   - Supports various spellings

5. **Polite Communication**
   - Offers formal/informal address choice
   - Professional language style
   - Appropriate governmental terminology

---

## Dateien / Files

### Agent-Konfiguration / Agent Configuration
- **`.github/agents/landwirt-helfer-35.agent.md`**
  - Haupt-Konfigurationsdatei des Agenten
  - Main agent configuration file

### Dokumentation / Documentation
- **`Server-Kommunikation-Dokumentation.md`**
  - Vollständige technische Dokumentation
  - Complete technical documentation
  - Schritt-für-Schritt-Anleitungen für alle Institutionen
  - Step-by-step guides for all institutions

- **`Landwirt-Helfer-35-Beispiele.md`**
  - 12+ Beispiel-Prompts mit detaillierten Antworten
  - 12+ example prompts with detailed responses
  - Anwendungsfälle und Szenarien
  - Use cases and scenarios

---

## Schnellstart / Quick Start

### Deutsch

1. **Agent aktivieren**
   - Datei in GitHub Copilot laden
   - Agent "Landwirt Helfer 35" auswählen

2. **Erste Schritte**
   ```
   Benutzer: "Hallo, ich brauche Hilfe bei der Server-Kommunikation"
   
   Agent: Bietet Sie/Du-Wahl an und zeigt verfügbare Funktionen
   ```

3. **Beispiel-Anfrage**
   ```
   Benutzer: "Ich möchte eine Verbindung zu HIT einrichten"
   
   Agent: Führt durch den kompletten Einrichtungsprozess
   ```

### English

1. **Activate Agent**
   - Load file in GitHub Copilot
   - Select agent "Landwirt Helfer 35"

2. **First Steps**
   ```
   User: "Hello, I need help with server communication"
   
   Agent: Offers formal/informal choice and shows available functions
   ```

3. **Example Request**
   ```
   User: "I want to set up a connection to HIT"
   
   Agent: Guides through the complete setup process
   ```

---

## Starter-Prompts

### Für Einsteiger / For Beginners

1. "Ich möchte eine Verbindung zu [HIT/BITBW/Data Experts/Ministerium] einrichten"
2. "Welche Firewall-Regeln benötige ich?"
3. "Wie erstelle ich eine Confluence-Dokumentation?"
4. "Zeige mir die Sicherheitsanforderungen"
5. "Die Verbindung funktioniert nicht - was soll ich prüfen?"

### Für Fortgeschrittene / For Advanced Users

6. "Wie richte ich SSL/TLS-Zertifikate ein?"
7. "Ich brauche eine VPN-Verbindung zum Behördennetz"
8. "Wie überwache ich die Verbindung?"
9. "Welche Compliance-Anforderungen gelten?"
10. "Wie sichere ich die Konfiguration?"

---

## Unterstützte Institutionen / Supported Institutions

| Institution | Typ | Sicherheitsstufe |
|-------------|-----|------------------|
| **HIT** | Hochschul-IT | Hoch |
| **Data Experts** | Datenverarbeitung (Profil-Projekt) | Sehr hoch (DSGVO) |
| **BITBW** | IT-Dienstleister Land BW | Sehr hoch |
| **Ministerien BW** | Landesbehörden | Sehr hoch |
| **Ämter** | Kommunalbehörden | Hoch |

---

## Sicherheitsstandards / Security Standards

### BSI Grundschutz
- APP.3.1: Web-Anwendungen
- NET.3.2: Firewall
- NET.4.1: TLS-Verschlüsselung
- OPS.2.2: Cloud-Nutzung
- CON.1: Kryptokonzept

### DSGVO / GDPR
- Datenschutz-Folgenabschätzung
- Auftragsverarbeitungsvertrag
- Technisch-organisatorische Maßnahmen
- Löschkonzept

### Landesrichtlinien BW
- IT-Sicherheitsrichtlinie
- Behördennetz-Zugang
- BITBW-Vorgaben

---

## Mehrsprachigkeit / Multilingual Support

### Unterstützte Sprachen / Supported Languages

| Sprache / Language | Status | Verwendung / Usage |
|-------------------|--------|-------------------|
| **Deutsch** | ✅ Primär | Hauptkommunikation |
| **Englisch** | ✅ Verfügbar | Zusammenfassungen |
| **Französisch** | ✅ Verfügbar | Zusammenfassungen |
| **Spanisch** | ✅ Verfügbar | Zusammenfassungen |
| **Arabisch** | ✅ Verfügbar | Zusammenfassungen |
| **Türkisch** | ✅ Verfügbar | Zusammenfassungen |

### Confluence Auto-Translate

Der Agent unterstützt die Confluence Auto-Translate-Funktion:
- Seite → Einstellungen → Übersetzungen → Auto-Translate aktivieren

The agent supports Confluence Auto-Translate feature:
- Page → Settings → Translations → Enable Auto-Translate

---

## Technische Anforderungen / Technical Requirements

### Unterstützte Linux-Distributionen
- Ubuntu 18.04, 20.04, 22.04, 24.04
- Debian 10, 11, 12
- Red Hat Enterprise Linux 8, 9
- SUSE Linux Enterprise Server

### Netzwerk-Protokolle / Network Protocols
- SSH (Port 22)
- HTTPS (Port 443)
- VPN (OpenVPN, WireGuard, IPSec)
- Custom Ports (nach Anforderung / as required)

### Voraussetzungen / Prerequisites
- Root-Zugriff / Root access
- Netzwerkfreigaben / Network permissions
- Sicherheitsgenehmigungen / Security approvals
- Zertifikate/Keys / Certificates/Keys

---

## Beispiele / Examples

### Beispiel 1: HIT-Verbindung einrichten

```bash
# Benutzer fragt
"Wie richte ich eine Verbindung zu HIT ein?"

# Agent antwortet mit:
1. Voraussetzungen-Check
2. Netzwerkkonfiguration
3. Firewall-Regeln
4. SSL/TLS-Setup
5. Monitoring
6. Dokumentation

# Fertige Befehle zum Kopieren
sudo nft add rule inet filter output ip daddr <HIT-IP> tcp dport 443 accept
```

### Beispiel 2: Confluence-Dokumentation

```bash
# Benutzer fragt
"Erstelle eine Confluence-Dokumentation für BITBW"

# Agent liefert:
1. Vollständige Vorlage
2. Technische Spezifikation
3. Sicherheitsanforderungen
4. Mehrsprachige Zusammenfassungen
5. Checklisten
```

### Example 3: Troubleshooting

```bash
# User asks
"Connection to Data Experts is not working"

# Agent provides:
1. Systematic diagnosis steps
2. Command-line tools
3. Common problems & solutions
4. Escalation path
```

---

## Fehlertoleranz / Error Tolerance

Der Agent erkennt häufige Tippfehler:

### Deutsch
- "Sever" → "Server"
- "Firwall" → "Firewall"
- "Zertifkat" → "Zertifikat"
- "BIBTW" → "BITBW"
- "Konfigurazion" → "Konfiguration"

### English
- "Conexion" → "Connection"
- "Sertificate" → "Certificate"
- "Confguration" → "Configuration"

---

## Sicherheitshinweise / Security Notes

### ⚠️ WICHTIG / IMPORTANT

1. **Private Schlüssel / Private Keys**
   - Niemals in Dokumentation aufnehmen
   - Never include in documentation
   - Immer verschlüsselt sichern
   - Always backup encrypted

2. **Passwörter / Passwords**
   - Keine Klartext-Passwörter
   - No plaintext passwords
   - Sichere Authentifizierung (Zertifikate, SSH-Keys)
   - Secure authentication (certificates, SSH keys)

3. **Compliance**
   - DSGVO bei personenbezogenen Daten beachten
   - Follow GDPR for personal data
   - BSI Grundschutz einhalten
   - Comply with BSI standards

4. **Logs**
   - Aufbewahrungspflichten beachten (7 Jahre für Behörden)
   - Follow retention requirements (7 years for authorities)

---

## Hilfe und Support / Help and Support

### Interne Kontakte / Internal Contacts
- **BITBW Service-Desk**: 0711-xxx-xxxx
- **IT-Sicherheit LGL**: cert@lgl-bw.de
- **Confluence-Support**: confluence-admin@lgl-bw.de

### Externe Ressourcen / External Resources
- **BSI**: https://www.bsi.bund.de
- **Linux Security**: https://www.kernel.org/doc/html/latest/admin-guide/security.html
- **nftables**: https://wiki.nftables.org

---

## Changelog

### Version 1.0.0 (2026-02-07)
- ✅ Initiale Version
- ✅ 12+ Starter-Prompts
- ✅ Vollständige Dokumentation
- ✅ Mehrsprachige Unterstützung
- ✅ Fehlertoleranz
- ✅ Sie/Du-Wahl

---

## Lizenz / License

Dieses Projekt ist Teil des Repositorys "Mastering Linux Security and Hardening 3E".
Siehe LICENSE-Datei für Details.

This project is part of the "Mastering Linux Security and Hardening 3E" repository.
See LICENSE file for details.

---

## Autoren / Authors

**Erstellt für**: Landesgesundheitsamt Baden-Württemberg (LGL BW)
**Created for**: State Health Office Baden-Württemberg (LGL BW)

**Version**: 1.0.0
**Datum / Date**: 2026-02-07

---

## Multilingual Summaries / Mehrsprachige Zusammenfassungen

### Résumé en français

**Landwirt Helfer 35** est un assistant IA spécialisé pour la documentation et la configuration de la communication serveur à Baden-Württemberg, Allemagne.

**Fonctionnalités principales**:
- Configuration de connexions serveur (HIT, Data Experts, BITBW, ministères)
- Documentation Confluence automatisée
- Support technique (pare-feu, certificats SSL/TLS, VPN)
- Tolérance aux fautes de frappe
- Communication professionnelle et polie

### Resumen en español

**Landwirt Helfer 35** es un asistente de IA especializado para documentar y configurar comunicaciones de servidor en Baden-Württemberg, Alemania.

**Funciones principales**:
- Configuración de conexiones de servidor (HIT, Data Experts, BITBW, ministerios)
- Documentación automática en Confluence
- Soporte técnico (firewall, certificados SSL/TLS, VPN)
- Tolerancia a errores tipográficos
- Comunicación profesional y cortés

### الملخص العربي

**Landwirt Helfer 35** هو مساعد ذكاء اصطناعي متخصص لتوثيق وإعداد اتصالات الخادم في بادن فورتمبيرغ، ألمانيا.

**الوظائف الرئيسية**:
- إعداد اتصالات الخادم (HIT، Data Experts، BITBW، الوزارات)
- توثيق تلقائي في Confluence
- دعم تقني (جدار الحماية، شهادات SSL/TLS، VPN)
- تحمل الأخطاء الإملائية
- تواصل مهني ومهذب

### Türkçe Özet

**Landwirt Helfer 35**, Baden-Württemberg, Almanya'da sunucu iletişimini belgelemek ve kurmak için özelleştirilmiş bir yapay zeka asistanıdır.

**Ana özellikler**:
- Sunucu bağlantılarını yapılandırma (HIT, Data Experts, BITBW, bakanlıklar)
- Otomatik Confluence belgelendirmesi
- Teknik destek (güvenlik duvarı, SSL/TLS sertifikaları, VPN)
- Yazım hatalarına tolerans
- Profesyonel ve kibar iletişim

---

**Letzte Aktualisierung / Last Update**: 2026-02-07
**Nächste Review / Next Review**: 2026-05-07
