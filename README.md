# 🏥 Healthapp - Healthcare Management System

![Docker](https://img.shields.io/badge/Docker-blue?logo=docker)
![Kubernetes](https://img.shields.io/badge/Kubernetes-purple?logo=kubernetes)
![Terraform](https://img.shields.io/badge/Terraform-red?logo=terraform)
![AWS](https://img.shields.io/badge/AWS-orange?logo=amazonaws)

## 📋 Overview

Healthapp is a healthcare management application with React frontend and Spring Boot microservices, deployed on AWS EKS using Docker, Kubernetes, Terraform, and Jenkins CI/CD.

## 🏗️ Architecture

**Frontend:** React.js (Node.js 18, Nginx)  
**Backend:** 3 Spring Boot microservices (Auth, Register, Document)  
**Infrastructure:** AWS EKS, Terraform IaC  
**CI/CD:** Jenkins pipeline  
**Registry:** Docker Hub

## 🚀 Microservices

- **Master Service** (Port 8081) - Authentication & JWT
- **Register Service** (Port 8082) - User registration
- **Document Service** (Port 8083) - File management
- **Frontend** (Port 80) - React UI

## 🛠️ Tech Stack

- **Frontend:** React, Node.js 18, Nginx
- **Backend:** Spring Boot, Java 8/11, H2 DB
- **DevOps:** Docker, Kubernetes 1.35, Terraform, Jenkins
- **Cloud:** AWS EKS, ALB, VPC, CloudWatch

## 📦 Project Structure

```
Healthapp/
├── bbhealthapp-frontend/     # React App
├── bbhealthapp-backend/     # Spring Boot Services
├── k8s/                      # K8s Manifests
├── k8s-jenkins/              # Jenkins Pipeline
└── terraform/                # Terraform IaC
```

## 🚀 Quick Start

```bash
# Clone
git clone https://github.com/testgame655/healthapp.git

# Build Docker images
./build-local.sh

# Deploy Infrastructure
cd terraform
terraform init && terraform apply

# Deploy to K8s
cd k8s
kubectl apply -f .
```

## 📖 Documentation

- [Docker Guide](DOCKER_TASK_COMPLETION.md)
- [K8s Guide](K8S_TASK_COMPLETION.md)
- [Docker Report](TASK_3_DOCKER_SETUP_REPORT.md)

## 🔒 Security

- IAM roles with least privilege
- Kubernetes Secrets for sensitive data
- VPC isolation and security groups
- RBAC for access control

## 💰 Cost

**24 hours:** ~$3-5 (testing)  
- EKS: $0.10/hour
- EC2: $0.096/hour per instance
- ALB: $0.0225/hour

## 🎯 Features

- ✅ Microservices architecture
- ✅ Docker containerization
- ✅ Kubernetes orchestration
- ✅ Terraform IaC
- ✅ Jenkins CI/CD
- ✅ AWS EKS deployment
- ✅ High availability (multi-AZ)
- ✅ Load balancing (ALB)

## 📝 License

MIT License

---

**⭐ Star if helpful!**
