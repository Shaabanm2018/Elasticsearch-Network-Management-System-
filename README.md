# Elasticsearch Network Management System

<div align="center">


## Table of Contents
- [Overview](#overview)
- [Key Features](#key-features)
- [System Architecture](#system-architecture)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Configuration](#configuration)
- [Usage Guide](#usage-guide)
- [Dashboard Overview](#dashboard-overview)
- [Monitoring Features](#monitoring-features)
- [Alert Management](#alert-management)
- [Maintenance](#maintenance)
- [Troubleshooting](#troubleshooting)

## Overview
An advanced network administration system designed for proactive monitoring and intelligent assessment of network infrastructure. The system provides real-time monitoring of routers, switches, and firewalls, with sophisticated incident response capabilities and predictive analytics.

### Key Features
- **Intelligent Monitoring**: Real-time surveillance of network devices and infrastructure
- **ML-Powered Anomaly Detection**: Predictive analysis of potential failures and network anomalies
- **Smart Alert System**: Priority-based incident categorization with automated notifications
- **Advanced Visualization**: Comprehensive dashboards for network metrics and performance
- **Automated Response**: Streamlined incident management and response workflows


## System Architecture
![Sysetem Flowchart](https://github.com/user-attachments/assets/7b927f12-b163-454e-963c-1c5c457d744c)


### Technology Stack
- **Containerization**: Docker and Kubernetes
- **Monitoring Stack**: ELK (Elasticsearch, Logstash, Kibana)
- **Network Tools**: SNMP, Nmap
- **Machine Learning**: Predictive maintenance models
- **Notification System**: Automated email alerts

## Prerequisites
- Kubernetes cluster (v1.19+)
- Docker (20.10+)
- Minimum hardware requirements:
  - CPU: 4 cores
  - RAM: 16GB
  - Storage: 100GB SSD
- Network access to monitored devices
- SMTP server for email notifications

## Installation

### Automatic Full Installation
```bash
# Clone the repository
git clone https://github.com/yourusername/network-management-system
cd network-management-system

# Run the installation script
chmod +x es_installation.sh
./es_installation.sh <namespace> staging <node-name> all
```

### Step-by-Step Installation
Detailed installation instructions are available in our Installation Documents.

## Dashboard Overview

### Main Dashboard
![Screenshot 2024-10-30 155654](https://github.com/user-attachments/assets/2139c865-638c-4b06-ad93-055f9e372901)
*Network overview dashboard showing key deployments and stateful pods*

#### Features
1. Real-time device status
2. Performance metrics
3. Alert overview
4. Resource utilization

### Deployements Dashboard
![deployements](https://github.com/user-attachments/assets/c880c676-45ee-4bfc-ad4b-6fb2bea68a69)

### Stateful Dashboard
![stateful](https://github.com/user-attachments/assets/d996efe0-eaa6-47a3-abc1-5d0532d8ba5d)


### Kibana Availability Dashboard
![Screenshot 2024-10-30 160251](https://github.com/user-attachments/assets/acd83995-3038-403d-a029-65a2a181b251)

### Kibana Discover Dashboard
![Screenshot 2024-10-30 160108](https://github.com/user-attachments/assets/ea14156e-0cef-4c37-888d-cb8c880d17f3)

### Kibana Traffic Dashboard
![Screenshot 2024-10-30 160201](https://github.com/user-attachments/assets/3e330636-29fa-4881-8c3e-9632394265f9)

### Kibana Firwalls Dashboard
![Screenshot 2024-10-30 160448](https://github.com/user-attachments/assets/3da47dca-cc9b-41e0-ac3f-69dcfc33c039)

### Kibana Query Consol 
![Screenshot 2024-10-30 160841](https://github.com/user-attachments/assets/382b0240-51fc-454b-9695-eb0d0ef9ad76)

### Alert Configuration
![Alert Configuration](docs/images/kibana/alert-config.png)
*Alert configuration interface*

1. Set up email notification parameters
2. Configure alert thresholds
3. Customize alert priorities

## Monitoring Features

### Device Monitoring
![Device Monitoring](docs/images/kibana/device-monitoring.png)
*Real-time device monitoring interface*

- CPU utilization
- Memory usage
- Interface statistics
- Error rates

### Network Analysis
![Network Analysis](docs/images/kibana/network-analysis.png)
*Network traffic analysis and patterns*

- Bandwidth utilization
- Traffic patterns
- Protocol analysis
- Performance metrics

## Alert Management
### Alert Configuration pipeline-config.yaml
```yaml
if [status_changed] == true {
    email {
          to => "junyian@orient-telecoms.com"
          from => "logstash@your-company.com"
          subject => "Interface Status Change Alert"
          body => "Host IP: %{[host][ip]}, Interface: %{InterfaceNo}, Alias: %{ifAlias} changed status from %{previous_status} to %{ifDeviceStatus}"
          address => "smtp.your-company.com"
          port => 25
          username => "elastic"  
          password => "1Qgd0A1BkFxmVuqZ"  
        }
  }
```

## Troubleshooting
- Kindly Refer to our installation documentation

---
