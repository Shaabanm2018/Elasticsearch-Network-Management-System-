#!/bin/bash

# Check if both namespace, environment, and additional arguments are provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <namespace> <environment> [additional-arguments...]"
  exit 1
fi

NAMESPACE=$1
ENVIRONMENT=$2
ES_POD="elasticsearch-master-0"
ES_USER="elastic"
SECRET_NAME="kibana-service-account-token"
ELASTIC_PASSWORD=$(kubectl get secret elasticsearch-master-credentials -n "$NAMESPACE" -o go-template='{{.data.password | base64decode}}')
echo "Elasticsearch password fetched: $ELASTIC_PASSWORD"
# Check if the environment is 'staging'
if [ "$ENVIRONMENT" == "staging" ]; then
  echo "Tearing down Elasticsearch in staging environment..."

  # Loop through all arguments starting from the third one
  for ARG in "${@:3}"; do
    if [[ "$ARG" == "elasticsearch" || "$ARG" == "all" ]]; then
      if [ -z "$ELASTICSEARCH_EXECUTED" ]; then
        echo "Elasticsearch Uninstallation Started"
        # Uninstall Elasticsearch using Helm
        kubectl exec -it elasticsearch-master-0 -n "$NAMESPACE" --   curl -k -X DELETE -u elastic:"$ELASTIC_PASSWORD"   "https://localhost:9200/_security/service/elastic/kibana/credential/token/kibana_token"
        helm uninstall elasticsearch --namespace "$NAMESPACE"
        # Check if the uninstallation was successful
        if [ $? -eq 0 ]; then
          echo "Elasticsearch uninstalled successfully from namespace '$NAMESPACE'."
        else
          echo "Failed to uninstall Elasticsearch from namespace '$NAMESPACE'."
          #exit 1
        fi
        ELASTICSEARCH_EXECUTED=true
      fi
    fi

    if [[ "$ARG" == "kibana" || "$ARG" == "all" ]]; then
      if [ -z "$KIBANA_EXECUTED" ]; then
        echo "Kibana Uninstallation Started"
        kubectl delete deployment kibana -n "$NAMESPACE"
        kubectl delete service kibana -n "$NAMESPACE"
        KIBANA_EXECUTED=true
      fi
    fi

    if [[ "$ARG" == "logstash" || "$ARG" == "all" ]]; then
      if [ -z "$LOGSTASH_EXECUTED" ]; then
        echo "Logstash Uninstallation Started"
        helm uninstall logstash -n "$NAMESPACE"
        LOGSTASH_EXECUTED=true
      fi
    fi
    if [[ "$ARG" == "nmap" || "$ARG" == "all" ]]; then
      if [ -z "$NMAP_EXECUTED" ]; then
        echo "Nmap Uninstallation Started"
        helm uninstall logstash-nmap -n "$NAMESPACE"
        NMAP_EXECUTED=true
      fi
    fi

    if [ "$ARG" == "all" ]; then
      if [ -z "$ALL_EXECUTED" ]; then
        # Remove the staging directory
        if [ -d "staging_elasticsearch" ]; then
          rm -rf staging_elasticsearch
          echo "Removed staging_elasticsearch directory."
        else
          echo "staging_elasticsearch directory not found."
        fi
        
        # Delete the namespace
        kubectl delete namespace "$NAMESPACE"
        kubectl delete pv elasticsearch-master-pv-0-"$NAMESPACE"
        kubectl delete pv elasticsearch-master-pv-1-"$NAMESPACE"
        kubectl delete pv elasticsearch-master-pv-2-"$NAMESPACE"
        # Check if the namespace deletion was successful
        if [ $? -eq 0 ]; then
          echo "Namespace '$NAMESPACE' deleted successfully."
        else
          echo "Failed to delete namespace '$NAMESPACE'."
          exit 1
        fi
        ALL_EXECUTED=true
      fi
    fi
  done
else
  echo "Environment '$ENVIRONMENT' is not recognized. No actions taken."
fi
        