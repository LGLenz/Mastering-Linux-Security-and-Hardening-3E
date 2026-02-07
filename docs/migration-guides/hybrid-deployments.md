# Hybrid Environments Migration Guide

## Übersicht (Overview)

Dieser Leitfaden behandelt Hybrid-Umgebungen, in denen Fördersysteme sowohl on-premises als auch in Cloud-Umgebungen betrieben werden. Der Fokus liegt auf sicherer Konnektivität, einheitlicher Sicherheitsrichtlinien und konsistenter Verwaltung.

This guide covers hybrid environments where grant processing systems run both on-premises and in cloud environments, focusing on secure connectivity, unified security policies, and consistent management.

## Hybrid Architecture Patterns

### Pattern 1: Gradual Cloud Migration
**Scenario**: Migrating components incrementally while maintaining on-premises core systems

```
┌─────────────────────┐         ┌─────────────────────┐
│   On-Premises       │         │      Cloud          │
│                     │         │                     │
│  ┌──────────────┐   │         │  ┌──────────────┐   │
│  │ Adabas DB    │◄──┼─────────┼──┤ Web Frontend │   │
│  │ (Legacy)     │   │         │  │ (Modern)     │   │
│  └──────────────┘   │         │  └──────────────┘   │
│                     │         │                     │
│  ┌──────────────┐   │         │  ┌──────────────┐   │
│  │ COBOL Apps   │◄──┼─────────┼──┤ API Gateway  │   │
│  └──────────────┘   │  VPN    │  └──────────────┘   │
└─────────────────────┘         └─────────────────────┘
```

### Pattern 2: Active-Active Deployment
**Scenario**: Running identical systems in both locations for high availability

### Pattern 3: Disaster Recovery
**Scenario**: On-premises primary with cloud-based disaster recovery

## Secure Connectivity

### VPN Configuration

#### IPsec VPN (Site-to-Site)

##### On-Premises Configuration (StrongSwan)
```bash
# Install StrongSwan
apt-get install strongswan strongswan-pki

# Generate certificates
ipsec pki --gen --type rsa --size 4096 --outform pem > /etc/ipsec.d/private/ca.key.pem
ipsec pki --self --ca --lifetime 3650 --in /etc/ipsec.d/private/ca.key.pem \
  --type rsa --dn "C=DE, O=LGL BW, CN=VPN CA" --outform pem > /etc/ipsec.d/cacerts/ca.cert.pem

# Configure IPsec
cat > /etc/ipsec.conf << 'EOF'
config setup
    charondebug="ike 2, knl 2, cfg 2"
    uniqueids=never

conn lgl-to-cloud
    auto=start
    type=tunnel
    authby=secret
    
    # Local (on-premises)
    left=%defaultroute
    leftid=vpn.lgl-bw.de
    leftsubnet=10.0.0.0/16
    
    # Remote (cloud)
    right=cloud-vpn.lgl-bw.de
    rightid=cloud-vpn.lgl-bw.de
    rightsubnet=172.16.0.0/16
    
    # Phase 1 (IKE)
    ike=aes256-sha2_256-modp2048!
    keyexchange=ikev2
    
    # Phase 2 (ESP)
    esp=aes256-sha2_256!
    keyingtries=%forever
    dpdaction=restart
    dpddelay=30s
EOF

# Configure pre-shared key
cat > /etc/ipsec.secrets << 'EOF'
vpn.lgl-bw.de cloud-vpn.lgl-bw.de : PSK "YOUR_STRONG_PSK_HERE"
EOF
chmod 600 /etc/ipsec.secrets

# Start IPsec
systemctl enable strongswan
systemctl start strongswan
```

##### Cloud Configuration (AWS VPN)
```bash
# Create Customer Gateway
aws ec2 create-customer-gateway \
  --type ipsec.1 \
  --public-ip 203.0.113.10 \
  --bgp-asn 65000 \
  --region eu-central-1

# Create Virtual Private Gateway
aws ec2 create-vpn-gateway \
  --type ipsec.1 \
  --region eu-central-1

# Create VPN Connection
aws ec2 create-vpn-connection \
  --type ipsec.1 \
  --customer-gateway-id cgw-xxxxx \
  --vpn-gateway-id vgw-xxxxx \
  --options '{"StaticRoutesOnly":true}'
```

### SD-WAN Alternative
For more complex hybrid environments, consider SD-WAN solutions:
- Cisco Viptela
- VMware VeloCloud
- Silver Peak

## Unified Security Management

### Centralized Identity Management

#### Active Directory Federation
```bash
# Configure SSSD for AD integration on Linux servers
cat > /etc/sssd/sssd.conf << 'EOF'
[sssd]
domains = lgl-bw.de
config_file_version = 2
services = nss, pam

[domain/lgl-bw.de]
ad_domain = lgl-bw.de
krb5_realm = LGL-BW.DE
realmd_tags = manages-system joined-with-adcli
cache_credentials = True
id_provider = ad
krb5_store_password_if_offline = True
default_shell = /bin/bash
ldap_id_mapping = True
use_fully_qualified_names = False
fallback_homedir = /home/%u@%d
access_provider = ad
ad_gpo_access_control = enforcing
EOF

chmod 600 /etc/sssd/sssd.conf
systemctl restart sssd
```

#### Azure AD Integration (for Cloud Resources)
```bash
# Install Azure AD authentication
curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg
echo "deb [arch=amd64] https://packages.microsoft.com/ubuntu/22.04/prod jammy main" > /etc/apt/sources.list.d/microsoft.list
apt-get update
apt-get install azcmagent

# Connect to Azure Arc
azcmagent connect \
  --resource-group "LGL-Hybrid-Resources" \
  --tenant-id "your-tenant-id" \
  --location "germanywestcentral" \
  --subscription-id "your-subscription-id"
```

### Unified Logging and Monitoring

#### Centralized SIEM Configuration
```bash
# Example: Splunk Universal Forwarder configuration
# /opt/splunkforwarder/etc/system/local/outputs.conf
[tcpout]
defaultGroup = lgl-siem

[tcpout:lgl-siem]
server = siem.lgl-bw.de:9997
useACK = true
compressed = true

# Enable TLS
sslCertPath = /opt/splunkforwarder/etc/auth/server.pem
sslRootCAPath = /opt/splunkforwarder/etc/auth/ca.pem
sslPassword = $7$encrypted_password
sslVerifyServerCert = true
```

#### Multi-Environment Monitoring
```yaml
# Prometheus federation configuration
# /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

# On-premises metrics
scrape_configs:
  - job_name: 'onprem-servers'
    static_configs:
      - targets: ['server1.lgl-bw.de:9100', 'server2.lgl-bw.de:9100']
    relabel_configs:
      - source_labels: [__address__]
        target_label: environment
        replacement: 'on-premises'

# Cloud metrics
  - job_name: 'cloud-servers'
    ec2_sd_configs:
      - region: eu-central-1
        port: 9100
    relabel_configs:
      - source_labels: [__address__]
        target_label: environment
        replacement: 'cloud'
```

## Data Synchronization and Consistency

### Database Replication

#### Adabas Replication Strategy
```bash
# Configure Event Replicator for Adabas
# Primary site configuration
cat > /opt/softwareag/Adabas/config/replication.cfg << 'EOF'
REPLICATION=ACTIVE
TARGET=adabas-cloud.lgl-bw.de:48080
MODE=ASYNCHRONOUS
BUFFER_SIZE=10MB
RETRY_INTERVAL=60
CONFLICT_RESOLUTION=PRIMARY_WINS
EOF

# Monitor replication lag
/opt/softwareag/Adabas/bin/adactl repstat
```

#### Backup Synchronization
```bash
# Sync backups between sites
#!/bin/bash
ONPREM_BACKUP="/backup/foerdersystem"
CLOUD_BACKUP="s3://lgl-foerdersystem-backups/onprem-sync"

# Use aws-cli with encryption
aws s3 sync ${ONPREM_BACKUP} ${CLOUD_BACKUP} \
  --sse AES256 \
  --delete \
  --exclude "*.tmp" \
  --region eu-central-1

# Reverse sync for cloud backups
aws s3 sync s3://lgl-foerdersystem-backups/cloud-sync ${ONPREM_BACKUP}/cloud-backups \
  --sse AES256 \
  --region eu-central-1
```

## Policy Consistency

### Unified Security Policies

#### Firewall Rule Management
```bash
# Script to sync firewall rules across environments
#!/bin/bash
# sync-firewall-rules.sh

# Define common rules
COMMON_RULES=(
  "allow from 10.0.0.0/16 to any port 22"
  "allow from 10.0.0.0/16 to any port 443"
  "deny from any to any"
)

# Apply to on-premises
for rule in "${COMMON_RULES[@]}"; do
  ufw $rule
done

# Apply to cloud (AWS Security Groups)
aws ec2 authorize-security-group-ingress \
  --group-id sg-xxxxx \
  --ip-permissions IpProtocol=tcp,FromPort=22,ToPort=22,IpRanges='[{CidrIp=10.0.0.0/16}]' \
  --region eu-central-1
```

#### Configuration Management with Ansible
```yaml
# ansible/playbooks/hybrid-security-baseline.yml
---
- name: Apply security baseline to hybrid environment
  hosts: all
  become: yes
  
  tasks:
    - name: Ensure firewalld is installed
      package:
        name: firewalld
        state: present
    
    - name: Configure common firewall rules
      firewalld:
        zone: internal
        source: "{{ item }}"
        permanent: yes
        state: enabled
      loop:
        - 10.0.0.0/16
        - 172.16.0.0/16
      notify: reload firewalld
    
    - name: Deploy common security configuration
      template:
        src: security-baseline.conf.j2
        dest: /etc/security/baseline.conf
        mode: '0600'
    
    - name: Configure audit rules
      copy:
        src: audit.rules
        dest: /etc/audit/rules.d/hybrid.rules
      notify: restart auditd
  
  handlers:
    - name: reload firewalld
      systemd:
        name: firewalld
        state: reloaded
    
    - name: restart auditd
      systemd:
        name: auditd
        state: restarted
```

## Migration Strategies

### Phase 1: Assessment and Planning
1. **Inventory**: Document all on-premises systems
2. **Dependencies**: Map application dependencies
3. **Data Classification**: Identify sensitive data
4. **Network Topology**: Document current network
5. **Compliance Review**: Verify regulatory requirements

### Phase 2: Connectivity Setup
1. **VPN Establishment**: Set up secure connectivity
2. **Network Testing**: Verify bandwidth and latency
3. **Security Validation**: Test security controls
4. **Monitoring Setup**: Deploy monitoring tools

### Phase 3: Pilot Migration
1. **Non-Production First**: Start with dev/test environments
2. **Data Synchronization**: Set up replication
3. **Application Testing**: Validate functionality
4. **Performance Baseline**: Establish benchmarks

### Phase 4: Production Migration
1. **Incremental Approach**: Move components gradually
2. **Parallel Running**: Run both environments
3. **Validation**: Continuous testing
4. **Rollback Plan**: Ready to revert if needed

### Phase 5: Optimization
1. **Performance Tuning**: Optimize configurations
2. **Cost Review**: Analyze and optimize costs
3. **Security Hardening**: Additional security measures
4. **Documentation**: Complete documentation

## Disaster Recovery in Hybrid Environment

### DR Scenarios

#### Scenario 1: On-Premises Failure
```bash
# Automated failover script
#!/bin/bash
# Check on-premises availability
if ! ping -c 3 onprem-primary.lgl-bw.de > /dev/null 2>&1; then
    echo "On-premises site unreachable. Initiating cloud failover..."
    
    # Update DNS to point to cloud
    aws route53 change-resource-record-sets \
      --hosted-zone-id Z123456 \
      --change-batch file://dns-failover.json
    
    # Promote cloud database to primary
    /opt/scripts/promote-cloud-db.sh
    
    # Notify team
    aws sns publish \
      --topic-arn arn:aws:sns:eu-central-1:123456789012:lgl-alerts \
      --message "DR failover to cloud completed"
fi
```

#### Scenario 2: Cloud Region Failure
- Fallback to on-premises systems
- Utilize alternative cloud region
- Manual failover process with documented runbooks

### DR Testing Schedule
- **Tabletop Exercise**: Quarterly
- **Partial Failover Test**: Semi-annually
- **Full DR Drill**: Annually

## Compliance and Audit

### Hybrid Compliance Checklist

#### Data Protection
- [ ] Data classification applied consistently
- [ ] Encryption in transit between sites
- [ ] Encryption at rest in both environments
- [ ] Data residency requirements met
- [ ] Backup verification in both locations

#### Access Control
- [ ] Unified identity management
- [ ] MFA enforced across environments
- [ ] Privileged access management
- [ ] Regular access reviews
- [ ] Audit logging enabled everywhere

#### Network Security
- [ ] VPN connectivity secured
- [ ] Network segmentation implemented
- [ ] Intrusion detection/prevention active
- [ ] DDoS protection enabled
- [ ] Regular vulnerability scans

#### Monitoring and Incident Response
- [ ] Centralized logging configured
- [ ] SIEM integration complete
- [ ] Alerting rules defined
- [ ] Incident response plan tested
- [ ] Regular security reviews

## Cost Management

### Hybrid Cost Optimization
- Monitor data transfer costs between environments
- Optimize workload placement based on cost/performance
- Use cloud bursting for peak loads
- Regular resource utilization reviews
- Reserved capacity planning

## Troubleshooting

### Common Issues

#### VPN Connectivity Problems
```bash
# Check VPN status
ipsec status
ipsec statusall

# Test connectivity
ping -c 4 172.16.0.1  # Cloud subnet
traceroute 172.16.0.1

# Check logs
tail -f /var/log/syslog | grep charon
```

#### Replication Lag
```bash
# Check Adabas replication
/opt/softwareag/Adabas/bin/adactl repstat

# Monitor network latency
mtr -n cloud-endpoint.lgl-bw.de
```

#### Authentication Issues
```bash
# Test AD connectivity
kinit username@LGL-BW.DE
klist

# Check SSSD
sssctl user-checks username
tail -f /var/log/sssd/sssd.log
```

## Support Resources

- **BITBW Hybrid Architecture Team**: [Contact]
- **LGL BW Network Operations**: [Contact]
- **Cloud Provider Support**: Provider-specific channels
- **Emergency Hotline**: [24/7 Support Number]

## Documentation Requirements

For hybrid deployments, maintain:
1. **Network Diagrams**: Current topology
2. **Data Flow Maps**: Inter-site data flows
3. **Security Policies**: Unified policy documents
4. **Runbooks**: Operational procedures
5. **DR Plans**: Disaster recovery documentation
6. **Contact Lists**: Escalation procedures

---

**Languages Available**: Deutsch (Sie) | English | عربي | Türkçe
