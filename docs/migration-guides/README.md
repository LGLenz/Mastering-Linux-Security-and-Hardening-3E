# LGL BW Fördersystem Migration Guides

## Overview
This documentation provides segmented guidance for migrating LGL BW's Fördersystem (grant processing systems) from mainframe environments (Großrechner) to hardened Linux servers. The guides are organized by deployment type to address specific security requirements and configurations.

## Documentation Structure

### 1. [Traditional Linux Servers (On-Premises)](./traditional-on-premises.md)
Guide for migrating to traditional on-premises Linux servers with legacy application support.

**Target Use Cases:**
- Direct mainframe replacement
- Adabas database hosting
- COBOL/legacy application runtime
- Internal network deployment

**Key Topics:**
- BITBW pre-configuration review
- Legacy application integration
- Local security hardening
- Network isolation

### 2. [Cloud-Native Linux Deployments](./cloud-native.md)
Guide for deploying Fördersystem components in cloud environments with modern security practices.

**Target Use Cases:**
- Public cloud deployment (with data sovereignty compliance)
- Containerized workloads
- Microservices architecture
- Scalable infrastructure

**Key Topics:**
- Cloud security posture
- BSI cloud compliance
- Data sovereignty requirements
- Container security

### 3. [Hybrid Environments](./hybrid-deployments.md)
Guide for managing security across hybrid on-premises and cloud deployments.

**Target Use Cases:**
- Gradual cloud migration
- Multi-location deployments
- Disaster recovery scenarios
- Development/production separation

**Key Topics:**
- Secure connectivity
- Unified monitoring
- Policy consistency
- Data migration strategies

## Getting Started

1. **Assess Your Environment**: Determine which deployment type(s) apply to your migration
2. **Review Pre-Configurations**: Check what BITBW has already configured
3. **Follow Relevant Guide(s)**: Use the appropriate guide for your deployment type
4. **Validate Security**: Run compliance scans and security audits
5. **Document Deviations**: Record any customizations or exceptions

## Support and Languages

All guides are available in:
- German (formal "Sie" form) - Primary language
- English
- Syrian Arabic (عربي)
- Eastern European languages (upon request)
- Turkish (Türkçe)

## Compliance References

- BSI IT-Grundschutz
- ISO 27001
- German government IT security guidelines
- BITBW infrastructure standards
- SCAP compliance profiles (see Chapter_12)
