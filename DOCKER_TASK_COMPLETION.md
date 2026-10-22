# Task 3: Docker Setup - Completion Guide

## Overview

This guide covers the complete Docker setup for the Healthapp application, including Dockerfile creation, ECR repository setup, and building/pushing images to ECR.

## Prerequisites

1. **Docker installed and running**
   - Verify: `docker --version`
   - Verify: `docker ps`

2. **AWS CLI installed and configured**
   - Verify: `aws --version`
   - Verify: `aws configure`

3. **ECR repositories created** (via Terraform from Task 2)
   - healthapp-frontend
   - healthapp-master-service
   - healthapp-register-service
   - healthapp-document-service

## Subtask 1: Dockerfile Creation

### Status: ✅ COMPLETED

All Dockerfiles have been created and reviewed:

#### Frontend Dockerfile
**Location**: `bbhealthapp-frontend/Dockerfile`
**Base Image**: node:18-alpine (updated from node:14-alpine)
**Port**: 80
**Build**: Multi-stage build (Node.js build + Nginx serve)

**Key Changes Made**:
- Updated from Node.js 14 to Node.js 18 to support React-Draggable 4.7.2
- Multi-stage build for optimized image size
- Nginx for serving static files

#### Master Service Dockerfile
**Location**: `bbhealthapp-backend/bbhealthapp-api-master/Dockerfile`
**Base Image**: maven:3.6.3-openjdk-8 (build), openjdk:8-jre-alpine (runtime)
**Port**: 8081
**Build**: Multi-stage build (Maven build + JRE runtime)

#### Register Service Dockerfile
**Location**: `bbhealthapp-backend/bbhealthapp-api-register/Dockerfile`
**Base Image**: maven:3.6.3-openjdk-8 (build), openjdk:8-jre-alpine (runtime)
**Port**: 8082
**Build**: Multi-stage build (Maven build + JRE runtime)

#### Document Service Dockerfile
**Location**: `bbhealthapp-backend/bbhealthapp-api-document/Dockerfile`
**Base Image**: maven:3.6.3-openjdk-11 (build), openjdk:11-jre-slim (runtime)
**Port**: 8083
**Build**: Multi-stage build (Maven build + JRE runtime)

### Steps to Test Docker Images Locally

#### Step 1: Build All Images Locally

**On Windows (PowerShell)**:
```powershell
.\build-local.ps1
```

**On Linux/Mac/Git Bash**:
```bash
chmod +x build-local.sh
./build-local.sh
```

This will build all 4 Docker images:
- healthapp-frontend:latest
- healthapp-master-service:latest
- healthapp-register-service:latest
- healthapp-document-service:latest

#### Step 2: Verify Images Were Built

```bash
docker images
```

You should see all 4 images listed.

#### Step 3: Test Frontend Image

```bash
docker run -d -p 80:80 --name frontend-test healthapp-frontend
```

Access at: http://localhost:80

#### Step 4: Test Backend Services

```bash
# Master Service
docker run -d -p 8081:8081 --name master-test healthapp-master-service

# Register Service
docker run -d -p 8082:8082 --name register-test healthapp-register-service

# Document Service
docker run -d -p 8083:8083 --name document-test healthapp-document-service
```

#### Step 5: Check Container Logs

```bash
# Frontend logs
docker logs frontend-test

# Master service logs
docker logs master-test

# Register service logs
docker logs register-test

# Document service logs
docker logs document-test
```

#### Step 6: Stop and Remove Test Containers

```bash
docker stop frontend-test master-test register-test document-test
docker rm frontend-test master-test register-test document-test
```

### Screenshots Required for Subtask 1

1. **Docker Build Command**
   - Take screenshot of the build command output showing successful builds
   - Command: `.\build-local.ps1` or `./build-local.sh`

2. **Docker Images List**
   - Take screenshot of `docker images` output
   - Should show all 4 images

3. **Docker Run Command**
   - Take screenshot of running containers
   - Command: `docker ps`

4. **Container Logs**
   - Take screenshot of container logs for at least one service
   - Command: `docker logs <container-name>`

5. **Docker Stop Command**
   - Take screenshot of stopping containers
   - Command: `docker stop <container-names>`

## Subtask 2: ECR Repository Setup

### Status: ✅ COMPLETED (via Terraform)

ECR repositories have been created by Terraform:
- healthapp-frontend
- healthapp-master-service
- healthapp-register-service
- healthapp-document-service

### ECR Registry URL Format

The ECR registry URL follows this format:
```
<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com
```

For example:
```
123456789012.dkr.ecr.us-west-2.amazonaws.com
```

### Steps to Get ECR Registry URL

#### Step 1: Get AWS Account ID

```bash
aws sts get-caller-identity --query Account --output text
```

#### Step 2: Construct Registry URL

Using your account ID and region:
```
<ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

### Screenshots Required for Subtask 2

1. **ECR Repositories List**
   - Navigate to AWS Console → ECR → Repositories
   - Take screenshot showing all 4 repositories:
     - healthapp-frontend
     - healthapp-master-service
     - healthapp-register-service
     - healthapp-document-service

2. **ECR Repository Details**
   - Click on each repository
   - Take screenshot showing:
     - Repository URI
     - Image tag mutability
     - Image scanning status

## Subtask 3: Build and Push Images to ECR

### Status: ✅ READY (scripts created)

Scripts have been created to automate the build and push process.

### Image Naming Convention

All images follow this pattern:
```
<ACCOUNT_ID>.dkr.ecr.<REGION>.amazonaws.com/<REPOSITORY_NAME>:latest
```

Examples:
- `123456789012.dkr.ecr.us-west-2.amazonaws.com/healthapp-frontend:latest`
- `123456789012.dkr.ecr.us-west-2.amazonaws.com/healthapp-master-service:latest`
- `123456789012.dkr.ecr.us-west-2.amazonaws.com/healthapp-register-service:latest`
- `123456789012.dkr.ecr.us-west-2.amazonaws.com/healthapp-document-service:latest`

### Steps to Build and Push Images to ECR

#### Step 1: Login to ECR

**On Windows (PowerShell)**:
```powershell
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

**On Linux/Mac/Git Bash**:
```bash
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
```

Replace `<ACCOUNT_ID>` with your actual AWS account ID.

#### Step 2: Build and Push All Images

**On Windows (PowerShell)**:
```powershell
.\build-and-push-ecr.ps1
```

Or with custom parameters:
```powershell
.\build-and-push-ecr.ps1 -Region "us-west-2" -AccountId "YOUR_ACCOUNT_ID"
```

**On Linux/Mac/Git Bash**:
```bash
chmod +x build-and-push-ecr.sh
./build-and-push-ecr.sh
```

Or with custom parameters:
```bash
./build-and-push-ecr.sh us-west-2 YOUR_ACCOUNT_ID
```

This script will:
1. Login to ECR
2. Build all 4 Docker images
3. Tag images with ECR registry URL
4. Push images to ECR
5. Display summary of pushed images

#### Step 3: Verify Images in ECR

Navigate to AWS Console → ECR → Repositories

Click on each repository and verify:
- Image tag: `latest`
- Image size
- Push timestamp

#### Step 4: Clean Up Local Images (Optional)

After successful push, you can remove local images to save space:

```bash
docker rmi healthapp-frontend:latest
docker rmi healthapp-master-service:latest
docker rmi healthapp-register-service:latest
docker rmi healthapp-document-service:latest
```

Or remove all ECR-tagged images:
```bash
docker images | grep "<ACCOUNT_ID>.dkr.ecr" | awk '{print $3}' | xargs docker rmi -f
```

### Screenshots Required for Subtask 3

1. **ECR Login Command**
   - Take screenshot of successful ECR login
   - Command: `aws ecr get-login-password ... | docker login ...`

2. **Build and Push Script Output**
   - Take screenshot of the script output
   - Should show successful build and push for all 4 images

3. **ECR Repositories with Images**
   - Navigate to AWS Console → ECR → Repositories
   - Take screenshot showing each repository with the `latest` image tag
   - Show image details (size, push date)

4. **Image Details**
   - Click on a repository
   - Take screenshot showing image details:
     - Image tag
     - Image digest
     - Image size
     - Pushed at timestamp

## Troubleshooting

### Docker Build Fails

**Issue**: Frontend build fails with Node.js errors
**Solution**: Ensure Node.js 18 is being used (updated in Dockerfile)

**Issue**: Backend build fails with Maven errors
**Solution**: Check pom.xml and ensure dependencies are available

**Issue**: Out of memory during build
**Solution**: Increase Docker memory allocation in Docker Desktop settings

### ECR Login Fails

**Issue**: "Cannot connect to the Docker daemon"
**Solution**: Ensure Docker is running

**Issue**: "Invalid username or password"
**Solution**: Ensure AWS credentials are configured correctly

**Issue**: "no basic creds"
**Solution**: Re-run the login command with correct account ID and region

### ECR Push Fails

**Issue**: "no such image"
**Solution**: Ensure image was built successfully before pushing

**Issue**: "permission denied"
**Solution**: Ensure your AWS user has ECR permissions

**Issue**: "repository does not exist"
**Solution**: Ensure ECR repositories were created via Terraform

### Port Conflicts

**Issue**: "port is already allocated"
**Solution**: Stop containers using the port or use different ports:
```bash
docker ps
docker stop <container-id>
```

## Verification Checklist

After completing all subtasks, verify:

- [ ] All 4 Dockerfiles exist and are correct
- [ ] Frontend Dockerfile uses Node.js 18
- [ ] All images build successfully locally
- [ ] All images can be run as containers
- [ ] Container logs show services starting correctly
- [ ] ECR repositories exist in AWS Console
- [ ] ECR login is successful
- [ ] All images push to ECR successfully
- [ ] Images are visible in ECR Console with `latest` tag
- [ ] Screenshots taken for all required steps

## Next Steps

After completing Docker setup:

1. **Update Kubernetes manifests** with ECR image URLs
2. **Deploy to EKS** using the updated manifests
3. **Configure Ingress** for external access
4. **Set up monitoring** and logging

## Files Created/Modified

### Dockerfiles (Modified)
- `bbhealthapp-frontend/Dockerfile` - Updated to Node.js 18
- `bbhealthapp-backend/bbhealthapp-api-master/Dockerfile` - Verified
- `bbhealthapp-backend/bbhealthapp-api-register/Dockerfile` - Verified
- `bbhealthapp-backend/bbhealthapp-api-document/Dockerfile` - Verified

### Build Scripts (Created)
- `build-local.ps1` - PowerShell script for local builds
- `build-local.sh` - Bash script for local builds
- `build-and-push-ecr.ps1` - PowerShell script for ECR builds
- `build-and-push-ecr.sh` - Bash script for ECR builds

### Documentation (Created)
- `DOCKER_TASK_COMPLETION.md` - This guide

## Summary

✅ **Subtask 1: Dockerfile Creation** - COMPLETED
- All Dockerfiles created and reviewed
- Frontend updated to Node.js 18
- Build scripts created for local testing

✅ **Subtask 2: ECR Repository Setup** - COMPLETED
- ECR repositories created via Terraform
- Registry URL format documented

✅ **Subtask 3: Build and Push Images to ECR** - READY
- Build and push scripts created
- Image naming convention documented
- Verification steps documented

**The Docker setup is ready. Follow the steps above to build, test, and push images to ECR.**
