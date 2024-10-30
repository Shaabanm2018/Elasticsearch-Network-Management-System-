# Elasticsearch Network Management System

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

## Monitoring and Analysis Features

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


### Network Data Preview 
![Screenshot 2024-10-30 160108](https://github.com/user-attachments/assets/ea14156e-0cef-4c37-888d-cb8c880d17f3)


### Network Device Monitoring
![Screenshot 2024-10-30 160108](https://github.com/user-attachments/assets/0ecc6cce-3ccf-4e0c-be7a-711edbb7a731)

*Real-time device monitoring interface*

- Device Status
- Memory usage
- Interface statistics
- Error rates

### Network Traffic Analysis
![Screenshot 2024-10-30 160201](https://github.com/user-attachments/assets/f7c8684a-fdc8-4c81-ae69-7db6b9d008d7)

*Network traffic analysis and patterns*

- Bandwidth utilization
- Traffic patterns
- Protocol analysis
- Performance metrics

### Network Firewalls Analysis
![Screenshot 2024-10-30 160448](https://github.com/user-attachments/assets/045da6b9-0e07-4f85-a489-fd1e4ed7f59b)

### Kibana Query Consol 
![Screenshot 2024-10-30 160841](https://github.com/user-attachments/assets/382b0240-51fc-454b-9695-eb0d0ef9ad76)

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
