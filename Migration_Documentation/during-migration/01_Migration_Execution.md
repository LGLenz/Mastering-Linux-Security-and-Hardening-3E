# Migration Execution / Durchführung der Migration

## Übersicht / Overview

Diese Phase beschreibt die praktische Durchführung der Migration von Großrechner-Systemen zu Linux-Servern unter Einhaltung der BSI Grundschutz-Anforderungen.

## 1. Migrations-Vorbereitung / Migration Preparation

### 1.1 Pre-Migration Checklist

```markdown
✓ Pflicht-Voraussetzungen / Mandatory Prerequisites
────────────────────────────────────────────────────
□ Alle Freigaben erhalten (IT-Sec, Datenschutz, Management)
□ Security Baseline auf allen Zielsystemen implementiert
□ Test-Umgebung vollständig aufgebaut
□ Backup-Strategie getestet und validiert
□ Rollback-Plan dokumentiert und geprobt
□ Team vollständig und geschult
□ Change-Tickets erstellt und genehmigt
□ Stakeholder informiert (Kommunikationsplan)
□ Wartungsfenster bestätigt

✓ Technische Voraussetzungen / Technical Prerequisites
──────────────────────────────────────────────────────
□ Ziel-Linux-Server provisioniert und gehärtet
□ Netzwerk-Konnektivität validiert
□ DNS-Einträge vorbereitet
□ SSL/TLS-Zertifikate installiert
□ Monitoring-Agents installiert
□ Backup-Jobs konfiguriert
□ PostgreSQL-Cluster aufgebaut
□ Datenmigrations-Tools getestet
□ Validierungs-Scripts entwickelt
```

### 1.2 Wartungsfenster-Planung

```bash
# Beispiel: Wartungsfenster für Phase 1 (Non-Critical Batch)
─────────────────────────────────────────────────────────────
Start:     Freitag, 20:00 Uhr
Ende:      Montag, 06:00 Uhr
Dauer:     58 Stunden
Team:      24/7 Bereitschaft

Timeline:
─────────
Fr 20:00 - Migration Kickoff, Letzte Checks
Fr 21:00 - Freeze auf Legacy-System
Fr 22:00 - Start Daten-Export aus Adabas
Sa 02:00 - Start Daten-Import in PostgreSQL
Sa 08:00 - Daten-Validierung
Sa 14:00 - Batch-Jobs migrieren und testen
So 10:00 - Integration Testing
So 18:00 - Performance Testing
So 22:00 - Go/No-Go Decision
Mo 02:00 - Cutover oder Rollback
Mo 06:00 - Ende Wartungsfenster, System freigeben
```

## 2. Phasenweise Migration / Phased Migration

### Phase 1: Non-Critical Batch Jobs

#### 2.1.1 Daten-Export aus Adabas

**Vorbereitung**:
```natural
* Natural-Programm für Daten-Export
* EXPORT-DATA
*
DEFINE DATA LOCAL
01 EMPLOYEES VIEW OF EMPLOYEE-FILE
   02 PERSONNEL-ID
   02 FIRST-NAME
   02 LAST-NAME
   02 DEPARTMENT
01 CSV-LINE (A200)
END-DEFINE
*
OPEN OUTPUT FILE 1 'employees.csv'
*
READ EMPLOYEES
  MOVE EDITED PERSONNEL-ID TO CSV-LINE
  MOVE ',' TO CSV-LINE (POSITION)
  MOVE FIRST-NAME TO CSV-LINE (POSITION)
  MOVE ',' TO CSV-LINE (POSITION)
  MOVE LAST-NAME TO CSV-LINE (POSITION)
  MOVE ',' TO CSV-LINE (POSITION)
  MOVE DEPARTMENT TO CSV-LINE (POSITION)
  WRITE FILE 1 CSV-LINE
END-READ
*
CLOSE FILE 1
END
```

**Linux-seitige Verarbeitung**:
```bash
#!/bin/bash
# adabas-export.sh

set -euo pipefail

# Variablen
ADABAS_HOST="mainframe.example.de"
ADABAS_USER="migration"
EXPORT_DIR="/mnt/migration/exports"
LOG_FILE="/var/log/migration/export.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Export starten
log "Starting Adabas export..."

# Via Natural Bridge oder FTP
ftp -n << EOF
open $ADABAS_HOST
user $ADABAS_USER
binary
cd /export
mget *.csv
bye
EOF

# Validierung
log "Validating exported files..."
for file in "$EXPORT_DIR"/*.csv; do
    lines=$(wc -l < "$file")
    log "File: $file - Lines: $lines"
done

log "Export completed successfully"
```

#### 2.1.2 Daten-Transformation

```python
#!/usr/bin/env python3
# transform_adabas_data.py

import csv
import psycopg2
import logging
from datetime import datetime

# Logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('/var/log/migration/transform.log'),
        logging.StreamHandler()
    ]
)

class AdabasTransformer:
    def __init__(self, db_config):
        self.conn = psycopg2.connect(**db_config)
        self.cursor = self.conn.cursor()
        
    def transform_employee_data(self, csv_file):
        """Transform employee data from Adabas CSV to PostgreSQL"""
        
        logging.info(f"Processing {csv_file}...")
        
        with open(csv_file, 'r', encoding='iso-8859-1') as f:
            reader = csv.DictReader(f)
            
            for row in reader:
                try:
                    # EBCDIC zu UTF-8 Konvertierung (falls nötig)
                    personnel_id = int(row['PERSONNEL_ID'])
                    first_name = row['FIRST_NAME'].strip()
                    last_name = row['LAST_NAME'].strip()
                    department = row['DEPARTMENT'].strip()
                    
                    # Daten-Validierung
                    if not first_name or not last_name:
                        logging.warning(f"Invalid data for ID {personnel_id}")
                        continue
                    
                    # Insert in PostgreSQL
                    self.cursor.execute("""
                        INSERT INTO employees (
                            personnel_id, first_name, last_name, 
                            department, created_at
                        ) VALUES (%s, %s, %s, %s, %s)
                        ON CONFLICT (personnel_id) DO UPDATE SET
                            first_name = EXCLUDED.first_name,
                            last_name = EXCLUDED.last_name,
                            department = EXCLUDED.department,
                            updated_at = CURRENT_TIMESTAMP
                    """, (personnel_id, first_name, last_name, 
                          department, datetime.now()))
                    
                except Exception as e:
                    logging.error(f"Error processing row: {e}")
                    self.conn.rollback()
                    raise
        
        self.conn.commit()
        logging.info(f"Successfully processed {csv_file}")
    
    def close(self):
        self.cursor.close()
        self.conn.close()

if __name__ == "__main__":
    db_config = {
        'host': 'db.example.de',
        'port': 5432,
        'database': 'migrated_db',
        'user': 'migration_user',
        'password': 'secure_password',
        'sslmode': 'require'
    }
    
    transformer = AdabasTransformer(db_config)
    
    try:
        transformer.transform_employee_data('/mnt/migration/exports/employees.csv')
    finally:
        transformer.close()
```

#### 2.1.3 Daten-Validierung

```python
#!/usr/bin/env python3
# validate_migration.py

import psycopg2
import logging
import sys

logging.basicConfig(level=logging.INFO)

class MigrationValidator:
    def __init__(self, adabas_count_file, pg_config):
        self.adabas_counts = self._load_adabas_counts(adabas_count_file)
        self.pg_conn = psycopg2.connect(**pg_config)
        self.errors = []
        
    def _load_adabas_counts(self, file_path):
        """Load record counts from Adabas"""
        counts = {}
        with open(file_path, 'r') as f:
            for line in f:
                table, count = line.strip().split(':')
                counts[table] = int(count)
        return counts
    
    def validate_record_counts(self):
        """Validate record counts match"""
        logging.info("Validating record counts...")
        
        cursor = self.pg_conn.cursor()
        
        for table, adabas_count in self.adabas_counts.items():
            cursor.execute(f"SELECT COUNT(*) FROM {table}")
            pg_count = cursor.fetchone()[0]
            
            if adabas_count == pg_count:
                logging.info(f"✓ {table}: {pg_count} records (match)")
            else:
                error = f"✗ {table}: Adabas={adabas_count}, PostgreSQL={pg_count}"
                logging.error(error)
                self.errors.append(error)
        
        cursor.close()
    
    def validate_data_integrity(self):
        """Validate data integrity constraints"""
        logging.info("Validating data integrity...")
        
        cursor = self.pg_conn.cursor()
        
        # Check for NULL values in NOT NULL columns
        cursor.execute("""
            SELECT column_name, table_name
            FROM information_schema.columns
            WHERE is_nullable = 'NO'
            AND table_schema = 'public'
        """)
        
        for column, table in cursor.fetchall():
            cursor.execute(f"""
                SELECT COUNT(*) FROM {table}
                WHERE {column} IS NULL
            """)
            null_count = cursor.fetchone()[0]
            
            if null_count > 0:
                error = f"✗ {table}.{column}: {null_count} NULL values"
                logging.error(error)
                self.errors.append(error)
        
        cursor.close()
    
    def validate_referential_integrity(self):
        """Validate foreign key constraints"""
        logging.info("Validating referential integrity...")
        
        cursor = self.pg_conn.cursor()
        
        # Get all FK constraints
        cursor.execute("""
            SELECT
                tc.table_name, 
                kcu.column_name,
                ccu.table_name AS foreign_table_name,
                ccu.column_name AS foreign_column_name
            FROM information_schema.table_constraints AS tc 
            JOIN information_schema.key_column_usage AS kcu
                ON tc.constraint_name = kcu.constraint_name
            JOIN information_schema.constraint_column_usage AS ccu
                ON ccu.constraint_name = tc.constraint_name
            WHERE tc.constraint_type = 'FOREIGN KEY'
        """)
        
        for table, column, ref_table, ref_column in cursor.fetchall():
            cursor.execute(f"""
                SELECT COUNT(*)
                FROM {table} t
                LEFT JOIN {ref_table} r ON t.{column} = r.{ref_column}
                WHERE r.{ref_column} IS NULL AND t.{column} IS NOT NULL
            """)
            orphaned = cursor.fetchone()[0]
            
            if orphaned > 0:
                error = f"✗ {table}.{column}: {orphaned} orphaned records"
                logging.error(error)
                self.errors.append(error)
        
        cursor.close()
    
    def generate_report(self):
        """Generate validation report"""
        if not self.errors:
            logging.info("✓ All validations passed!")
            return True
        else:
            logging.error(f"✗ {len(self.errors)} validation errors found:")
            for error in self.errors:
                logging.error(f"  - {error}")
            return False
    
    def close(self):
        self.pg_conn.close()

if __name__ == "__main__":
    pg_config = {
        'host': 'db.example.de',
        'database': 'migrated_db',
        'user': 'migration_user',
        'password': 'secure_password',
        'sslmode': 'require'
    }
    
    validator = MigrationValidator('adabas_counts.txt', pg_config)
    
    try:
        validator.validate_record_counts()
        validator.validate_data_integrity()
        validator.validate_referential_integrity()
        
        if not validator.generate_report():
            sys.exit(1)
    finally:
        validator.close()
```

### Phase 2: Read-Only Applications

#### 2.2.1 Natural-Programm Migration

**Option 1: Natural für Linux**
```bash
# Software AG Natural Runtime installieren
# Lizenz erforderlich

# Natural-Programme deployen
cp natural_programs/* /opt/softwareag/natural/

# Natural Runtime starten
natstart
```

**Option 2: Re-Implementation in Python/Java**
```python
# Beispiel: Natural-Programm in Python reimplementiert
# Original Natural:
# READ EMPLOYEES WHERE DEPARTMENT = 'IT'

from flask import Flask, jsonify
import psycopg2

app = Flask(__name__)

@app.route('/api/employees/<department>')
def get_employees(department):
    conn = psycopg2.connect(
        host='db.example.de',
        database='migrated_db',
        user='app_user',
        password='secure_password',
        sslmode='require'
    )
    
    cursor = conn.cursor()
    cursor.execute("""
        SELECT personnel_id, first_name, last_name
        FROM employees
        WHERE department = %s
        ORDER BY last_name
    """, (department,))
    
    employees = []
    for row in cursor.fetchall():
        employees.append({
            'id': row[0],
            'firstName': row[1],
            'lastName': row[2]
        })
    
    cursor.close()
    conn.close()
    
    return jsonify(employees)

if __name__ == '__main__':
    # HTTPS only (TLS 1.3)
    app.run(
        host='0.0.0.0',
        port=8443,
        ssl_context=('/etc/ssl/certs/server.crt', 
                     '/etc/ssl/private/server.key')
    )
```

#### 2.2.2 Dual-Read Setup (Parallelbetrieb)

```python
#!/usr/bin/env python3
# dual_read_comparison.py

import psycopg2
import requests
import logging

class DualReadValidator:
    """Compare results from Adabas and PostgreSQL"""
    
    def __init__(self, adabas_api, pg_config):
        self.adabas_api = adabas_api
        self.pg_conn = psycopg2.connect(**pg_config)
        
    def compare_query(self, query, params):
        # Query Adabas
        adabas_result = requests.get(
            f"{self.adabas_api}/query",
            params={'sql': query, **params}
        ).json()
        
        # Query PostgreSQL
        cursor = self.pg_conn.cursor()
        cursor.execute(query, params)
        pg_result = cursor.fetchall()
        cursor.close()
        
        # Compare
        if adabas_result == pg_result:
            logging.info(f"✓ Results match for: {query[:50]}")
            return True
        else:
            logging.error(f"✗ Results differ for: {query[:50]}")
            logging.error(f"  Adabas: {len(adabas_result)} rows")
            logging.error(f"  PostgreSQL: {len(pg_result)} rows")
            return False
```

### Phase 3: Write Operations (Critical)

#### 2.3.1 Dual-Write Implementation

```python
#!/usr/bin/env python3
# dual_write.py

import psycopg2
import requests
import logging
from contextlib import contextmanager

class DualWriteManager:
    """Write to both Adabas and PostgreSQL during transition"""
    
    def __init__(self, adabas_api, pg_config):
        self.adabas_api = adabas_api
        self.pg_config = pg_config
        
    @contextmanager
    def transaction(self):
        """Dual-write transaction context"""
        pg_conn = psycopg2.connect(**self.pg_config)
        pg_conn.autocommit = False
        
        try:
            yield pg_conn
            pg_conn.commit()
        except Exception as e:
            pg_conn.rollback()
            logging.error(f"Transaction failed: {e}")
            raise
        finally:
            pg_conn.close()
    
    def insert_employee(self, data):
        """Insert to both systems"""
        
        # Write to PostgreSQL
        with self.transaction() as pg_conn:
            cursor = pg_conn.cursor()
            cursor.execute("""
                INSERT INTO employees (first_name, last_name, department)
                VALUES (%s, %s, %s)
                RETURNING personnel_id
            """, (data['first_name'], data['last_name'], data['department']))
            
            personnel_id = cursor.fetchone()[0]
            cursor.close()
        
        # Write to Adabas (legacy)
        try:
            response = requests.post(
                f"{self.adabas_api}/employees",
                json={**data, 'personnel_id': personnel_id}
            )
            response.raise_for_status()
        except requests.exceptions.RequestException as e:
            logging.error(f"Adabas write failed: {e}")
            # Decision: Continue or rollback PostgreSQL?
            # Depends on business requirements
            
        logging.info(f"Dual-write completed for ID: {personnel_id}")
        return personnel_id
```

## 3. Sicherheitsüberwachung während Migration / Security Monitoring

### 3.1 Real-Time Security Monitoring

```bash
#!/bin/bash
# migration-security-monitor.sh

# SIEM Alerting
tail -f /var/log/audit/audit.log | while read line; do
    # Check for suspicious activity
    if echo "$line" | grep -q "SYSCALL.*execve"; then
        logger -p security.warning "Suspicious execve during migration: $line"
        # Send to SIEM
        echo "$line" | nc siem.example.de 514
    fi
done &

# Integrity checks
while true; do
    aide --check
    sleep 3600
done &

# Performance monitoring
while true; do
    vmstat 1 5
    iostat -x 1 5
    sleep 300
done &
```

### 3.2 Zugriffskontrolle während Migration

```bash
# Temporäre Firewall-Regeln für Migrations-Zeitraum
firewall-cmd --permanent --new-zone=migration
firewall-cmd --permanent --zone=migration --add-source=10.0.50.0/24
firewall-cmd --permanent --zone=migration --add-port=5432/tcp
firewall-cmd --permanent --zone=migration --add-port=8080/tcp
firewall-cmd --reload

# Nach Migration entfernen:
# firewall-cmd --permanent --delete-zone=migration
```

## 4. Rollback-Prozedur / Rollback Procedure

### 4.1 Rollback-Entscheidungskriterien

```markdown
Go-Decision:
✓ Alle Validierungstests bestanden
✓ Performance-Ziele erreicht
✓ Keine kritischen Fehler in Logs
✓ Stakeholder-Freigabe

No-Go/Rollback:
✗ Datenverlust oder -korruption
✗ Performance < 80% von Baseline
✗ Kritische Anwendungsfehler
✗ Security-Incidents
✗ Stakeholder-Ablehnung
```

### 4.1 Rollback-Script

```bash
#!/bin/bash
# rollback.sh

set -euo pipefail

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/migration/rollback_${TIMESTAMP}.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

log "=== ROLLBACK INITIATED ==="

# 1. Stop all application services
log "Stopping application services..."
systemctl stop myapp

# 2. Restore database from backup
log "Restoring PostgreSQL from backup..."
pg_restore -h db.example.de -U postgres -d migrated_db /backup/pre_migration.dump

# 3. Re-enable Adabas access
log "Re-enabling Adabas connections..."
# Specific to environment

# 4. Revert firewall rules
log "Reverting firewall rules..."
firewall-cmd --reload

# 5. Notify stakeholders
log "Sending rollback notifications..."
mail -s "Migration Rollback Executed" stakeholders@example.de < /tmp/rollback_msg.txt

log "=== ROLLBACK COMPLETED ==="
```

## 5. Post-Cutover Tasks / Nach der Umstellung

### 5.1 Sofort nach Cutover

```markdown
✓ Unmittelbar nach Cutover (0-2 Stunden)
──────────────────────────────────────────
□ System-Gesundheits-Check
□ Kritische Transaktionen testen
□ Performance-Metriken überwachen
□ Log-Analyse auf Fehler
□ Benutzer-Feedback sammeln
□ Incident-Response-Team in Bereitschaft
```

### 5.2 Erste 24 Stunden

```markdown
✓ Erste 24 Stunden
─────────────────
□ Stündliche System-Checks
□ Performance-Trending
□ Datenbank-Integrität validieren
□ Backup-Validierung
□ Security-Scan durchführen
□ Kapazitäts-Monitoring
```

## Nächste Schritte / Next Steps

1. [Data Migration Details](./02_Data_Migration.md)
2. [Testing and Validation](./03_Testing_and_Validation.md)
3. [Post-Migration Operations](../post-migration/01_Operations_and_Maintenance.md)

## Referenzen / References

- BSI Grundschutz OPS.1.1.3: Patch- und Änderungsmanagement
- ITIL Change Management
- PostgreSQL Migration Best Practices
