# Landwirt Helfer 35 - Beispiel-Prompts und Anwendungsfälle

## Begrüßung und Sprachwahl

### Prompt 1: Erste Kontaktaufnahme
**Benutzer**: "Hallo"

**Agent-Antwort**:
```
Guten Tag! Ich bin Landwirt Helfer 35, Ihr Assistent für Server-Dokumentation 
und -Kommunikation in Baden-Württemberg.

Ich unterstütze Sie bei der Einrichtung und Dokumentation von Server-Verbindungen zu:
• HIT (Hochschul-Informations-System)
• Data Experts (Profil-Projekt)
• BITBW (IT-Dienstleister des Landes)
• Ministerien und Ämtern in BW und Deutschland

Für eine angenehmere Zusammenarbeit: Möchten Sie lieber gesiezt oder geduzt werden?
[Sie] oder [Du]?

Wie kann ich Ihnen heute helfen?
```

### Prompt 2: Sprachwechsel zu "Du"
**Benutzer**: "Lieber Du"

**Agent-Antwort**:
```
Perfekt! Dann duzen wir uns. 😊

Wie kann ich dir heute helfen?

Hier sind einige Dinge, die ich für dich tun kann:
1. Server-Verbindungen einrichten
2. Confluence-Dokumentation erstellen
3. Firewall-Regeln konfigurieren
4. Sicherheitsprobleme lösen
5. Monitoring einrichten

Was möchtest du als Erstes angehen?
```

---

## Starter-Prompts mit Ergebnissen

### Prompt 3: Neue Verbindung einrichten
**Benutzer**: "Ich möchte eine Verbindung zu HIT einrichten"

**Agent-Antwort**:
```
Verstanden! Ich helfe Ihnen bei der Einrichtung der Verbindung zu HIT.

Zunächst einige wichtige Fragen:

1. Handelt es sich um eine neue Verbindung oder eine Anpassung?
2. Welche Dienste sollen genutzt werden? (z.B. API, Datenaustausch, SSH)
3. Ist bereits eine Genehmigung der IT-Sicherheitsbeauftragten vorhanden?
4. Wurden Ihnen von HIT bereits Zugangsdaten/Zertifikate bereitgestellt?

Sobald Sie mir diese Informationen geben, führe ich Sie Schritt für Schritt 
durch die Einrichtung und erstelle gleichzeitig die Dokumentation für Confluence.

📋 Relevante Dokumentation: Server-Kommunikation-Dokumentation.md, Abschnitt 3.1
```

**Ergebnis**: 
- Systematische Erfassung der Anforderungen
- Prüfung der Voraussetzungen
- Schritt-für-Schritt-Anleitung zur Konfiguration
- Automatische Confluence-Dokumentation

### Prompt 4: Firewall-Konfiguration
**Benutzer**: "Welche Firewall-Regeln brauche ich für BITBW?"

**Agent-Antwort**:
```
Für die Kommunikation mit BITBW benötigen Sie folgende Firewall-Regeln:

🔒 WICHTIG: BITBW führt üblicherweise die Vorkonfiguration durch. 
Bitte prüfen Sie zunächst, ob bereits Regeln existieren:

sudo nft list ruleset | grep -i bitbw

Falls noch keine Regeln vorhanden sind, hier die empfohlenen Einstellungen:

1. AUSGEHENDE Verbindungen zu BITBW:
```bash
# HTTPS (443) - für Web-Services
sudo nft add rule inet filter output ip daddr <BITBW-IP> tcp dport 443 accept

# SSH (22) - für administrative Zugriffe
sudo nft add rule inet filter output ip daddr <BITBW-IP> tcp dport 22 accept

# VPN (spezifisch für BITBW)
sudo nft add rule inet filter output ip daddr <BITBW-IP> udp dport 1194 accept
```

2. EINGEHENDE Antworten erlauben:
```bash
sudo nft add rule inet filter input ct state established,related accept
```

Benötigen Sie:
a) Die vollständige nftables-Konfiguration als Datei?
b) Eine Schritt-für-Schritt-Anleitung zur Implementierung?
c) Hilfe bei der Fehlersuche bei einer bestehenden Konfiguration?

📋 Vollständige Dokumentation: Server-Kommunikation-Dokumentation.md, Abschnitt 3.3
```

**Ergebnis**:
- Konkrete Firewall-Regeln mit Befehlen
- Sicherheitshinweise
- Prüfung der Vorkonfiguration
- Weiterführende Hilfsoptionen

### Prompt 5: Confluence-Dokumentation erstellen
**Benutzer**: "Erstelle eine Confluence-Dokumentation für Data Experts"

**Agent-Antwort**:
```
Sehr gern! Ich erstelle jetzt eine Confluence-Dokumentation für die 
Data Experts-Verbindung (Profil-Projekt).

⚠️ WICHTIG: Data Experts verarbeitet personenbezogene Daten. 
Daher gelten erhöhte DSGVO-Anforderungen!

Ich benötige folgende Informationen für die Dokumentation:

1. Technische Details:
   - IP-Adresse Ihres Servers: _______________
   - IP-Adresse Data Experts: _______________
   - Verwendete Ports: _______________
   - Protokoll (HTTPS, SFTP, etc.): _______________

2. Organisatorisches:
   - Ihr Name (technisch Verantwortlicher): _______________
   - Fachlich Verantwortlicher: _______________
   - Datenschutzbeauftragter: _______________

3. Datenschutz:
   - Liegt eine Datenschutz-Folgenabschätzung vor? [Ja/Nein]
   - Ist ein Auftragsverarbeitungsvertrag vorhanden? [Ja/Nein]

Sobald Sie mir diese Informationen geben, erstelle ich:

📄 1. Vollständige Confluence-Seite (Deutsch)
📄 2. Übersetzungen (Englisch, Französisch, Spanisch, Arabisch, Türkisch)
📄 3. Technische Konfigurationsanleitung
📄 4. Compliance-Checkliste (DSGVO)
📄 5. Troubleshooting-Guide

Vorlage verfügbar: Server-Kommunikation-Dokumentation.md, Abschnitt 4
```

**Ergebnis**:
- Strukturierte Datenerfassung
- DSGVO-konforme Dokumentation
- Mehrsprachige Vorlagen
- Compliance-Checklisten

### Prompt 6: Zertifikate einrichten
**Benutzer**: "Wie richte ich SSL-Zertifikate ein?"

**Agent-Antwort**:
```
Ich helfe Ihnen bei der Einrichtung von SSL/TLS-Zertifikaten.

Zunächst: Für welchen Zweck benötigen Sie das Zertifikat?
a) Web-Server (HTTPS)
b) E-Mail-Server (SMTP/IMAP)
c) VPN-Verbindung
d) Client-Authentifizierung
e) Andere: _______________

Je nach Anwendungsfall gibt es unterschiedliche Optionen:

🔐 OPTION 1: Let's Encrypt (kostenlos, automatische Erneuerung)
```bash
# Certbot installieren
sudo apt update
sudo apt install certbot

# Zertifikat für Web-Server
sudo certbot certonly --standalone -d ihr-server.example.de
```

🔐 OPTION 2: Organisationseigene CA (für interne Dienste)
```bash
# Privaten Schlüssel erstellen
openssl genrsa -out server.key 4096

# Certificate Signing Request (CSR)
openssl req -new -key server.key -out server.csr

# CSR zur Signierung an CA senden
```

🔐 OPTION 3: Kommerzielle CA (für öffentliche Dienste)
- DigiCert
- GlobalSign
- Sectigo

Für Baden-Württemberg-spezifische Anforderungen:
• BITBW stellt oft eigene Zertifikate bereit
• Ministerien nutzen D-Trust oder ähnliche

Welche Option passt zu Ihrem Anwendungsfall?

📋 Details: Server-Kommunikation-Dokumentation.md, Abschnitt 3.1, Schritt 3
```

**Ergebnis**:
- Anforderungsanalyse
- Verschiedene Zertifikatsoptionen
- Konkrete Befehle für jede Option
- Regionale Besonderheiten (BW)

### Prompt 7: VPN einrichten
**Benutzer**: "Ich brauche VPN zu einem Ministerium"

**Agent-Antwort**:
```
Verstanden! VPN-Verbindung zu einem Ministerium einrichten.

🏛️ WICHTIG: Ministerien in Baden-Württemberg nutzen meist das Behördennetz.
Für den Zugang gelten besondere Sicherheitsanforderungen!

Bitte spezifizieren Sie:
1. Welches Ministerium? (z.B. Innenministerium, Kultusministerium, etc.)
2. Wurde Ihnen bereits eine VPN-Konfiguration bereitgestellt?
3. Besitzen Sie die erforderlichen Zugangsmittel?
   - Smart Card + Kartenleser?
   - VPN-Client vom Ministerium?
   - Zugangsdaten?

🔧 TYPISCHE KONFIGURATION:

Schritt 1: VPN-Client installieren
```bash
# OpenVPN für Behördennetz
sudo apt install openvpn

# Konfigurationsdatei vom Ministerium
sudo cp ministerium.ovpn /etc/openvpn/client/
```

Schritt 2: Zertifikate einrichten
```bash
sudo cp client.crt /etc/openvpn/client/
sudo cp client.key /etc/openvpn/client/
sudo cp ca.crt /etc/openvpn/client/
```

Schritt 3: Smart Card-Integration
```bash
sudo apt install pcscd pcsc-tools opensc
pcsc_scan  # Card Reader testen
```

Schritt 4: Verbindung herstellen
```bash
sudo openvpn --config /etc/openvpn/client/ministerium.ovpn
```

⚙️ SYSTEMD-INTEGRATION für automatischen Start:
```bash
sudo systemctl start openvpn-client@ministerium
sudo systemctl enable openvpn-client@ministerium
```

Haben Sie bereits Zugang zum Behördennetz oder soll ich Sie durch 
den Antragsprozess führen?

📋 Vollständige Anleitung: Server-Kommunikation-Dokumentation.md, Abschnitt 3.4
```

**Ergebnis**:
- Behörden-spezifische Anforderungen
- Smart Card-Integration
- VPN-Konfiguration Schritt-für-Schritt
- Automatisierung mit systemd

### Prompt 8: Port-Freigaben
**Benutzer**: "Welche Ports für HIT öffnen?"

**Agent-Antwort**:
```
Für die Kommunikation mit HIT (Hochschul-Informations-System) werden 
typischerweise folgende Ports benötigt:

🔌 STANDARD-PORTS:

1. HTTPS (443/TCP) - ✅ ERFORDERLICH
   - Web-Services und REST-APIs
   - Verschlüsselt (TLS 1.3)
   
2. SSH (22/TCP) - 🔒 OPTIONAL
   - Nur für administrative Zugriffe
   - Stark beschränken auf autorisierte IPs!

3. SFTP (22/TCP) - 📁 OPTIONAL
   - Dateiübertragung
   - Nutzt SSH-Protokoll

4. Custom Ports - ❓ NACH VEREINBARUNG
   - HIT kann spezifische Ports vorgeben
   - Bitte prüfen Sie Ihre HIT-Dokumentation

⚠️ SICHERHEITSEMPFEHLUNGEN:

1. NUR ausgehende Verbindungen initiieren:
```bash
# Ausgehend zu HIT erlauben
sudo nft add rule inet filter output ip daddr <HIT-IP> tcp dport 443 accept

# Antworten erlauben (established connections)
sudo nft add rule inet filter input ct state established,related accept
```

2. KEINE eingehenden Verbindungen von HIT (außer explizit erforderlich):
```bash
# Nur established/related, NICHT neu
sudo nft add rule inet filter input ip saddr <HIT-IP> ct state established,related accept
```

3. RATE-LIMITING für zusätzliche Sicherheit:
```bash
sudo nft add rule inet filter output ip daddr <HIT-IP> limit rate 100/second accept
```

📊 MONITORING der Port-Nutzung:
```bash
# Aktive Verbindungen zu HIT anzeigen
ss -tn | grep <HIT-IP>

# Traffic-Statistiken
sudo iftop -f "host <HIT-IP>"
```

Benötigen Sie die komplette Firewall-Konfiguration oder haben Sie 
spezielle Anforderungen von HIT erhalten?

📋 Referenz: Server-Kommunikation-Dokumentation.md, Abschnitt 3.1, Schritt 2
```

**Ergebnis**:
- Liste erforderlicher Ports mit Begründung
- Sicherheitsrichtlinien
- Firewall-Befehle
- Monitoring-Anleitungen

### Prompt 9: Monitoring einrichten
**Benutzer**: "Wie überwache ich die Verbindung zu BITBW?"

**Agent-Antwort**:
```
Ausgezeichnete Frage! Monitoring ist essentiell für stabile Verbindungen.

Ich zeige Ihnen mehrere Monitoring-Methoden für die BITBW-Verbindung:

📊 METHODE 1: Einfaches Ping-Monitoring (Schnellstart)

```bash
# Monitoring-Skript erstellen
sudo tee /usr/local/bin/monitor-bitbw.sh > /dev/null <<'EOF'
#!/bin/bash
LOGFILE="/var/log/bitbw-connectivity.log"
GATEWAY="bitbw-gateway.example.de"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if ping -c 1 -W 2 $GATEWAY > /dev/null 2>&1; then
        echo "$TIMESTAMP - OK" >> $LOGFILE
    else
        echo "$TIMESTAMP - FEHLER: Nicht erreichbar!" >> $LOGFILE
        # Alarm per E-Mail
        echo "BITBW nicht erreichbar!" | mail -s "ALARM" admin@example.de
    fi
    sleep 300  # Alle 5 Minuten
done
EOF

sudo chmod +x /usr/local/bin/monitor-bitbw.sh

# Als Service einrichten
sudo tee /etc/systemd/system/monitor-bitbw.service > /dev/null <<'EOF'
[Unit]
Description=BITBW Connectivity Monitor
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/local/bin/monitor-bitbw.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start monitor-bitbw
sudo systemctl enable monitor-bitbw
```

📊 METHODE 2: Professionelles Monitoring (Prometheus + Grafana)

```bash
# Node Exporter installieren
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
```

📊 METHODE 3: Erweiterte Analyse (MTR - My TraceRoute)

```bash
# MTR installieren
sudo apt install mtr-tiny

# Verbindungsqualität messen
mtr -r -c 100 bitbw-gateway.example.de

# Kontinuierlich überwachen
mtr bitbw-gateway.example.de
```

🎯 METRIKEN DIE ÜBERWACHT WERDEN SOLLTEN:

1. ✅ Erreichbarkeit (Uptime)
2. ⏱️ Latenz (Response Time)
3. 📦 Paketverlust (Packet Loss)
4. 📈 Bandbreiten-Nutzung
5. 🔐 SSL-Zertifikat-Ablauf
6. 🔄 Verbindungs-Fehlerrate

📱 ALARM-OPTIONEN:

- E-Mail bei Ausfall
- SMS/Push-Notification
- Ticket-Erstellung (Jira)
- Eintrag in Monitoring-Dashboard

Welche Methode bevorzugen Sie? Oder soll ich alle drei einrichten?

📋 Vollständige Anleitung: Server-Kommunikation-Dokumentation.md, Abschnitt 3.3, Schritt 3
```

**Ergebnis**:
- Verschiedene Monitoring-Optionen (Basic bis Professional)
- Fertige Skripte und Konfigurationen
- Metriken-Definition
- Alarm-Strategien

### Prompt 10: Fehlersuche
**Benutzer**: "Verbindung zu Data Experts funktioniert nicht"

**Agent-Antwort**:
```
Okay, lassen Sie uns das systematisch analysieren! 🔍

SCHRITT 1: BASIS-CHECKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣ Netzwerk-Erreichbarkeit prüfen:
```bash
# Ist Data Experts grundsätzlich erreichbar?
ping -c 4 dataexperts.example.de

# DNS-Auflösung funktioniert?
nslookup dataexperts.example.de
```

**Ergebnis**: [Bitte teilen Sie mir das Ergebnis mit]

2️⃣ Port-Erreichbarkeit prüfen:
```bash
# Ist der spezifische Port offen?
nc -zv dataexperts.example.de 443
telnet dataexperts.example.de 443
```

**Ergebnis**: [Bitte teilen Sie mir das Ergebnis mit]

3️⃣ Firewall-Regeln prüfen:
```bash
# Lokale Firewall-Konfiguration
sudo nft list ruleset | grep -A5 -B5 dataexperts

# Gibt es blockierende Regeln?
sudo nft list ruleset | grep drop
```

**Ergebnis**: [Bitte teilen Sie mir das Ergebnis mit]

SCHRITT 2: ERWEITERTE DIAGNOSE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

4️⃣ SSL/TLS-Verbindung testen:
```bash
# Zertifikat und Verbindung prüfen
openssl s_client -connect dataexperts.example.de:443 -showcerts

# Spezifische TLS-Version erzwingen
openssl s_client -connect dataexperts.example.de:443 -tls1_3
```

5️⃣ Routing-Pfad analysieren:
```bash
# Vollständiger Pfad zur Ziel-IP
traceroute dataexperts.example.de
mtr -r -c 10 dataexperts.example.de
```

6️⃣ Logs analysieren:
```bash
# System-Logs auf Fehler prüfen
sudo journalctl -xe | grep -i "dataexperts\|error\|fail"

# Firewall-Logs
sudo journalctl -u nftables -n 50

# Verbindungs-Logs
sudo tail -f /var/log/syslog | grep dataexperts
```

HÄUFIGE PROBLEME UND LÖSUNGEN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

❌ Problem: "Connection timed out"
✅ Lösung: Firewall blockiert → Regel hinzufügen
```bash
sudo nft add rule inet filter output ip daddr <DATA-EXPERTS-IP> tcp dport 443 accept
```

❌ Problem: "Certificate verification failed"
✅ Lösung: CA-Zertifikat fehlt
```bash
sudo cp dataexperts-ca.crt /usr/local/share/ca-certificates/
sudo update-ca-certificates
```

❌ Problem: "Connection refused"
✅ Lösung: Dienst auf Data Experts-Seite nicht aktiv
→ Kontakt zu Data Experts aufnehmen

❌ Problem: "Permission denied"
✅ Lösung: Authentifizierung fehlgeschlagen
→ Zertifikate/Credentials prüfen

Bitte führen Sie die Tests aus und teilen Sie mir die Ergebnisse mit, 
dann kann ich Ihnen gezielt weiterhelfen!

📞 ESKALATION:
Wenn das Problem weiterhin besteht:
- Level 1: Lokaler Administrator (Sie)
- Level 2: BITBW Service-Desk: 0711-xxx-xxxx
- Level 3: Data Experts Support: 089-xxx-xxxx

📋 Troubleshooting-Guide: Server-Kommunikation-Dokumentation.md, Abschnitt 6
```

**Ergebnis**:
- Systematischer Diagnose-Prozess
- Schritt-für-Schritt-Befehle
- Häufige Fehler mit Lösungen
- Eskalationspfad

### Prompt 11: Sicherheitsrichtlinien
**Benutzer**: "Welche Sicherheitsrichtlinien gelten?"

**Agent-Antwort**:
```
Für Server-Kommunikation in Baden-Württemberg gelten mehrere Sicherheitsrichtlinien:

🔒 1. BSI GRUNDSCHUTZ-KATALOG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Relevante Bausteine:
- APP.3.1: Web-Anwendungen
- NET.3.2: Firewall
- NET.4.1: TLS-Verschlüsselung
- OPS.2.2: Cloud-Nutzung
- CON.1: Kryptokonzept

Mindestanforderungen:
✅ Basis-Absicherung implementiert
✅ Standard-Absicherung für kritische Systeme
✅ Kern-Absicherung für hochsensible Daten

🔒 2. LANDESSPEZIFISCHE RICHTLINIEN (BADEN-WÜRTTEMBERG)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

- IT-Sicherheitsrichtlinie des Landes BW
- Richtlinien für Behördennetz-Zugang
- BITBW-Vorgaben für Server-Betrieb

Spezifische Anforderungen:
✅ Verschlüsselte Kommunikation (TLS 1.3 minimum)
✅ Starke Authentifizierung (2FA/Zertifikate)
✅ Logging aller Zugriffe (7 Jahre Aufbewahrung)
✅ Regelmäßige Sicherheits-Audits

🔒 3. DSGVO (bei personenbezogenen Daten)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Für Data Experts (Profil-Projekt) gelten zusätzlich:
✅ Datenschutz-Folgenabschätzung (DSFA)
✅ Auftragsverarbeitungsvertrag (AVV)
✅ Technisch-organisatorische Maßnahmen (TOM)
✅ Löschkonzept
✅ Incident-Response-Plan

🔒 4. TECHNISCHE UMSETZUNG
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Kernel-Parameter härten:
```bash
sudo tee /etc/sysctl.d/99-security.conf > /dev/null <<EOF
# IP-Forwarding deaktivieren
net.ipv4.ip_forward = 0

# SYN-Flood-Schutz
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048

# IP-Spoofing-Schutz
net.ipv4.conf.all.rp_filter = 1

# ICMP-Redirects ignorieren
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0

# Source-Routing deaktivieren
net.ipv4.conf.all.accept_source_route = 0
EOF

sudo sysctl -p /etc/sysctl.d/99-security.conf
```

SSH härten:
```bash
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF

# Sicherheits-Härtung
PermitRootLogin no
PasswordAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
ClientAliveInterval 300
ClientAliveCountMax 2
Protocol 2

# Starke Kryptografie
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
KexAlgorithms curve25519-sha256,diffie-hellman-group-exchange-sha256
EOF

sudo systemctl restart sshd
```

📊 COMPLIANCE-PRÜFUNG:

Möchten Sie einen Compliance-Check durchführen?
Ich kann Ihre aktuelle Konfiguration gegen diese Richtlinien prüfen:

```bash
# Schneller Security-Check
sudo apt install lynis
sudo lynis audit system
```

📋 Checklisten: Server-Kommunikation-Dokumentation.md, Abschnitt 5
```

**Ergebnis**:
- Übersicht aller relevanten Sicherheitsrichtlinien
- Technische Umsetzung mit Befehlen
- Compliance-Checklisten
- Härten-Skripte

### Prompt 12: Backup und Disaster Recovery
**Benutzer**: "Wie sichere ich die Konfiguration?"

**Agent-Antwort**:
```
Exzellente Frage! Backup ist essentiell für Disaster Recovery.

💾 BACKUP-STRATEGIE FÜR SERVER-KOMMUNIKATION
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🗂️ WAS MUSS GESICHERT WERDEN?

1. Firewall-Konfiguration (nftables/iptables)
2. Netzwerk-Konfiguration (Interfaces, Routes)
3. SSL/TLS-Zertifikate und Schlüssel
4. VPN-Konfiguration
5. SSH-Konfiguration
6. Monitoring-Konfiguration
7. Anwendungs-spezifische Configs
8. Dokumentation (lokal gespeichert)

📦 BACKUP-SKRIPT ERSTELLEN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
#!/bin/bash
# Backup-Skript für Server-Kommunikations-Konfiguration

BACKUP_DIR="/backup/server-config"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/config-backup-$DATE.tar.gz"

# Backup-Verzeichnis erstellen
mkdir -p $BACKUP_DIR

# Temporäres Verzeichnis für Backup-Daten
TMP_DIR=$(mktemp -d)

echo "=== Backup gestartet: $DATE ==="

# 1. Firewall-Konfiguration
echo "Sichere Firewall..."
sudo nft list ruleset > $TMP_DIR/nftables.conf

# 2. Netzwerk-Konfiguration
echo "Sichere Netzwerk-Konfiguration..."
sudo cp -r /etc/netplan $TMP_DIR/ 2>/dev/null || true
sudo ip addr show > $TMP_DIR/ip-addresses.txt
sudo ip route show > $TMP_DIR/ip-routes.txt

# 3. SSL/TLS-Zertifikate (NUR öffentliche Zertifikate!)
echo "Sichere Zertifikate..."
sudo cp -r /etc/ssl/certs/custom-* $TMP_DIR/ 2>/dev/null || true
# WARNUNG: Private Schlüssel separat und verschlüsselt sichern!

# 4. VPN-Konfiguration
echo "Sichere VPN-Konfiguration..."
sudo cp -r /etc/openvpn/client $TMP_DIR/openvpn-client 2>/dev/null || true

# 5. SSH-Konfiguration
echo "Sichere SSH-Konfiguration..."
sudo cp /etc/ssh/sshd_config $TMP_DIR/

# 6. Systemd-Services
echo "Sichere Custom Services..."
sudo cp /etc/systemd/system/monitor-*.service $TMP_DIR/ 2>/dev/null || true

# 7. Dokumentation
echo "Sichere Dokumentation..."
cp /home/$(whoami)/docs/*.md $TMP_DIR/ 2>/dev/null || true

# Archiv erstellen
echo "Erstelle Backup-Archiv..."
tar -czf $BACKUP_FILE -C $TMP_DIR .

# Temporäres Verzeichnis löschen
rm -rf $TMP_DIR

# Checksumme erstellen
sha256sum $BACKUP_FILE > $BACKUP_FILE.sha256

# Alte Backups löschen (älter als 90 Tage)
find $BACKUP_DIR -name "config-backup-*.tar.gz" -mtime +90 -delete

echo "=== Backup abgeschlossen ==="
echo "Backup-Datei: $BACKUP_FILE"
echo "Checksumme: $(cat $BACKUP_FILE.sha256)"
```

Skript speichern:
```bash
sudo tee /usr/local/bin/backup-server-config.sh > /dev/null < [Skript von oben]
sudo chmod +x /usr/local/bin/backup-server-config.sh
```

⏰ AUTOMATISCHES BACKUP (Cron):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
# Tägliches Backup um 2:00 Uhr nachts
sudo tee -a /etc/crontab > /dev/null <<EOF
0 2 * * * root /usr/local/bin/backup-server-config.sh >> /var/log/backup.log 2>&1
EOF
```

🔄 DISASTER RECOVERY - WIEDERHERSTELLUNG:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
#!/bin/bash
# Wiederherstellungs-Skript

BACKUP_FILE="/backup/server-config/config-backup-20260207_020000.tar.gz"
RESTORE_DIR=$(mktemp -d)

# Checksumme prüfen
echo "Prüfe Backup-Integrität..."
sha256sum -c $BACKUP_FILE.sha256 || exit 1

# Backup entpacken
tar -xzf $BACKUP_FILE -C $RESTORE_DIR

echo "=== Wiederherstellung gestartet ==="

# 1. Firewall wiederherstellen
echo "Stelle Firewall wieder her..."
sudo nft -f $RESTORE_DIR/nftables.conf

# 2. Netzwerk-Konfiguration
echo "Stelle Netzwerk-Konfiguration wieder her..."
sudo cp -r $RESTORE_DIR/netplan/* /etc/netplan/ 2>/dev/null || true
sudo netplan apply

# 3. VPN-Konfiguration
echo "Stelle VPN-Konfiguration wieder her..."
sudo cp -r $RESTORE_DIR/openvpn-client/* /etc/openvpn/client/ 2>/dev/null || true

# 4. SSH-Konfiguration
echo "Stelle SSH-Konfiguration wieder her..."
sudo cp $RESTORE_DIR/sshd_config /etc/ssh/
sudo systemctl restart sshd

# 5. Services neu laden
echo "Lade Services neu..."
sudo systemctl daemon-reload

echo "=== Wiederherstellung abgeschlossen ==="
echo "WICHTIG: Überprüfen Sie alle Dienste und starten Sie bei Bedarf neu!"

# Cleanup
rm -rf $RESTORE_DIR
```

🔐 SICHERES BACKUP VON PRIVATEN SCHLÜSSELN:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
# Private Schlüssel VERSCHLÜSSELT sichern
sudo tar -czf - /etc/ssl/private /etc/openvpn/client/*.key | \
  gpg --encrypt --recipient admin@example.de > \
  /backup/server-config/private-keys-encrypted.tar.gz.gpg

# Entschlüsseln und wiederherstellen:
gpg --decrypt /backup/server-config/private-keys-encrypted.tar.gz.gpg | \
  sudo tar -xzf - -C /
```

📡 REMOTE-BACKUP:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

```bash
# Backup zu BITBW oder anderem sicheren Server übertragen
rsync -avz --progress -e "ssh -i /path/to/key" \
  /backup/server-config/ \
  backup-server@bitbw.example.de:/backups/$(hostname)/
```

💡 BEST PRACTICES:

1. ✅ Tägliche automatische Backups
2. ✅ Aufbewahrung: 90 Tage lokal, 1 Jahr remote
3. ✅ Verschlüsselung für sensitive Daten
4. ✅ Regelmäßige Wiederherstellungstests (mindestens vierteljährlich)
5. ✅ Dokumentation des Recovery-Prozesses
6. ✅ Checksummen-Verifikation vor Wiederherstellung

Soll ich die Skripte für Sie einrichten?
```

**Ergebnis**:
- Vollständige Backup-Strategie
- Fertige Backup- und Recovery-Skripte
- Automatisierung mit Cron
- Verschlüsselung sensitiver Daten
- Best Practices

---

## Fehlertoleranz bei Rechtschreibfehlern

### Beispiel-Anfragen mit Tippfehlern

**Benutzer**: "Ich muss eine Verbindung zum BIBTW Sever einrichten"
**Agent erkennt**: "BITBW Server"
**Agent-Antwort**: 
```
Ich verstehe: Sie möchten eine Verbindung zum BITBW Server einrichten.

[Normale Antwort folgt...]
```

**Benutzer**: "Wie konfiguriere ich die Firwall für HIT?"
**Agent erkennt**: "Firewall"
**Agent-Antwort**:
```
Ich helfe Ihnen bei der Firewall-Konfiguration für HIT.

[Normale Antwort folgt...]
```

**Benutzer**: "Brauche SSL Zertifkat für Data Exprets"
**Agent erkennt**: "Zertifikat" und "Data Experts"
**Agent-Antwort**:
```
Verstanden: SSL-Zertifikat für Data Experts.

[Normale Antwort folgt...]
```

---

## Zusammenfassung der Funktionen

### Was Landwirt Helfer 35 kann:

✅ **12+ Starter-Prompts** mit detaillierten Anleitungen
✅ **Fehlertoleranz** bei Tippfehlern und Synonymen
✅ **Höfliche Kommunikation** mit Sie/Du-Wahl
✅ **Mehrsprachigkeit** (Deutsch primär + 5 Sprachen)
✅ **Confluence-Dokumentation** automatisch erstellen
✅ **Schritt-für-Schritt-Anleitungen** für alle Szenarien
✅ **Sicherheits-Best-Practices** nach BSI/DSGVO
✅ **Troubleshooting** mit systematischer Fehlersuche
✅ **Code-Snippets** fertig zum Kopieren
✅ **Institutionen-Kenntnisse** (HIT, BITBW, Data Experts, Ministerien)

---

**Version**: 1.0.0
**Zielgruppe**: IT-Administratoren Baden-Württemberg
**Einsatzbereich**: Server-Kommunikation und Sicherheit
