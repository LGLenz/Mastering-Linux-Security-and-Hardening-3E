# Cloud-Native Linux Deployments Migration Guide

## Übersicht (Overview)

Dieser Leitfaden behandelt die Migration von Fördersystemen in Cloud-Native Linux-Umgebungen unter Berücksichtigung der BSI-Richtlinien und deutscher Datensouveränitätsanforderungen.

This guide covers migrating grant processing systems to cloud-native Linux environments while maintaining BSI compliance and German data sovereignty requirements.

## Cloud Provider Selection Criteria

### Data Sovereignty Requirements

For LGL BW Fördersystem deployment, ensure:

1. **Data Location**: All data must remain within Germany/EU
2. **BSI C5 Certification**: Cloud provider must have BSI C5 attestation
3. **GDPR Compliance**: Full GDPR compliance required
4. **Government Cloud Options**: Consider govCloud or sovereign cloud offerings

### Recommended Providers (Examples)
- Open Telekom Cloud (Deutsche Telekom)
- German-based AWS regions (Frankfurt)
- Microsoft Azure Germany
- Ionos Cloud
- Other BSI C5 certified providers

## Pre-Deployment Security Checklist

### 1. Identity and Access Management (IAM)

```bash
# Example: AWS IAM policy for Fördersystem resources
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ec2:RunInstances",
        "ec2:TerminateInstances"
      ],
      "Resource": "*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-central-1"
        }
      }
    }
  ]
}
```

**Best Practices:**
- Implement least privilege access
- Enable Multi-Factor Authentication (MFA)
- Use service accounts for applications
- Regular access reviews
- Implement break-glass procedures

### 2. Network Security

#### Virtual Private Cloud (VPC) Configuration
```bash
# Example: Terraform configuration for secure VPC
resource "aws_vpc" "foerdersystem_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  tags = {
    Name        = "LGL-Foerdersystem-VPC"
    Environment = "Production"
    Compliance  = "BSI-C5"
  }
}

# Private subnet for Adabas
resource "aws_subnet" "database_subnet" {
  vpc_id                  = aws_vpc.foerdersystem_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = false
  availability_zone       = "eu-central-1a"
  
  tags = {
    Name = "Database-Private-Subnet"
    Tier = "Data"
  }
}

# Security group for application tier
resource "aws_security_group" "app_sg" {
  name        = "foerdersystem-app-sg"
  description = "Security group for Foerdersystem application servers"
  vpc_id      = aws_vpc.foerdersystem_vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

#### Network Segmentation Strategy
- **Public Subnet**: Load balancers only
- **Application Subnet**: Fördersystem application servers
- **Database Subnet**: Adabas and data storage
- **Management Subnet**: Bastion hosts and management tools

### 3. Encryption

#### Encryption at Rest
```bash
# Example: Enable EBS encryption for all volumes
aws ec2 modify-ebs-default-kms-key-id --kms-key-id arn:aws:kms:eu-central-1:123456789012:key/your-key-id

# Enable encryption by default
aws ec2 enable-ebs-encryption-by-default --region eu-central-1
```

#### Encryption in Transit
```bash
# Configure TLS 1.3 minimum
# /etc/nginx/nginx.conf
ssl_protocols TLSv1.3;
ssl_prefer_server_ciphers on;
ssl_ciphers 'ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384';
ssl_certificate /etc/ssl/certs/foerdersystem.crt;
ssl_certificate_key /etc/ssl/private/foerdersystem.key;
```

## Container Security (If Using Containers)

### Docker/Podman Hardening

#### Secure Base Image
```dockerfile
# Use minimal, security-focused base image
FROM registry.access.redhat.com/ubi9/ubi-minimal:latest

# Run as non-root user
RUN useradd -r -u 1001 foerdersystem
USER foerdersystem

# Copy only necessary files
COPY --chown=foerdersystem:foerdersystem ./app /opt/foerdersystem/

# Set secure permissions
RUN chmod 500 /opt/foerdersystem/bin/*
RUN chmod 400 /opt/foerdersystem/config/*

# Health check
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost:8080/health || exit 1

EXPOSE 8080
CMD ["/opt/foerdersystem/bin/start.sh"]
```

#### Container Runtime Security
```bash
# Run container with security options
podman run -d \
  --name foerdersystem-app \
  --security-opt=no-new-privileges \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  -p 8080:8080 \
  foerdersystem:latest
```

### Kubernetes Security (If Using K8s)

#### Pod Security Policy
```yaml
apiVersion: policy/v1beta1
kind: PodSecurityPolicy
metadata:
  name: foerdersystem-restricted
spec:
  privileged: false
  allowPrivilegeEscalation: false
  requiredDropCapabilities:
    - ALL
  volumes:
    - 'configMap'
    - 'emptyDir'
    - 'projected'
    - 'secret'
  hostNetwork: false
  hostIPC: false
  hostPID: false
  runAsUser:
    rule: 'MustRunAsNonRoot'
  seLinux:
    rule: 'RunAsAny'
  fsGroup:
    rule: 'RunAsAny'
  readOnlyRootFilesystem: true
```

#### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: foerdersystem-network-policy
  namespace: foerdersystem
spec:
  podSelector:
    matchLabels:
      app: foerdersystem
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: foerdersystem
      ports:
        - protocol: TCP
          port: 8080
  egress:
    - to:
        - namespaceSelector:
            matchLabels:
              name: foerdersystem-db
      ports:
        - protocol: TCP
          port: 48080
```

## BSI Cloud Compliance

### Required Security Controls

#### 1. OPS-01: Cloud Service Provider Selection
- ✅ Verify BSI C5 certification
- ✅ Review SOC 2 Type II reports
- ✅ Ensure data residency in Germany/EU
- ✅ Verify GDPR compliance

#### 2. OPS-02: Access Management
- ✅ Implement role-based access control (RBAC)
- ✅ Enable MFA for all administrative access
- ✅ Regular access reviews (quarterly)
- ✅ Audit logging of all privileged operations

#### 3. OPS-03: Data Protection
- ✅ Encryption at rest (AES-256)
- ✅ Encryption in transit (TLS 1.3)
- ✅ Key management (HSM or managed KMS)
- ✅ Data classification and handling procedures

#### 4. OPS-04: Monitoring and Incident Response
```bash
# Example: CloudWatch alarms for security events
aws cloudwatch put-metric-alarm \
  --alarm-name unauthorized-api-calls \
  --alarm-description "Alert on unauthorized API calls" \
  --metric-name UnauthorizedAPICalls \
  --namespace AWS/CloudTrail \
  --statistic Sum \
  --period 300 \
  --threshold 1 \
  --comparison-operator GreaterThanThreshold \
  --evaluation-periods 1
```

## Logging and Monitoring

### Centralized Logging
```yaml
# Example: Filebeat configuration for cloud logging
filebeat.inputs:
  - type: log
    enabled: true
    paths:
      - /var/log/foerdersystem/*.log
    fields:
      environment: production
      application: foerdersystem
      compliance: BSI-C5

output.elasticsearch:
  hosts: ["https://elasticsearch.internal.lgl-bw.de:9200"]
  protocol: "https"
  ssl.certificate_authorities: ["/etc/ssl/certs/ca.crt"]
  ssl.certificate: "/etc/ssl/certs/client.crt"
  ssl.key: "/etc/ssl/private/client.key"
```

### Security Monitoring
- Enable CloudTrail/equivalent for API auditing
- Configure SIEM integration
- Set up anomaly detection
- Implement automated compliance checks

## Disaster Recovery and Business Continuity

### Backup Strategy
```bash
# Automated backup script
#!/bin/bash
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_BUCKET="s3://lgl-foerdersystem-backups-eu-central-1"

# Backup Adabas database
/opt/softwareag/Adabas/bin/adactl backup /backup/adabas_${BACKUP_DATE}.bkp

# Encrypt and upload
openssl enc -aes-256-cbc -salt -in /backup/adabas_${BACKUP_DATE}.bkp \
  -out /backup/adabas_${BACKUP_DATE}.bkp.enc -pass pass:${BACKUP_PASSWORD}

aws s3 cp /backup/adabas_${BACKUP_DATE}.bkp.enc ${BACKUP_BUCKET}/ \
  --server-side-encryption AES256 \
  --region eu-central-1
```

### Multi-Region Considerations
- Primary region: eu-central-1 (Frankfurt)
- DR region: eu-west-3 (Paris) or eu-central-2 (Zurich)
- RPO: 1 hour
- RTO: 4 hours

## Migration Checklist

- [ ] Cloud provider BSI C5 certification verified
- [ ] Data sovereignty requirements confirmed
- [ ] VPC and network security configured
- [ ] IAM policies and roles defined
- [ ] Encryption enabled (at rest and in transit)
- [ ] Container security implemented (if applicable)
- [ ] Kubernetes security policies applied (if applicable)
- [ ] Monitoring and logging configured
- [ ] SIEM integration completed
- [ ] Backup and disaster recovery tested
- [ ] Compliance scan passed
- [ ] Security documentation completed
- [ ] Team training conducted

## Cost Optimization with Security

While maintaining security, consider:
- Right-sizing instances
- Reserved instances for production
- Automated scaling policies
- Storage lifecycle policies
- Regular resource audits

## Support and Resources

- **BSI Cloud Computing Guidelines**: https://www.bsi.bund.de/
- **BSI C5 Criteria**: Cloud Computing Compliance Controls Catalogue
- **BITBW Cloud Support**: [Contact BITBW]
- **Cloud Provider Security**: Provider-specific security documentation

---

**Languages Available**: Deutsch (Sie) | English | عربي | Türkçe
