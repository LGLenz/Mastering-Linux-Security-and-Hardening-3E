# Server-Kommunikation Dokumentation
## Baden-Württemberg Infrastruktur

### Übersicht

Diese Dokumentation beschreibt die Einrichtung und Verwaltung der Server-Kommunikation zwischen lokalen Servern in Baden-Württemberg und externen Partnern/Institutionen.

---

## 1. Beteiligte Institutionen

### 1.1 HIT (Hochschul-Informations-System GmbH)
- **Zweck**: IT-Dienstleistungen für Hochschulen
- **Kommunikationsart**: HTTPS, SSH, VPN
- **Sicherheitsstufe**: Hoch
- **Dokumentation**: [HIT-Verbindung einrichten](#hit-verbindung)

### 1.2 Data Experts (Profil-Projekt)
- **Zweck**: Datenverarbeitung und Analyseprojekte
- **Kommunikationsart**: HTTPS, SFTP
- **Sicherheitsstufe**: Sehr hoch (personenbezogene Daten)
- **Dokumentation**: [Data Experts-Verbindung](#data-experts)

### 1.3 BITBW (IT-Dienstleister des Landes Baden-Württemberg)
- **Zweck**: Zentrale IT-Infrastruktur BW
- **Kommunikationsart**: Dedizierte Leitungen, VPN
- **Sicherheitsstufe**: Sehr hoch
- **Dokumentation**: [BITBW-Verbindung](#bitbw-verbindung)

### 1.4 Ministerien und Ämter
- **Zweck**: Behördenkommunikation
- **Kommunikationsart**: Behördennetz, VPN
- **Sicherheitsstufe**: Sehr hoch
- **Dokumentation**: [Ministerien-Verbindung](#ministerien)

---

## 2. Sicherheitsanforderungen

### 2.1 Grundlegende Anforderungen
- BSI Grundschutz-Katalog konform
- Verschlüsselte Übertragung (TLS 1.3 oder höher)
- Starke Authentifizierung (Zertifikate, 2FA)
- Logging und Monitoring aller Verbindungen
- Regelmäßige Sicherheitsaudits

### 2.2 Netzwerk-Segmentierung
```
┌─────────────────────────────────────────────┐
│           Lokaler Server (BW)               │
│                                             │
│  ┌──────────────────────────────────────┐  │
│  │  DMZ (Demilitarisierte Zone)         │  │
│  │  - Reverse Proxy                     │  │
│  │  - Firewall                          │  │
│  │  - IDS/IPS                           │  │
│  └──────────────────────────────────────┘  │
│                   │                         │
└───────────────────┼─────────────────────────┘
                    │
         ┌──────────┴──────────┐
         │                     │
    ┌────▼─────┐         ┌────▼─────┐
    │   HIT    │         │  BITBW   │
    └──────────┘         └──────────┘
         │                     │
    ┌────▼─────┐         ┌────▼─────┐
    │   Data   │         │Ministerien│
    │ Experts  │         │   Ämter   │
    └──────────┘         └──────────┘
```

### 2.3 Firewall-Regeln (nftables)
```bash
#!/usr/sbin/nft -f

# Firewall-Konfiguration für externe Kommunikation
flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback erlauben
        iif lo accept
        
        # Etablierte Verbindungen
        ct state established,related accept
        
        # SSH von spezifischen IPs
        ip saddr { 192.168.100.0/24 } tcp dport 22 accept
        
        # HTTPS für externe Dienste
        tcp dport 443 accept
        
        # ICMP für Monitoring
        icmp type echo-request limit rate 5/second accept
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
        
        # Logging ausgehender Verbindungen
        log prefix "OUT: "
    }
}
```

---

## 3. Schritt-für-Schritt-Anleitungen

### 3.1 HIT-Verbindung einrichten {#hit-verbindung}

#### Voraussetzungen
- [x] Genehmigung der IT-Sicherheitsbeauftragten
- [x] Netzwerkfreigabe von BITBW
- [x] SSL-Zertifikate von vertrauenswürdiger CA
- [x] Dokumentierter Zweck der Verbindung

#### Schritt 1: Netzwerkkonfiguration prüfen
```bash
# IP-Konfiguration anzeigen
ip addr show

# Routing-Tabelle prüfen
ip route show

# DNS-Auflösung testen
nslookup hit.server.example.de

# Erreichbarkeit prüfen (wenn Firewall offen)
ping -c 4 hit.server.example.de
```

#### Schritt 2: Firewall-Regeln hinzufügen
```bash
# Backup der aktuellen Konfiguration
sudo nft list ruleset > /etc/nftables.conf.backup

# HIT-spezifische Regel hinzufügen
sudo nft add rule inet filter output ip daddr 203.0.113.100 tcp dport 443 accept
sudo nft add rule inet filter input ip saddr 203.0.113.100 tcp sport 443 ct state established accept

# Konfiguration speichern
sudo nft list ruleset > /etc/nftables.conf

# Firewall neu laden
sudo systemctl restart nftables
```

#### Schritt 3: SSL/TLS-Verbindung einrichten
```bash
# Zertifikate installieren
sudo cp hit-ca-cert.pem /usr/local/share/ca-certificates/hit-ca.crt
sudo update-ca-certificates

# Verbindung testen
openssl s_client -connect hit.server.example.de:443 -showcerts

# Zertifikat-Details prüfen
openssl x509 -in hit-ca-cert.pem -text -noout
```

#### Schritt 4: Monitoring einrichten
```bash
# Netdata für Monitoring installieren
sudo apt update
sudo apt install netdata

# Prometheus Node Exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.7.0/node_exporter-1.7.0.linux-amd64.tar.gz
tar xvfz node_exporter-1.7.0.linux-amd64.tar.gz
sudo cp node_exporter-1.7.0.linux-amd64/node_exporter /usr/local/bin/
sudo useradd -rs /bin/false node_exporter

# Systemd-Service erstellen
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Node Exporter
After=network.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start node_exporter
sudo systemctl enable node_exporter
```

#### Schritt 5: Logging konfigurieren
```bash
# rsyslog für zentrale Logs
sudo tee -a /etc/rsyslog.d/50-hit-connection.conf > /dev/null <<EOF
# HIT-Verbindungs-Logs
:msg, contains, "HIT" /var/log/hit-connection.log
& stop
EOF

# rsyslog neu starten
sudo systemctl restart rsyslog

# Log-Rotation einrichten
sudo tee /etc/logrotate.d/hit-connection > /dev/null <<EOF
/var/log/hit-connection.log {
    daily
    rotate 90
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
}
EOF
```

#### Schritt 6: Verbindungstest
```bash
# Verbindung testen mit curl
curl -v https://hit.server.example.de/health

# Ausführlicher Test mit allen Headers
curl -v -H "User-Agent: LGL-BW-Server/1.0" https://hit.server.example.de/api/status

# Performance-Test
time curl -s https://hit.server.example.de/ > /dev/null
```

#### Schritt 7: Dokumentation in Confluence
1. Confluence-Seite erstellen unter: "IT-Infrastruktur > Server-Kommunikation > HIT"
2. Vorlage verwenden (siehe Abschnitt 4)
3. Alle technischen Details eintragen
4. Screenshots der Konfiguration hinzufügen
5. Übersetzungen aktivieren oder manuell hinzufügen
6. Review-Prozess durchführen
7. Seite veröffentlichen

---

### 3.2 Data Experts-Verbindung (Profil-Projekt) {#data-experts}

#### Besondere Sicherheitsanforderungen
- DSGVO-Konformität (personenbezogene Daten)
- Verschlüsselte Datenübertragung (Ende-zu-Ende)
- Audit-Trail für alle Zugriffe
- Beschränkter Zugriff (nur autorisierte Benutzer)

#### Schritt 1: Rechtliche Grundlagen prüfen
- Datenschutz-Folgenabschätzung durchgeführt?
- Auftragsverarbeitungsvertrag vorhanden?
- Technisch-organisatorische Maßnahmen dokumentiert?
- Löschkonzept definiert?

#### Schritt 2: Sichere Datenübertragung einrichten
```bash
# SFTP-Server konfigurieren
sudo apt install openssh-server

# SFTP-Gruppe erstellen
sudo groupadd sftponly

# Benutzer für Data Experts
sudo useradd -m -g sftponly -s /bin/false dataexperts
sudo passwd dataexperts

# SSH-Konfiguration anpassen
sudo tee -a /etc/ssh/sshd_config > /dev/null <<EOF

# Data Experts SFTP-Konfiguration
Match Group sftponly
    ChrootDirectory /home/%u
    ForceCommand internal-sftp
    AllowTcpForwarding no
    X11Forwarding no
    PasswordAuthentication no
    PubkeyAuthentication yes
EOF

# SSH neu starten
sudo systemctl restart sshd
```

#### Schritt 3: Verschlüsselung auf Dateiebene
```bash
# GPG für zusätzliche Verschlüsselung
sudo apt install gnupg

# Schlüsselpaar generieren
gpg --full-generate-key

# Öffentlichen Schlüssel exportieren für Data Experts
gpg --export -a "Data Experts Transfer" > dataexperts-public-key.asc

# Daten verschlüsseln vor Übertragung
gpg --encrypt --recipient "Data Experts Transfer" sensible-daten.csv
```

#### Schritt 4: Audit-Logging
```bash
# Erweiterte Audit-Regeln
sudo apt install auditd

# Audit-Regeln für SFTP-Zugriffe
sudo tee -a /etc/audit/rules.d/sftp-access.rules > /dev/null <<EOF
# Überwachung SFTP-Verzeichnis
-w /home/dataexperts/ -p warx -k dataexperts_access

# Überwachung SSH-Verbindungen
-w /var/log/auth.log -p wa -k auth_log
EOF

# Audit-System neu laden
sudo augenrules --load
sudo systemctl restart auditd
```

---

### 3.3 BITBW-Verbindung {#bitbw-verbindung}

#### Hinweis
BITBW führt die Vorkonfiguration durch. Diese Dokumentation beschreibt die Überprüfung und Anpassung.

#### Schritt 1: Vorkonfiguration überprüfen
```bash
# Von BITBW konfigurierte Interfaces prüfen
ip link show

# VPN-Verbindung Status
sudo wg show  # Für WireGuard
# oder
sudo ipsec status  # Für IPSec

# Routing zu BITBW-Netzen
ip route show | grep bitbw
```

#### Schritt 2: Zusätzliche Sicherheitshärtung
```bash
# Kernel-Parameter für Netzwerk-Sicherheit
sudo tee -a /etc/sysctl.d/99-bitbw-security.conf > /dev/null <<EOF
# IP-Forwarding deaktivieren (wenn nicht benötigt)
net.ipv4.ip_forward = 0

# SYN-Flood-Schutz
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 2048

# IP-Spoofing-Schutz
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1

# ICMP-Redirect ignorieren
net.ipv4.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0

# Source-Routing deaktivieren
net.ipv4.conf.all.accept_source_route = 0
EOF

sudo sysctl -p /etc/sysctl.d/99-bitbw-security.conf
```

#### Schritt 3: Monitoring der BITBW-Verbindung
```bash
# Verbindungsqualität überwachen
sudo apt install mtr-tiny

# Kontinuierliches Monitoring
mtr -r -c 100 bitbw-gateway.example.de > /var/log/bitbw-mtr.log

# Skript für automatisches Monitoring
sudo tee /usr/local/bin/monitor-bitbw.sh > /dev/null <<'EOF'
#!/bin/bash
LOGFILE="/var/log/bitbw-connectivity.log"
GATEWAY="bitbw-gateway.example.de"

while true; do
    TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
    if ping -c 1 -W 2 $GATEWAY > /dev/null 2>&1; then
        echo "$TIMESTAMP - OK: BITBW erreichbar" >> $LOGFILE
    else
        echo "$TIMESTAMP - FEHLER: BITBW nicht erreichbar!" >> $LOGFILE
        # Benachrichtigung senden
        echo "BITBW-Verbindung unterbrochen!" | mail -s "ALARM: BITBW" admin@example.de
    fi
    sleep 300  # Alle 5 Minuten
done
EOF

sudo chmod +x /usr/local/bin/monitor-bitbw.sh

# Systemd-Service
sudo tee /etc/systemd/system/monitor-bitbw.service > /dev/null <<EOF
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

---

### 3.4 Ministerien und Ämter {#ministerien}

#### Behördennetz-Anforderungen
- Zugang über Behördennetz (geschlossenes Netz)
- Starke Authentifizierung (Smart Card, 2FA)
- Protokollierung nach Aufbewahrungspflichten
- Einhaltung des Onlinezugangsgesetzes (OZG)

#### Schritt 1: Zugang zum Behördennetz
```bash
# VPN-Client für Behördennetz installieren
# (Spezifischer Client abhängig von Ministerium)

# Beispiel: OpenVPN-Konfiguration
sudo apt install openvpn

# Konfigurationsdatei vom Ministerium
sudo cp ministerium.ovpn /etc/openvpn/client/

# Client-Zertifikate installieren
sudo cp client.crt /etc/openvpn/client/
sudo cp client.key /etc/openvpn/client/
sudo cp ca.crt /etc/openvpn/client/

# VPN-Verbindung starten
sudo systemctl start openvpn-client@ministerium
sudo systemctl enable openvpn-client@ministerium
```

#### Schritt 2: Smart Card-Integration
```bash
# Erforderliche Pakete
sudo apt install pcscd pcsc-tools opensc

# Smart Card-Reader testen
pcsc_scan

# OpenSSH mit Smart Card
sudo tee -a /etc/ssh/ssh_config > /dev/null <<EOF

# Smart Card-Authentifizierung
PKCS11Provider /usr/lib/x86_64-linux-gnu/opensc-pkcs11.so
EOF
```

#### Schritt 3: Compliance-Logging
```bash
# Erweiterte Logging-Regeln für Compliance
sudo tee /etc/rsyslog.d/80-ministerium-compliance.conf > /dev/null <<EOF
# Alle Zugriffe auf Ministerium-Dienste loggen
:msg, contains, "MINISTERIUM" /var/log/ministerium-access.log
:msg, contains, "MINISTERIUM" @@log-server.example.de:514

# Lokale Kopie für Audit
:msg, contains, "MINISTERIUM" /var/log/audit/ministerium-audit.log
& stop
EOF

# Log-Rotation mit langer Aufbewahrung (7 Jahre für Behörden)
sudo tee /etc/logrotate.d/ministerium-compliance > /dev/null <<EOF
/var/log/ministerium-access.log
/var/log/audit/ministerium-audit.log {
    daily
    rotate 2555  # 7 Jahre
    compress
    delaycompress
    missingok
    notifempty
    create 0640 root adm
    sharedscripts
    postrotate
        # Nach Rotation: Integrity-Check
        sha256sum /var/log/ministerium-access.log.1.gz >> /var/log/audit/log-integrity.txt
    endscript
}
EOF
```

---

## 4. Confluence-Dokumentationsvorlage

### Vorlage: Server-Kommunikationseinrichtung

```markdown
# Server-Kommunikation: [Quellserver] → [Zielserver]

**Erstellt**: [Datum]
**Autor**: [Name]
**Version**: 1.0
**Status**: ✅ Aktiv / 🔄 In Bearbeitung / ⚠️ Veraltet

---

## 1. Übersicht

### 1.1 Zweck der Verbindung
[Beschreibung, warum diese Verbindung benötigt wird]

### 1.2 Beteiligte Systeme
- **Quellserver**: [Hostname, IP-Adresse]
- **Zielserver**: [Hostname, IP-Adresse]
- **Protokolle**: [z.B. HTTPS, SSH, SFTP]

### 1.3 Verantwortliche
- **Technisch**: [Name, E-Mail, Telefon]
- **Fachlich**: [Name, E-Mail, Telefon]
- **Datenschutz**: [Name, E-Mail, Telefon]

---

## 2. Technische Spezifikation

### 2.1 Netzwerkdetails
| Parameter | Wert |
|-----------|------|
| Quell-IP | x.x.x.x |
| Ziel-IP | y.y.y.y |
| Ports | TCP 443, TCP 22 |
| Protokoll | HTTPS, SSH |
| Verschlüsselung | TLS 1.3 |

### 2.2 Authentifizierung
- **Methode**: [Zertifikat / SSH-Key / Passwort + 2FA]
- **Zertifikats-CA**: [Name der Certificate Authority]
- **Gültigkeit**: [Start- und Enddatum]

### 2.3 Sicherheitszonen
```
[DMZ] ←→ [Firewall] ←→ [Externes Netz]
```

---

## 3. Einrichtungsanleitung

### 3.1 Voraussetzungen
- [ ] Sicherheitsgenehmigung vorhanden
- [ ] Netzwerkfreigabe erteilt
- [ ] Zertifikate bereitgestellt
- [ ] Backup erstellt

### 3.2 Schritt-für-Schritt
[Detaillierte Anleitung gemäß Abschnitt 3]

### 3.3 Verifizierung
```bash
# Test-Kommandos
[Befehle zum Testen der Verbindung]
```

---

## 4. Sicherheit und Compliance

### 4.1 Angewandte Sicherheitsmaßnahmen
- ✅ Verschlüsselte Übertragung
- ✅ Firewall-Regeln aktiv
- ✅ Intrusion Detection aktiviert
- ✅ Logging konfiguriert
- ✅ Monitoring eingerichtet

### 4.2 Compliance
- ✅ BSI Grundschutz-Katalog
- ✅ DSGVO (bei personenbezogenen Daten)
- ✅ Landesrichtlinien Baden-Württemberg

### 4.3 Audit-Trail
[Speicherort und Aufbewahrungsdauer der Logs]

---

## 5. Betrieb und Wartung

### 5.1 Monitoring
- **Tool**: [z.B. Nagios, Zabbix, Prometheus]
- **Metriken**: [Verfügbarkeit, Latenz, Durchsatz]
- **Alarme**: [Benachrichtigung bei Ausfall]

### 5.2 Wartungsfenster
- **Regulär**: [z.B. Jeden 1. Sonntag im Monat, 02:00-06:00 Uhr]
- **Notfall**: [Kontaktinformationen]

### 5.3 Backup
- **Konfiguration**: [Speicherort und Häufigkeit]
- **Zertifikate**: [Speicherort und Ablaufdatum]

---

## 6. Fehlerbehandlung

### 6.1 Häufige Probleme

#### Problem: Verbindung schlägt fehl
**Symptom**: [Beschreibung]
**Diagnose**:
```bash
[Diagnosebefehle]
```
**Lösung**: [Lösungsschritte]

#### Problem: Langsame Verbindung
**Symptom**: [Beschreibung]
**Diagnose**: [Befehle]
**Lösung**: [Lösungsschritte]

### 6.2 Eskalationspfad
1. **Level 1**: Lokaler Administrator
2. **Level 2**: [Team/Abteilung]
3. **Level 3**: [Externe Dienstleister, z.B. BITBW]

---

## 7. Änderungshistorie

| Datum | Version | Autor | Änderung |
|-------|---------|-------|----------|
| 2026-02-07 | 1.0 | [Name] | Erstdokumentation |

---

## 8. Mehrsprachige Zusammenfassungen

### English Summary
[Brief summary of the server connection in English]

### Résumé en français
[Résumé bref de la connexion serveur en français]

### Resumen en español
[Resumen breve de la conexión del servidor en español]

### الملخص العربي
[ملخص موجز لاتصال الخادم بالعربية]

### Türkçe Özet
[Sunucu bağlantısının kısa özeti]

---

**Hinweis**: Für automatische Übersetzung aktivieren Sie die Confluence Auto-Translate-Funktion:
Seite → Einstellungen → Übersetzungen → Auto-Translate aktivieren
```

---

## 5. Checklisten

### 5.1 Sicherheits-Checkliste vor Produktionsstart

- [ ] Firewall-Regeln getestet und dokumentiert
- [ ] Verschlüsselung aktiv (mindestens TLS 1.2)
- [ ] Authentifizierung implementiert (Zertifikate/Keys)
- [ ] Logging konfiguriert und funktionsfähig
- [ ] Monitoring eingerichtet mit Alarmen
- [ ] Backup-Strategie definiert und getestet
- [ ] Dokumentation in Confluence erstellt
- [ ] Security-Audit durchgeführt
- [ ] Genehmigung der IT-Sicherheitsbeauftragten
- [ ] Change-Management-Prozess durchlaufen
- [ ] Notfall-Kontakte dokumentiert
- [ ] Runbook für Incident Response erstellt

### 5.2 Compliance-Checkliste (DSGVO)

- [ ] Datenschutz-Folgenabschätzung durchgeführt
- [ ] Rechtsgrundlage für Datenverarbeitung vorhanden
- [ ] Auftragsverarbeitungsvertrag abgeschlossen
- [ ] Technisch-organisatorische Maßnahmen dokumentiert
- [ ] Löschkonzept definiert
- [ ] Betroffenenrechte dokumentiert
- [ ] Datenpannen-Prozess definiert
- [ ] Datenschutzbeauftragter informiert

### 5.3 BSI Grundschutz-Checkliste

- [ ] Gefährdungsanalyse durchgeführt
- [ ] Schutzbedarfsfeststellung dokumentiert
- [ ] Basis-Absicherung implementiert
- [ ] Standard-Absicherung implementiert
- [ ] Kern-Absicherung implementiert
- [ ] Risikoanalyse für Restrisiken
- [ ] Sicherheitskonzept erstellt
- [ ] Regelmäßige Reviews geplant

---

## 6. Troubleshooting

### 6.1 Verbindungsprobleme diagnostizieren

```bash
# Schritt 1: Netzwerk-Grundlagen
ping -c 4 <ziel-ip>
traceroute <ziel-ip>
mtr -r -c 10 <ziel-ip>

# Schritt 2: DNS-Auflösung
nslookup <ziel-hostname>
dig <ziel-hostname>
host <ziel-hostname>

# Schritt 3: Port-Erreichbarkeit
nc -zv <ziel-ip> <port>
telnet <ziel-ip> <port>
nmap -p <port> <ziel-ip>

# Schritt 4: Firewall prüfen
sudo nft list ruleset
sudo iptables -L -n -v

# Schritt 5: Routing
ip route get <ziel-ip>
ip route show

# Schritt 6: SSL/TLS-Verbindung
openssl s_client -connect <hostname>:443 -showcerts
curl -vI https://<hostname>

# Schritt 7: Logs analysieren
sudo journalctl -u nftables -n 50
sudo tail -f /var/log/syslog
sudo grep -i "error\|fail" /var/log/syslog
```

### 6.2 Performance-Probleme

```bash
# Netzwerk-Durchsatz testen
iperf3 -c <ziel-server>

# Latenz-Analyse
ping -c 100 -i 0.2 <ziel-ip> | tail -1

# Paketverlustwort
ping -c 1000 -q <ziel-ip>

# MTU-Größe ermitteln
ping -M do -s 1472 <ziel-ip>  # 1500 - 28 = 1472

# Netzwerk-Stack-Statistiken
ss -s
netstat -s

# Bandbreiten-Nutzung
iftop -i <interface>
nethogs
```

---

## 7. Kontakte und Ressourcen

### 7.1 Wichtige Kontakte

| Institution | Kontakt | Telefon | E-Mail | Verfügbarkeit |
|-------------|---------|---------|--------|---------------|
| BITBW | Service-Desk | 0711-xxx-xxxx | servicedesk@bitbw.de | 24/7 |
| HIT | Support | 0761-xxx-xxxx | support@hit.de | Mo-Fr 8-17 Uhr |
| Data Experts | Hotline | 089-xxx-xxxx | hotline@dataexperts.de | Mo-Fr 9-18 Uhr |
| IT-Sicherheit LGL | CERT | 0711-xxx-xxxx | cert@lgl-bw.de | 24/7 |

### 7.2 Interne Ressourcen

- **Wiki**: https://wiki.internal.lgl-bw.de
- **Confluence**: https://confluence.internal.lgl-bw.de
- **Ticket-System**: https://jira.internal.lgl-bw.de
- **Monitoring**: https://monitoring.internal.lgl-bw.de

### 7.3 Externe Ressourcen

- **BSI Grundschutz**: https://www.bsi.bund.de/grundschutz
- **Linux Security**: https://www.kernel.org/doc/html/latest/admin-guide/security.html
- **nftables**: https://wiki.nftables.org
- **OpenSSL**: https://www.openssl.org/docs/

---

**Letzte Aktualisierung**: 2026-02-07
**Nächste Review**: 2026-05-07
**Verantwortlich**: IT-Sicherheit LGL Baden-Württemberg
