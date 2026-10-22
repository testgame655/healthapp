Task 3: Docker Setup Report
Student Name: [Name] | Date: [Date] | OS: [Windows/Mac/Linux with version]
This report documents Task 3: containerizing the Healthapp application with Docker and pushing images to AWS ECR for Kubernetes deployment. The sections below show what was configured, how to deploy it and how to verify it. The screenshots are dummy images and must be replaced with real screenshots from your own environment.

Architecture overview

Each service has its own Dockerfile with a multi-stage build; build scripts automate local and ECR workflows, and Terraform provisions the ECR repositories in us-west-2.

Component
What it does
Frontend Dockerfile
Multi-stage build with node:18-alpine and nginx:alpine, serves React on port 80
Master Service Dockerfile
Multi-stage Maven build with openjdk:8, runs Spring Boot on port 8081
Register Service Dockerfile
Multi-stage Maven build with openjdk:8, runs Spring Boot on port 8082
Document Service Dockerfile
Multi-stage Maven build with openjdk:11, runs Spring Boot on port 8083
build-local.ps1 / .sh
Builds all four images locally for testing
build-and-push-ecr.ps1 / .sh
Logs in to ECR, builds all images, tags them and pushes to ECR
ECR repositories (Terraform)
Four repositories in us-west-2 with lifecycle policy and image scanning

Deployment workflow

Local builds let you test images before they reach ECR; the push script logs in, tags with the full registry URL and uploads, after which the ECR console confirms the result.

Subtask 1: Dockerfile creation

Four Dockerfiles use multi-stage builds to keep runtime images small, and the frontend was updated from Node.js 14 to Node.js 18 for React-Draggable compatibility.

Guideline
What was done
Create Dockerfiles for each service
Frontend: node:18-alpine build, nginx:alpine runtime, port 80
Master: maven:3.6.3-openjdk-8 build, openjdk:8-jre-alpine runtime, port 8081
Register: maven:3.6.3-openjdk-8 build, openjdk:8-jre-alpine runtime, port 8082
Document: maven:3.6.3-openjdk-11 build, openjdk:11-jre-slim runtime, port 8083
Test Docker images locally
Ran build-local.ps1, all four images built successfully
Verify services in containers
Tested each image with docker run, containers started and logs showed no errors
Check logs for failures
Checked docker logs for each container, all services started correctly
Stop containers after testing
Ran docker stop and docker rm to clean up test containers
Commands used:

docker images output showing all four images

docker run command for one service

docker logs showing successful startup

docker stop command

Subtask 2: ECR repository setup

Four ECR repositories exist in us-west-2 from the Terraform deployment in Task 2, each with image scanning enabled and a lifecycle policy that keeps only the last 10 images.

Guideline
What was done
ECR repositories match service names
healthapp-frontend, healthapp-master-service, healthapp-register-service, healthapp-document-service repositories exist in ECR
Note the ECR registry URL
Registry URL is <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com
Take screenshots of ECR repositories
Captured ECR repositories list in AWS Console

ECR repositories list in AWS Console

Repository details showing URI, mutability and scanning

Subtask 3: Build and push images to ECR

The push script logs in to ECR, builds each image, tags it with the full registry URL and pushes it. Images are tagged as latest, and the lifecycle policy automatically removes old images beyond the last ten.

Guideline
What was done
Use consistent image name pattern
All images follow <ACCOUNT_ID>.dkr.ecr.us-west-2.amazonaws.com/<service-name>:latest
Tag images as latest
Each image is tagged with :latest during the push process
Verify successful pushes
Checked ECR console after push, all four repositories show the latest image
Take screenshots of ECR repositories with images
Captured each repository showing the pushed image
Clean up local images (optional)
Ran docker rmi to remove local images and save disk space
Commands used:

aws ecr get-login-password for ECR login

build-and-push-ecr.ps1 script output

ECR repository with pushed image showing tag, size and push time

Errors encountered and resolutions

Error
Cause
Resolution
Node.js version incompatibility
Frontend Dockerfile used node:14-alpine but React-Draggable 4.7.2 requires Node.js 18
Updated Dockerfile to use node:18-alpine
IAM role security issue
IAM roles allowed any service account to assume them
Added namespace restriction to restrict to bbhealthapp namespace only

Screenshots checklist

These are the six screenshots Task 3 asks for. Tick each one once it is captured and added to this report.
? Docker build command output showing successful builds for all four services
? Docker images list showing healthapp-frontend, healthapp-master-service, healthapp-register-service, healthapp-document-service
? Docker run command and container logs showing services starting correctly
? Docker stop command showing containers stopped
? ECR login command output showing successful authentication
? ECR repositories in AWS Console showing all four repositories with pushed images

Cost and next improvements

ECR storage costs approximately $0.02 per month for the four repositories (200MB total), which is negligible. Data transfer costs are minimal for deployment usage.

Item
Approximate monthly cost
ECR storage (4 repositories × 50MB)
$0.02
Data transfer (deployment only)
< $0.01
Next improvements:
? Use semantic versioning for image tags (v1.0.0, v1.0.1) instead of only latest
? Add Git commit SHA as image tag for traceability
? Integrate vulnerability scanning in CI/CD pipeline (Trivy)
? Use distroless images for backend services to further reduce attack surface
? Implement BuildKit for parallel builds and better caching
? Add health check and readiness probe testing in Docker build phase
? Use .dockerignore files more aggressively to exclude unnecessary files
? Consider using buildx for multi-architecture builds (amd64, arm64)
