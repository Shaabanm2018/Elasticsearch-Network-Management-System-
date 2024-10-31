# Elasticsearch Network Management System

## Overview
An advanced network administration system designed for proactive monitoring and intelligent assessment of network infrastructure. The system provides real-time monitoring of routers, switches, and firewalls, with sophisticated incident response capabilities and predictive analytics.

### Key Features
- **Intelligent Monitoring**: Real-time surveillance of network devices and infrastructure
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
The main dashboard serves as the primary entry point for elastic search system, offering immediate visibility into system health and performance metrics while enabling quick navigation to more details such as pod logs and specifications.
![Screenshot 2024-10-30 155654](https://github.com/user-attachments/assets/2139c865-638c-4b06-ad93-055f9e372901)
*Network overview dashboard showing key deployments and stateful pods*

#### Features
1. Real-time device status
2. Performance metrics
3. Alert overview
4. Resource utilization

### Deployments Dashboard
This dashboard provides a comprehensive view of all Kubernetes deployments within the system. Monitor the health, status, and performance metrics of Ingress and Kibana services in real-time. It also tracks deployment rollouts, updates, and resource utilization in the cluster.

![deployements](https://github.com/user-attachments/assets/c880c676-45ee-4bfc-ad4b-6fb2bea68a69)

### Stateful Dashboard
This dashboard visualizes the status and metrics of elastic search and logstash statefulSet within the Kubernetes cluster. Monitor persistent volumes, replica status, and state management for applications requiring stable, unique network identifiers and persistent storage.

![stateful](https://github.com/user-attachments/assets/d996efe0-eaa6-47a3-abc1-5d0532d8ba5d)

### Network Data Preview 
The Kibana discover panel offers a detailed overview of network telemetry data collected from various sources. View aggregated network statistics, trends, and real-time data streams from multiple network devices and endpoints in a unified interface.

![Screenshot 2024-10-30 160108](https://github.com/user-attachments/assets/ea14156e-0cef-4c37-888d-cb8c880d17f3)

### Network Device Monitoring
This dashboard Provides real-time monitoring and diagnostics for network infrastructure devices (Switches, Routeres and Firewalls). Track the Up-Down status the network devices.

![Screenshot 2024-10-30 160251](https://github.com/user-attachments/assets/d17e5077-d87d-4d9a-81c3-ee0426a814c0)
*Real-time device monitoring interface*

### Network Traffic Analysis
This is a traffic analysis dashboard for deep insights into network behavior and performance patterns. Identify trends, anomalies, and potential bottlenecks in network traffic.

![Screenshot 2024-10-30 160201](https://github.com/user-attachments/assets/f7c8684a-fdc8-4c81-ae69-7db6b9d008d7)
*Network traffic analysis and patterns*
- Bandwidth utilization
- Traffic patterns
- Protocol analysis
- Performance metrics

### Network Firewalls Analysis
This is a security monitoring dashboard for firewall operations and security policies. Track security events, policy violations, and traffic filtering across your network devices.

![Screenshot 2024-10-30 160448](https://github.com/user-attachments/assets/045da6b9-0e07-4f85-a489-fd1e4ed7f59b)

### Kibana Query Console
The kibana query console is a query interface for deep diving into network data and logs. Perform complex searches, create custom visualizations, and analyze network data using Elasticsearch's powerful query language.

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
