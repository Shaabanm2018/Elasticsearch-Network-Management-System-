#!/bin/bash

# Check if both namespace, environment, and node name arguments are provided
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <namespace> <environment> <node-name> [additional-arguments...]"
  exit 1
fi

NAMESPACE=$1
ENVIRONMENT=$2
NODE_NAME=$3
ES_POD="elasticsearch-master-0"
ES_USER="elastic"
SECRET_NAME="kibana-service-account-token"
# Directory paths
BASE_PATH="/mnt/data"
ELASTICSEARCH_PATH="${BASE_PATH}/elasticsearch-master-0-${NAMESPACE}"
ELASTICSEARCH1_PATH="${BASE_PATH}/elasticsearch-master-1-${NAMESPACE}"
ELASTICSEARCH2_PATH="${BASE_PATH}/elasticsearch-master-2-${NAMESPACE}"
# Create directory and set permissions
echo "Creating directory for namespace ${NAMESPACE}..."
sudo mkdir -p ${ELASTICSEARCH_PATH}
sudo chown -R 1000:1000 ${ELASTICSEARCH_PATH}
sudo mkdir -p ${ELASTICSEARCH1_PATH}
sudo chown -R 1000:1000 ${ELASTICSEARCH1_PATH}

sudo mkdir -p ${ELASTICSEARCH2_PATH}
sudo chown -R 1000:1000 ${ELASTICSEARCH2_PATH}

# Check if the namespace already exists
if kubectl get namespace "$NAMESPACE" > /dev/null 2>&1; then
  echo "Namespace '$NAMESPACE' already exists."
else
  # Create the namespace
  kubectl create namespace "$NAMESPACE"

  # Check if the namespace creation was successful
  if [ $? -eq 0 ]; then
    echo "Namespace '$NAMESPACE' created successfully."
  else
    echo "Failed to create namespace '$NAMESPACE'."
    exit 1
  fi
fi
echo "Before Env IF"
# Check if the environment is 'staging'
if [ "$ENVIRONMENT" == "staging" ]; then
  echo "Setting up Elasticsearch in staging environment..."
  # Create a directory for staging Elasticsearch
  mkdir -p staging_elasticsearch
  cd staging_elasticsearch || exit
  for ARG in "${@:4}"; do
    case "$ARG" in
      elasticsearch)
        echo "Elasticsearch Setup"
        # Add the Helm repository and update
        helm repo add elastic https://helm.elastic.co
        helm repo update
        # Generate the default values file
        helm show values elastic/elasticsearch > elasticsearch-values.yaml

        # Modify the values file
        #sed -i "s/nameOverride: .*/nameOverride: \"elasticsearch-master-$ENVIRONMENT\"/" elasticsearch-values.yaml
        #sed -i 's/replicas: .*/replicas: 1/' elasticsearch-values.yaml
        #sed -i 's/minimumMasterNodes: .*/minimumMasterNodes: 1/' elasticsearch-values.yaml
        sed -i '/esConfig: {}/c\esConfig:\n  elasticsearch.yml: |\n    path.data: /usr/share/elasticsearch/data' elasticsearch-values.yaml
        sed -i 's/imageTag: .*/imageTag: "8.15.0"/' elasticsearch-values.yaml
        sed -i 's/esJavaOpts: .*/esJavaOpts: "-Xmx2g -Xms2g"/' elasticsearch-values.yaml
        # Modify antiAffinity to be soft
        sed -i 's/antiAffinity: .*/antiAffinity: "soft"/' elasticsearch-values.yaml
        # Add extraInitContainers for fixing permissions
        sed -i '/^extraInitContainers:/c\extraInitContainers:\n  - name: fix-permissions\n    image: busybox\n    command: [\"sh\", \"-c\", \"chown -R 1000:1000 /usr/share/elasticsearch/data\"]\n    securityContext:\n      runAsUser: 0\n    volumeMounts:\n    - name: elasticsearch-master\n      mountPath: /usr/share/elasticsearch/data' elasticsearch-values.yaml
        #printf "volumeClaimTemplates:\n  - metadata:\n      name: \"elasticsearch-master-${ENVIRONMENT}\"\n    spec:\n      accessModes: [ \"ReadWriteOnce\" ]\n      storageClassName: \"local-storage-staging\"\n      resources:\n        requests:\n          storage: 30Gi\n" >> elasticsearch-values.yaml
        sed -i '
/^volumeClaimTemplate:/,/^[a-z]/ {
  /^volumeClaimTemplate:/,/^[a-z]/ {
    /^volumeClaimTemplate:/ {
      c\
volumeClaimTemplate:\
  accessModes: [ "ReadWriteOnce" ]\
  storageClassName: "local-storage-staging"\
  resources:\
    requests:\
      storage: 30Gi
    }
    /^[a-z]/!d
  }
}' elasticsearch-values.yaml

        sed -i '
/^resources:/,/^[a-z]/ {
  /^resources:/,/^[a-z]/ {
    /^resources:/ {
      c\
resources:\
  requests:\
    cpu: "1500m"\
    memory: "3Gi"\
  limits:\
    cpu: "1500m"\
    memory: "3Gi"
    }
    /^[a-z]/!d
  }
}' elasticsearch-values.yaml
        # Install Elasticsearch using Helm
        helm install elasticsearch elastic/elasticsearch -f elasticsearch-values.yaml --namespace "$NAMESPACE"

        # Check if the installation was successful
        if [ $? -eq 0 ]; then
          echo "Elasticsearch installed successfully in namespace '$NAMESPACE'."
        else
          echo "Failed to install Elasticsearch in namespace '$NAMESPACE'."
          exit 1
        fi

        # Create the pv directory and file inside staging_elasticsearch
        mkdir -p pv
        cd pv || exit

        cat <<EOF > elasticsearch-master-pv-0-$NAMESPACE.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: elasticsearch-master-pv-0-$NAMESPACE
spec:
  capacity:
    storage: 30Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage-staging
  local:
    path: /mnt/data/elasticsearch-master-0-$NAMESPACE
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $NODE_NAME  # Node name provided as argument
  claimRef:
    namespace: $NAMESPACE
    name: elasticsearch-master-elasticsearch-master-0
EOF

        # Apply the PersistentVolume
        kubectl delete pv elasticsearch-master-pv-0-$NAMESPACE
        kubectl apply -f elasticsearch-master-pv-0-$NAMESPACE.yaml

        cat <<EOF > elasticsearch-master-pv-1-$NAMESPACE.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: elasticsearch-master-pv-1-$NAMESPACE
spec:
  capacity:
    storage: 30Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage-staging
  local:
    path: /mnt/data/elasticsearch-master-1-$NAMESPACE
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $NODE_NAME  # Node name provided as argument
  claimRef:
    namespace: $NAMESPACE
    name: elasticsearch-master-elasticsearch-master-1
EOF

        # Apply the PersistentVolume
        kubectl delete pv elasticsearch-master-pv-1-$NAMESPACE
        kubectl apply -f elasticsearch-master-pv-1-$NAMESPACE.yaml

        cat <<EOF > elasticsearch-master-pv-2-$NAMESPACE.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: elasticsearch-master-pv-2-$NAMESPACE
spec:
  capacity:
    storage: 30Gi
  volumeMode: Filesystem
  accessModes:
    - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage-staging
  local:
    path: /mnt/data/elasticsearch-master-2-$NAMESPACE
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - $NODE_NAME  # Node name provided as argument
  claimRef:
    namespace: $NAMESPACE
    name: elasticsearch-master-elasticsearch-master-2
EOF

        # Apply the PersistentVolume
        kubectl delete pv elasticsearch-master-pv-2-$NAMESPACE
        kubectl apply -f elasticsearch-master-pv-2-$NAMESPACE.yaml

        # Go back to staging_elasticsearch directory
        cd ..

        # Create the storage directory and file inside staging_elasticsearch
        mkdir -p storage
        cd storage || exit

        cat <<EOF > storage_class_staging.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-staging
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF

        # Apply the StorageClass
        kubectl apply -f storage_class_staging.yaml

        # Return to the staging_elasticsearch directory
        cd ..
        ;;
      kibana)
        echo "Kibana mentioned"

        mkdir -p kibana
        cd kibana || exit
        echo "Fetching Elasticsearch password..."
        ELASTIC_PASSWORD=$(kubectl get secret elasticsearch-master-credentials -n "$NAMESPACE" -o go-template='{{.data.password | base64decode}}')
        echo "Elasticsearch password fetched: $ELASTIC_PASSWORD"

        echo "Obtaining Elasticsearch token..."
	MAX_RETRIES=5
        RETRY_INTERVAL=30
        for i in $(seq 1 $MAX_RETRIES); do
            CURL_RESPONSE=$(kubectl exec -it elasticsearch-master-0 -n "$NAMESPACE" -- \
              curl -s -k -X POST -u elastic:"$ELASTIC_PASSWORD" \
                "https://localhost:9200/_security/service/elastic/kibana/credential/token/kibana_token?pretty")

            if [[ $CURL_RESPONSE == *"\"created\" : true"* ]]; then
                echo "Token created successfully on attempt $i"
                break
            else
                echo "Attempt $i failed. Retrying in $RETRY_INTERVAL seconds..."
                sleep $RETRY_INTERVAL
            fi

            if [ $i -eq $MAX_RETRIES ]; then
                echo "Failed to create token after $MAX_RETRIES attempts."
                exit 1
            fi
        done
        TOKEN=$(echo "$CURL_RESPONSE" | jq -r '.token.value')
        kubectl create secret generic kibana-service-account-token --from-literal=token="$TOKEN" -n "$NAMESPACE"
        echo "Token obtained successfully"
        echo "Token: $TOKEN"


        cat <<EOF > kibana-deployment-$NAMESPACE.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kibana
  namespace: $NAMESPACE
spec:
  replicas: 1
  selector:
    matchLabels:
      app: kibana
  template:
    metadata:
      labels:
        app: kibana
    spec:
      containers:
      - name: kibana
        image: docker.elastic.co/kibana/kibana:8.15.0
        env:
        - name: ELASTICSEARCH_HOSTS
          value: "https://elasticsearch-master:9200"
        - name: ELASTICSEARCH_SERVICEACCOUNTTOKEN
          valueFrom:
            secretKeyRef:
              name: kibana-service-account-token
              key: token
        - name: ELASTICSEARCH_SSL_CERTIFICATEAUTHORITIES
          value: "/usr/share/kibana/config/certs/ca.crt"
        - name: ELASTICSEARCH_SSL_VERIFICATIONMODE
          value: "certificate"
        ports:
        - containerPort: 5601
        volumeMounts:
        - name: elasticsearch-certs
          mountPath: /usr/share/kibana/config/certs
          readOnly: true
      volumes:
      - name: elasticsearch-certs
        secret:
          secretName: elasticsearch-master-certs
---
apiVersion: v1
kind: Service
metadata:
  name: kibana
  namespace: $NAMESPACE
spec:
  selector:
    app: kibana
  ports:
  - port: 5601
    targetPort: 5601
EOF
        kubectl apply -f kibana-deployment-$NAMESPACE.yaml -n $NAMESPACE
        cd ..
        ;;
      logstash)
        helm pull elastic/logstash --untar
        cd logstash
        sed -i 's/appVersion: .*/appVersion: "8.15.0"/' Chart.yaml
        sed -i 's/version: .*/version: "8.15.0"/' Chart.yaml
        sed -i 's/imageTag: .*/imageTag: "8.15.0"/' values.yaml
        helm dependency update
        helm install logstash . -n $NAMESPACE
        cd ..
        ;;
      nmap)
        ELASTIC_PASSWORD=$(kubectl get secret elasticsearch-master-credentials -n "$NAMESPACE" -o go-template='{{.data.password | base64decode}}')
        #sudo apt install namp
        helm create logstash_parent_nmap
        rm -rf logstash_parent_nmap/templates/*
        cat <<EOF >> logstash_parent_nmap/Chart.yaml
dependencies:
  - name: logstash
    version: '8.5.1'
    repository: '@elastic'
EOF
        cat <<EOF >> logstash_parent_nmap/templates/logstash-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: logstash-config
data:
  logstash.yml: |
    # Add any configuration you need
    http.host: "0.0.0.0"
    xpack.monitoring.elasticsearch.hosts: [ "https://elasticsearch-master:9200" ]
    xpack.monitoring.elasticsearch.username: elastic
    xpack.monitoring.elasticsearch.password: "$ELASTIC_PASSWORD"
    xpack.monitoring.elasticsearch.ssl.certificate_authority: /usr/share/logstash/config/certs/ca.crt
    xpack.monitoring.enabled: true

  pipelines.yml: |
    - pipeline.id: main
      path.config: "/usr/share/logstash/pipeline/main*.conf"
EOF
        cat <<EOF >> logstash_parent_nmap/templates/pipelines.yaml 
apiVersion: v1
kind: ConfigMap
metadata:
  name: pipeline-config
data:
  main_01_input.conf: |
    input {
       http {
        port => 8080
        codec => json
      }
      
    }
  main_02_filter.conf: |
    filter {
      split {
        field => "hosts"
      }

      mutate {
        rename => {
          "[hosts][ip]" => "ip_address"
          "[hosts][status]" => "host_status"
          "[hosts][reason]" => "status_reason"
          "[hosts][hostname]" => "hostname"
        }
        remove_field => ["event", "http", "url", "user_agent", "hosts"]
      }

      date {
        match => [ "timestamp", "ISO8601" ]
        target => "@timestamp"
      }
    }
  main_03_output.conf: |
    output {
      elasticsearch {
        hosts => ["https://elasticsearch-master:9200"]
        ssl => true
        cacert => "/usr/share/logstash/config/certs/ca.crt"
        user => "elastic"   # Replace with actual username if authentication is required
        password => "$ELASTIC_PASSWORD"
      }
      stdout {
        codec => rubydebug
      }
    }
EOF
        cat <<EOF >> logstash_parent_nmap/values.yaml
logstash:
  image: "docker.elastic.co/logstash/logstash"
  imageTag: "8.15.0"
  extraVolumes:
    - name: logstash-config
      configMap:
        name: logstash-config
        items:
          - key: logstash.yml
            path: logstash.yml
          - key: pipelines.yml
            path: pipelines.yml

    - name: pipelines
      configMap:
        name: pipeline-config

    - name: ca-cert-volume
      secret:
        secretName: elasticsearch-master-certs

  extraVolumeMounts:
    - name: logstash-config
      mountPath: /usr/share/logstash/config/logstash.yml
      subPath: logstash.yml

    - name: logstash-config
      mountPath: /usr/share/logstash/config/pipelines.yml
      subPath: pipelines.yml

    - name: pipelines
      mountPath: /usr/share/logstash/pipeline

    - name: ca-cert-volume
      mountPath: /usr/share/logstash/config/certs/ca.crt
      subPath: ca.crt
  service:
    type: NodePort
    ports:
      - name: http
        port: 8080
        protocol: TCP
        targetPort: 8080
        nodePort: 30003 


EOF
#         cat << 'OUTER' > nmap_scan.sh
# #!/bin/bash

# NETWORK="172.23.37.31/24"
# OUTPUT_FILE="/tmp/nmap_scan_results.json"
# NODE_IP="172.23.37.31"  # Replace with the IP of one of your nodes if different
# NODE_PORT="30003"  # The NodePort assigned to your Logstash service

# # Run nmap and format the output as valid JSON
# nmap -A -oX - $NETWORK | xmlstarlet sel -T -t -o '{"hosts":[' -n \
#   -m "//host" -o "{" \
#   -o '"ip":"' -v "address/@addr" -o '",' \
#   -o '"status":"' -v "status/@state" -o '",' \
#   -o '"reason":"' -v "status/@reason" -o '",' \
#   -o '"hostname":"' -v "hostnames/hostname/@name" -o '"' \
#   -o "}," -n \
# | sed '$ s/,$//' | sed '$ s/$/]}/' > $OUTPUT_FILE

# # Send the results to Logstash
# curl -H "Content-Type: application/json" -XPOST "http://${NODE_IP}:${NODE_PORT}" --data-binary @$OUTPUT_FILE
# OUTER
#         chmod +x nmap_scan.sh
        helm dep build logstash_parent_nmap/ -n "$NAMESPACE"
        helm install logstash-nmap logstash_parent_nmap/ -n "$NAMESPACE"
        cd ..
        ;;
      *)
        echo "Unknown argument: $ARG"
        ;;
    esac
  done
  cd ..
else
  echo "Environment '$ENVIRONMENT' is not recognized. No additional actions taken."
fi
