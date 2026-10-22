# Task 4: Kubernetes Deployment - Completion Guide

## Overview

This guide covers deploying the Healthapp application to EKS using Kubernetes manifests (without Helm). The deployment includes frontend, backend services, persistent storage, and external access via LoadBalancer.

## Prerequisites

1. **EKS Cluster Running** (from Task 2)
   - Cluster name: healthapp-eks-cluster
   - Region: us-west-2
   - Node groups: public and private

2. **Docker Images Pushed to ECR** (from Task 3)
   - healthapp-frontend:latest
   - healthapp-master-service:latest
   - healthapp-register-service:latest
   - healthapp-document-service:latest

3. **kubectl installed and configured**
   - Verify: `kubectl version --client`
   - Connected to EKS cluster

4. **AWS IAM Authenticator** (for EKS)
   - Verify: `aws-iam-authenticator version`

## Kubernetes Manifests Created

All manifests are located in the `k8s/` directory:

### 1. Namespace
- **File**: `namespace.yaml`
- **Namespace**: bbhealthapp
- **Purpose**: Isolates all Healthapp resources

### 2. ConfigMap
- **File**: `configmap.yaml`
- **Purpose**: Application configuration (non-sensitive)
- **Includes**:
  - Service hostnames and ports
  - Spring profiles
  - H2 database configuration
  - File upload settings

### 3. Secret
- **File**: `secret.yaml`
- **Purpose**: Sensitive data (JWT secrets)
- **Includes**:
  - TOKEN_SECRET_MASTER
  - TOKEN_SECRET_REGISTER
  - TOKEN_SECRET_DOCUMENT
  - DB_PASSWORD

### 4. Persistent Volume Claims (PVCs)
- **File**: `pvc.yaml`
- **PVCs**:
  - `uploads-pvc`: 10Gi for file uploads (ReadWriteMany)
  - `database-pvc`: 5Gi for H2 database (ReadWriteOnce)

### 5. Deployments
- **Files**:
  - `master-service-deployment.yaml` - Master/Auth service (2 replicas)
  - `register-service-deployment.yaml` - Register service (2 replicas)
  - `document-service-deployment.yaml` - Document service (2 replicas)
  - `frontend-deployment.yaml` - React frontend (2 replicas)

### 6. Services
- **Files**:
  - `master-service-service.yaml` - ClusterIP (port 8081)
  - `register-service-service.yaml` - ClusterIP (port 8082)
  - `document-service-service.yaml` - ClusterIP (port 8083)
  - `frontend-service.yaml` - LoadBalancer (port 80)

### 7. Ingress
- **File**: `ingress.yaml`
- **Type**: AWS Application Load Balancer (ALB)
- **Routes**:
  - `/` → Frontend
  - `/api/` → Master Service
  - `/register/` → Register Service
  - `/document/` → Document Service

## Subtask 1: Kubernetes Deployment Using Manifests

### Step 1: Update Image URLs in Manifests

Before deploying, you need to update the ECR image URLs in the deployment manifests.

**On Windows (PowerShell)**:
```powershell
cd k8s
.\update-image-urls.ps1 -AccountId "YOUR_ACCOUNT_ID"
```

**On Linux/Mac**:
You'll need to manually update the image URLs in each deployment file:
- master-service-deployment.yaml
- register-service-deployment.yaml
- document-service-deployment.yaml
- frontend-deployment.yaml

Replace:
```
<ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/<SERVICE_NAME>:latest
```

With your actual ECR image URL:
```
123456789012.dkr.ecr.us-west-2.amazonaws.com/healthapp-master-service:latest
```

### Step 2: Configure kubectl for EKS

If not already configured:
```bash
aws eks update-kubeconfig --name healthapp-eks-cluster --region us-west-2
```

Verify connection:
```bash
kubectl cluster-info
kubectl get nodes
```

### Step 3: Deploy to Kubernetes

**On Windows (PowerShell)**:
```powershell
cd k8s
.\deploy-k8s.ps1
```

**On Linux/Mac**:
```bash
cd k8s
chmod +x deploy-k8s.sh
./deploy-k8s.sh
```

This will deploy all resources in the correct order:
1. Namespace
2. ConfigMap
3. Secret
4. PVCs
5. Services
6. Deployments
7. Ingress

### Step 4: Verify Pod Status

Check that all pods are running:
```bash
kubectl get pods -n bbhealthapp
```

Expected output:
```
NAME                                READY   STATUS    RESTARTS   AGE
document-service-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
document-service-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
frontend-xxxxxxxxxx-xxxxx           1/1     Running   0          2m
frontend-xxxxxxxxxx-xxxxx           1/1     Running   0          2m
master-service-xxxxxxxxxx-xxxxx     1/1     Running   0          2m
master-service-xxxxxxxxxx-xxxxx     1/1     Running   0          2m
register-service-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
register-service-xxxxxxxxxx-xxxxx   1/1     Running   0          2m
```

### Step 5: Check Pod Logs

Check logs for any errors:
```bash
# Frontend logs
kubectl logs -n bbhealthapp -l app=frontend

# Master service logs
kubectl logs -n bbhealthapp -l app=master-service

# Register service logs
kubectl logs -n bbhealthapp -l app=register-service

# Document service logs
kubectl logs -n bbhealthapp -l app=document-service
```

### Step 6: Verify PVCs are Bound

Check PVC status:
```bash
kubectl get pvc -n bbhealthapp
```

Expected output:
```
NAME             STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   AGE
database-pvc     Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   5Gi        RWO            gp2            5m
uploads-pvc      Bound    pvc-xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx   10Gi       RWX            gp2            5m
```

### Step 7: Verify Services

Check services:
```bash
kubectl get svc -n bbhealthapp
```

Expected output:
```
NAME               TYPE           CLUSTER-IP       EXTERNAL-IP      PORT(S)        AGE
document-service   ClusterIP      10.100.xxx.xxx    <none>           8083/TCP       5m
frontend           LoadBalancer   10.100.xxx.xxx    xxxx-xxxx.us-west-2.elb.amazonaws.com   80:xxxxx/TCP   5m
master-service     ClusterIP      10.100.xxx.xxx    <none>           8081/TCP       5m
register-service   ClusterIP      10.100.xxx.xxx    <none>           8082/TCP       5m
```

### Step 8: Verify Ingress

Check ingress:
```bash
kubectl get ingress -n bbhealthapp
```

### Screenshots Required for Subtask 1

1. **Running Pods**
   - Command: `kubectl get pods -n bbhealthapp`
   - Show all 8 pods in Running state

2. **Pod Logs**
   - Command: `kubectl logs <pod-name> -n bbhealthapp`
   - Show logs for at least one pod (preferably a backend service)

3. **PVCs**
   - Command: `kubectl get pvc -n bbhealthapp`
   - Show both PVCs in Bound state

4. **Services**
   - Command: `kubectl get svc -n bbhealthapp`
   - Show all 4 services with LoadBalancer EXTERNAL-IP

5. **Ingress**
   - Command: `kubectl get ingress -n bbhealthapp`
   - Show ingress with ALB address

## Subtask 2: Helm Chart Deployment

**SKIPPED** - As requested, Helm is not being used. All deployment is done via Kubernetes manifests.

## Subtask 3: Application Access and Testing

### Step 1: Get LoadBalancer URL

Get the external IP/hostname of the frontend service:
```bash
kubectl get svc frontend -n bbhealthapp
```

Look for the `EXTERNAL-IP` field. It will be in the format:
```
xxxx-xxxx.us-west-2.elb.amazonaws.com
```

### Step 2: Access the Application

Open a web browser and navigate to:
```
http://<EXTERNAL-IP>
```

For example:
```
http://abcd1234-efgh5678.us-west-2.elb.amazonaws.com
```

### Step 3: Test Frontend

1. Verify the React application loads
2. Check that the UI displays correctly
3. Navigate through different pages

### Step 4: Test Backend APIs

You can test the backend APIs using curl or a tool like Postman:

**Master Service (Auth)**:
```bash
curl http://<EXTERNAL-IP>/api/
```

**Register Service**:
```bash
curl http://<EXTERNAL-IP>/register/
```

**Document Service**:
```bash
curl http://<EXTERNAL-IP>/document/
```

### Step 5: Check for Errors in Logs

Monitor logs while testing:
```bash
# Watch logs in real-time
kubectl logs -n bbhealthapp -l app=master-service -f

# Check for errors
kubectl logs -n bbhealthapp -l app=master-service | grep -i error
```

### Screenshots Required for Subtask 3

1. **Application in Browser**
   - Open the application URL in a browser
   - Take screenshot showing the loaded application

2. **Successful API Calls**
   - Use curl or Postman to test API endpoints
   - Take screenshot showing successful responses

3. **LoadBalancer URL**
   - Command: `kubectl get svc frontend -n bbhealthapp`
   - Show the EXTERNAL-IP/hostname

## Troubleshooting

### Pods Not Starting

**Issue**: Pods stuck in Pending or ImagePullBackOff state

**Solutions**:
1. Check pod events:
   ```bash
   kubectl describe pod <pod-name> -n bbhealthapp
   ```

2. Verify image URL is correct:
   ```bash
   kubectl get deployment <deployment-name> -n bbhealthapp -o yaml | grep image
   ```

3. Verify ECR access:
   - Ensure your AWS credentials are configured
   - Ensure ECR repositories exist

### PVCs Not Binding

**Issue**: PVCs stuck in Pending state

**Solutions**:
1. Check PVC events:
   ```bash
   kubectl describe pvc <pvc-name> -n bbhealthapp
   ```

2. Verify storage class exists:
   ```bash
   kubectl get storageclass
   ```

3. For EKS, gp2 storage class should be available by default

### Services Not Accessible

**Issue**: Cannot access services via LoadBalancer

**Solutions**:
1. Check service status:
   ```bash
   kubectl describe svc frontend -n bbhealthapp
   ```

2. Verify LoadBalancer is provisioned:
   - It may take a few minutes for AWS to provision the ELB
   - Check AWS Console → EC2 → Load Balancers

3. Check security groups:
   - Ensure port 80 is open in the node security group

### Application Errors

**Issue**: Application returns errors

**Solutions**:
1. Check pod logs:
   ```bash
   kubectl logs <pod-name> -n bbhealthapp
   ```

2. Check ConfigMap values:
   ```bash
   kubectl get configmap app-config -n bbhealthapp -o yaml
   ```

3. Check Secret values:
   ```bash
   kubectl get secret app-secrets -n bbhealthapp -o yaml
   ```

4. Verify service-to-service communication:
   ```bash
   kubectl exec -it <pod-name> -n bbhealthapp -- curl http://master-service:8081
   ```

## Verification Checklist

After deployment, verify:

- [ ] Namespace bbhealthapp created
- [ ] ConfigMap app-config created
- [ ] Secret app-secrets created
- [ ] PVCs (uploads-pvc, database-pvc) are Bound
- [ ] All 8 pods are Running
- [ ] All pods have 1/1 READY
- [ ] No pods in Error or CrashLoopBackOff state
- [ ] All 4 services created
- [ ] Frontend service has LoadBalancer type
- [ ] LoadBalancer has EXTERNAL-IP assigned
- [ ] Ingress created with ALB
- [ ] Application accessible via LoadBalancer URL
- [ ] Frontend loads in browser
- [ ] Backend APIs respond to requests
- [ ] No errors in pod logs

## Clean Up

To remove all resources:
```bash
cd k8s
kubectl delete -f ingress.yaml
kubectl delete -f frontend-deployment.yaml
kubectl delete -f frontend-service.yaml
kubectl delete -f document-service-deployment.yaml
kubectl delete -f document-service-service.yaml
kubectl delete -f register-service-deployment.yaml
kubectl delete -f register-service-service.yaml
kubectl delete -f master-service-deployment.yaml
kubectl delete -f master-service-service.yaml
kubectl delete -f pvc.yaml
kubectl delete -f secret.yaml
kubectl delete -f configmap.yaml
kubectl delete -f namespace.yaml
```

Or delete the entire namespace:
```bash
kubectl delete namespace bbhealthapp
```

## Files Created

### Kubernetes Manifests
- `k8s/namespace.yaml` - Namespace definition
- `k8s/configmap.yaml` - Application configuration
- `k8s/secret.yaml` - Sensitive data
- `k8s/pvc.yaml` - Persistent volume claims
- `k8s/master-service-deployment.yaml` - Master service deployment
- `k8s/master-service-service.yaml` - Master service
- `k8s/register-service-deployment.yaml` - Register service deployment
- `k8s/register-service-service.yaml` - Register service
- `k8s/document-service-deployment.yaml` - Document service deployment
- `k8s/document-service-service.yaml` - Document service
- `k8s/frontend-deployment.yaml` - Frontend deployment
- `k8s/frontend-service.yaml` - Frontend service (LoadBalancer)
- `k8s/ingress.yaml` - Ingress for external access

### Deployment Scripts
- `k8s/update-image-urls.ps1` - Script to update ECR image URLs
- `k8s/deploy-k8s.ps1` - PowerShell deployment script
- `k8s/deploy-k8s.sh` - Bash deployment script

### Documentation
- `K8S_TASK_COMPLETION.md` - This guide

## Summary

✅ **Subtask 1: Kubernetes Deployment Using Manifests** - READY
- All Kubernetes manifests created
- Deployment scripts created
- Verification steps documented

⏭️ **Subtask 2: Helm Chart Deployment** - SKIPPED
- As requested, Helm is not being used

✅ **Subtask 3: Application Access and Testing** - READY
- Access instructions documented
- Testing steps documented
- Screenshot requirements documented

**The Kubernetes deployment is ready. Follow the steps above to deploy and test the application.**
