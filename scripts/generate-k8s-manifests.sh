#!/bin/bash

# 生成其他业务服务的K8s部署文件

SERVICES=("risk-service:8082" "ledger-service:8083" "notification-service:8084" "transfer-service:8085")

for service_info in "${SERVICES[@]}"; do
    IFS=':' read -r service port <<< "$service_info"
    
    cat > "k8s/${service}/deployment.yaml" <<EOF
apiVersion: v1
kind: Secret
metadata:
  name: ${service}-secret
  namespace: isbank
type: Opaque
stringData:
  mysql-password: Zmzzmz010627!

---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${service}
  namespace: isbank
  labels:
    app: ${service}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${service}
  template:
    metadata:
      labels:
        app: ${service}
    spec:
      initContainers:
      - name: wait-for-mysql
        image: busybox:1.35
        command: ['sh', '-c', 'until nc -z mysql.isbank.svc.cluster.local 3306; do echo waiting for mysql; sleep 2; done;']
      - name: wait-for-eureka
        image: busybox:1.35
        command: ['sh', '-c', 'until nc -z eureka-server.isbank.svc.cluster.local 8761; do echo waiting for eureka; sleep 2; done;']
      containers:
      - name: ${service}
        image: 1.94.151.57:85/test/isbank-${service}:latest
        imagePullPolicy: Always
        ports:
        - containerPort: ${port}
          name: http
        env:
        - name: JAVA_OPTS
          value: "-Xms256m -Xmx512m"
        - name: SPRING_PROFILES_ACTIVE
          value: "k8s"
        - name: MYSQL_PASSWORD
          valueFrom:
            secretKeyRef:
              name: ${service}-secret
              key: mysql-password
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "1000m"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: ${port}
          initialDelaySeconds: 90
          periodSeconds: 10
          timeoutSeconds: 5
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: ${port}
          initialDelaySeconds: 60
          periodSeconds: 5
          timeoutSeconds: 3

---
apiVersion: v1
kind: Service
metadata:
  name: ${service}
  namespace: isbank
  labels:
    app: ${service}
spec:
  type: ClusterIP
  selector:
    app: ${service}
  ports:
  - port: ${port}
    targetPort: ${port}
    protocol: TCP
    name: http
EOF

    echo "Generated k8s/${service}/deployment.yaml"
done

echo "All K8s manifests generated successfully!"

