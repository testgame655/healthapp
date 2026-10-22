# Healthapp Kubernetes Manifests - Jenkins CI/CD (kubeadm + Docker Hub)

Clean Kubernetes manifests for Jenkins CI/CD pipeline deployment on kubeadm with Docker Hub.

## Prerequisites

- kubeadm cluster (RHEL 10 or any Linux)
- kubectl configured
- nginx ingress controller installed
- Minimum 8GB RAM, 4 CPU cores
- Create host directories before deployment:
  ```bash
  sudo mkdir -p /data/bbhealthapp/uploads
  sudo mkdir -p /data/bbhealthapp/database
  sudo chown -R $(whoami):$(whoami) /data/bbhealthapp
  ```

## Folder Structure

```
k8s-jenkins/
├── namespace.yaml              # Creates bbhealthapp namespace
├── configmap.yaml              # Application configuration
├── secret.yaml                # JWT secrets and passwords
├── pvc.yaml                    # Persistent volume claims (local-path)
├── nginx-config.yaml           # Nginx reverse proxy configuration
├── frontend-deployment.yaml    # Frontend deployment
├── frontend-service.yaml        # Frontend service
├── master-service-deployment.yaml # Master backend deployment
├── master-service-service.yaml   # Master backend service
├── register-service-deployment.yaml # Register backend deployment
├── register-service-service.yaml  # Register backend service
├── document-service-deployment.yaml # Document backend deployment
├── document-service-service.yaml  # Document backend service
└── ingress.yaml                # Ingress for external access
```

## Configuration Details

- **Docker Images:** fhodam/healthapp-xxx:latest
- **Replicas:** 1 per service (optimized for 8GB RAM)
- **Memory:** 512Mi request, 1Gi limit per backend service
- **Storage:** manual hostPath PVs (no provisioner needed)
- **Network:** Nginx reverse proxy for API routing
- **Spring Profile:** dev
- **Namespace:** bbhealthapp

## Resource Usage

- Total Memory: ~3.25Gi
- Total CPU: ~1700m
- Well within 8GB RAM / 4 CPU limits

## Deployment Order

1. Apply namespace.yaml
2. Apply configmap.yaml
3. Apply secret.yaml
4. Apply pvc.yaml
5. Apply all service files
6. Apply all deployment files
7. Apply ingress.yaml

## Quick Deploy

```bash
kubectl apply -f k8s-jenkins/
```

## Verification

```bash
kubectl get pods -n bbhealthapp
kubectl get svc -n bbhealthapp
kubectl get pvc -n bbhealthapp
kubectl get ingress -n bbhealthapp
```

## Access Application

### Option 1: Port Forwarding
```bash
kubectl port-forward svc/frontend -n bbhealthapp 8080:80 --address 0.0.0.0
```
Browser: `http://<VM-IP>:8080/`

### Option 2: Ingress (if LoadBalancer IP available)
```bash
kubectl get ingress -n bbhealthapp
```
Browser: `http://<INGRESS-IP>/`

## Jenkins Integration

This folder is designed for Jenkins CI/CD pipeline:

1. Jenkins clones code from GitHub
2. Builds Docker images
3. Pushes to Docker Hub
4. Updates image tags using sed command
5. Deploys to Kubernetes
6. Verifies deployment

## Key Features

- ✅ Clean file names (no numbered prefixes)
- ✅ Separate deployment and service files
- ✅ No kustomization complexity
- ✅ Docker Hub image references
- ✅ Jenkins-friendly sed command
- ✅ Nginx reverse proxy for API routing
- ✅ Health probes removed (to avoid 401 errors)
- ✅ 1 replica per service (optimized for resources)

## Differences from Original k8s Folder

| Aspect | Original k8s | k8s-jenkins |
|--------|---------------|-------------|
| File naming | Numbered prefixes (00-, 01-, 10-) | Clean names |
| Deployment/Service | Combined in single files | Separate files |
| Kustomization | Present | Removed |
| MetalLB | Present | Removed |
| Storage | hostPath | local-path |
| Jenkins-friendly | No | Yes |
| Image references | Mixed | Docker Hub consistent |

## Troubleshooting

### PVC Pending
```bash
# Check if directories exist
ls -la /data/bbhealthapp/
# Create if missing
sudo mkdir -p /data/bbhealthapp/uploads /data/bbhealthapp/database
sudo chown -R $(whoami):$(whoami) /data/bbhealthapp
# Delete and recreate PVCs
kubectl delete pvc database-pvc uploads-pvc -n bbhealthapp
kubectl apply -f pvc.yaml
```

### Pods Pending
```bash
kubectl describe pod <pod-name> -n bbhealthapp
```

### Image Pull Errors
```bash
kubectl create secret docker-registry regcred --docker-username=<user> --docker-password=<pass> --docker-email=<email> -n bbhealthapp
```

Add to deployment files:
```yaml
imagePullSecrets:
- name: regcred
```

## Notes

- This folder replaces the original k8s folder for Jenkins CI/CD
- Designed for automated deployment without manual intervention
- Images use Docker Hub (fhodam/healthapp-xxx:latest)
- sed command in Jenkinsfile will update :latest to :BUILD_NUMBER
