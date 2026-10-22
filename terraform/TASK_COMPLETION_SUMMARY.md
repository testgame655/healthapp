# Task 2: Terraform AWS Infrastructure - Completion Summary

## Overview

All Terraform configuration files have been successfully created for the Healthapp project. The infrastructure will provision AWS resources for deploying the application on EKS.

## Files Created

### Core Terraform Files
1. **provider.tf** - AWS provider and S3 backend configuration
2. **variables.tf** - All configurable variables for the infrastructure
3. **terraform.tfvars** - Default values for all variables
4. **vpc.tf** - VPC, subnets, Internet Gateway, NAT Gateways, and VPC endpoints
5. **eks.tf** - EKS cluster, node groups, IAM roles, and security groups
6. **ecr.tf** - ECR repositories and IAM roles for ECR access
7. **outputs.tf** - Output values for important resources

### Helper Files
8. **README.md** - Comprehensive deployment guide
9. **setup-backend.sh** - Bash script to create S3 bucket and DynamoDB table
10. **setup-backend.ps1** - PowerShell script to create S3 bucket and DynamoDB table
11. **terraform.tfvars.example** - Example terraform.tfvars file
12. **.gitignore** - Git ignore rules for Terraform

## Infrastructure Components

### ✓ Subtask 1: AWS CLI and Terraform Initialization
- **Region**: us-west-2 (configured in terraform.tfvars)
- **S3 Backend**: Configured in provider.tf (needs unique bucket name)
- **Variables**: All variables defined in variables.tf
- **terraform.tfvars**: Created with default values

### ✓ Subtask 2: VPC and Networking Setup
- **VPC**: 10.0.0.0/16 CIDR block
- **Public Subnets**: 3 subnets in us-west-2a, us-west-2b, us-west-2c
  - 10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24
  - Tagged with `kubernetes.io/role/elb = 1`
  - Internet access via Internet Gateway
- **Private Subnets**: 3 subnets in us-west-2a, us-west-2b, us-west-2c
  - 10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24
  - Tagged with `kubernetes.io/role/internal-elb = 1`
  - Internet access via NAT Gateways
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: 3 NAT gateways (one per AZ) for private subnets
- **VPC Endpoints**: ECR API, ECR DKR, and S3 endpoints for private cluster access

### ✓ Subtask 3: EKS Cluster Setup
- **Cluster Name**: healthapp-eks-cluster
- **Kubernetes Version**: 1.35
- **Instance Type**: t3.medium for all nodes
- **Node Groups**:
  - **Public Node Group**: 2 nodes (min: 1, max: 4)
  - **Private Node Group**: 2 nodes (min: 1, max: 4)
- **OIDC**: Enabled for IAM roles for service accounts
- **Cluster Autoscaler**: Enabled with proper IAM policy
- **Security Groups**: Configured for cluster and nodes with proper ingress/egress rules

### ✓ Subtask 4: IAM Roles and ECR Setup
- **IAM Roles Created**:
  - healthapp-eks-cluster-role (with AmazonEKSClusterPolicy and AmazonEKSVPCResourceController)
  - healthapp-eks-node-role (with AmazonEKSWorkerNodePolicy, AmazonEKS_CNI_Policy, AmazonEC2ContainerRegistryReadOnly)
  - healthapp-eks-ecr-role (for pods to access ECR)
  - healthapp-eks-cloudwatch-role (for pods to write to CloudWatch Logs)
- **ECR Repositories**:
  - healthapp-frontend
  - healthapp-master-service
  - healthapp-register-service
  - healthapp-document-service
- **ECR Lifecycle Policy**: Keep last 10 images
- **Least Privilege**: All IAM policies follow least privilege principle

## Next Steps (Manual Actions Required)

### Step 1: Configure AWS CLI
If not already configured:
```bash
aws configure
```
Enter your AWS credentials and set default region to `us-west-2`.

### Step 2: Create Unique S3 Bucket Name
The S3 bucket name must be globally unique. Choose a unique name and update `provider.tf`:

```hcl
backend "s3" {
  bucket         = "healthapp-terraform-state-YOUR-UNIQUE-NAME"
  key            = "terraform.tfstate"
  region         = "us-west-2"
  encrypt        = true
  dynamodb_table = "healthapp-terraform-locks"
}
```

### Step 3: Create S3 Bucket and DynamoDB Table
Run the PowerShell script (for Windows):
```powershell
.\setup-backend.ps1 -BucketName "healthapp-terraform-state-YOUR-UNIQUE-NAME"
```

Or run the bash script (for Linux/Mac/Git Bash):
```bash
./setup-backend.sh healthapp-terraform-state-YOUR-UNIQUE-NAME
```

### Step 4: Create SSH Key Pair (optional)
SSH is disabled by default. To enable it, create a key pair and set `ssh_key_name = "healthapp-key"` in `terraform.tfvars`:
```bash
aws ec2 create-key-pair --key-name healthapp-key --query 'KeyMaterial' --output text > healthapp-key.pem
```

On Windows PowerShell:
```powershell
aws ec2 create-key-pair --key-name healthapp-key --query 'KeyMaterial' --output text > healthapp-key.pem
```

Set appropriate permissions:
```bash
chmod 400 healthapp-key.pem
```

### Step 5: Initialize Terraform
```bash
terraform init
```

### Step 6: Review the Plan
```bash
terraform plan
```

### Step 7: Apply the Infrastructure
```bash
terraform apply
```
Type `yes` when prompted.

### Step 8: Configure kubectl
After successful deployment:
```bash
aws eks update-kubeconfig --name healthapp-eks-cluster --region us-west-2
```

Verify:
```bash
kubectl get nodes
```

### Step 9: Take Screenshots

#### Subtask 2: VPC and Networking
1. Navigate to AWS Console → VPC → Your VPCs
2. Select the healthapp-vpc
3. Take screenshot showing:
   - VPC ID
   - CIDR block
   - Associated subnets
4. Navigate to Subnets
5. Take screenshot showing:
   - Public subnets with tags
   - Private subnets with tags
   - Verify EKS tags: `kubernetes.io/role/elb` and `kubernetes.io/role/internal-elb`
6. Navigate to Internet Gateways
7. Take screenshot showing the IGW
8. Navigate to NAT Gateways
9. Take screenshot showing NAT gateways

#### Subtask 3: EKS Cluster
1. Navigate to AWS Console → EKS → Clusters
2. Select healthapp-eks-cluster
3. Take screenshot showing:
   - Cluster name
   - Kubernetes version
   - Status
   - Endpoint URL
   - OIDC provider status
4. Navigate to Compute → Node Groups
5. Take screenshot showing:
   - Public node group (healthapp-public-node-group)
   - Private node group (healthapp-private-node-group)
   - Instance types
   - Current/desired/max/min node counts
6. Click on each node group and take screenshots of details

#### Subtask 4: IAM Roles and ECR
1. Navigate to AWS Console → IAM → Roles
2. Take screenshots of each role:
   - healthapp-eks-cluster-role
   - healthapp-eks-node-role
   - healthapp-eks-ecr-role
   - healthapp-eks-cloudwatch-role
3. For each role, show attached policies
4. Navigate to AWS Console → ECR → Repositories
5. Take screenshot showing all 4 repositories:
   - healthapp-frontend
   - healthapp-master-service
   - healthapp-register-service
   - healthapp-document-service
6. Click on each repository and show details

## Important Notes

1. **Unique Bucket Name**: The S3 bucket name must be globally unique across all AWS accounts. Include your name or a random string to ensure uniqueness.

2. **SSH Key Pair (optional)**: Only needed if you set `ssh_key_name`; the key pair must exist before `terraform apply`.

3. **Cost**: This infrastructure will incur monthly costs of approximately $250-300. Remember to destroy resources when not in use:
   ```bash
   terraform destroy
   ```

4. **Region**: All resources are configured for `us-west-2`. Do not change this without updating availability zones.

5. **Terraform Version**: Requires Terraform 1.0 or higher.

6. **AWS Permissions**: Your AWS user must have sufficient permissions to create:
   - VPC, subnets, IGW, NAT gateways
   - EKS clusters and node groups
   - IAM roles and policies
   - ECR repositories
   - S3 buckets and DynamoDB tables

## Verification Checklist

After deployment, verify:

- [ ] VPC created with correct CIDR (10.0.0.0/16)
- [ ] 6 subnets created (3 public, 3 private)
- [ ] Subnets tagged correctly for EKS
- [ ] Internet Gateway created and attached
- [ ] NAT Gateways created (one per AZ)
- [ ] EKS cluster created and active
- [ ] EKS version is 1.35
- [ ] OIDC provider enabled
- [ ] 2 node groups created (public and private)
- [ ] Nodes are in "Ready" state
- [ ] Cluster autoscaler enabled
- [ ] 4 ECR repositories created
- [ ] IAM roles created with correct policies
- [ ] kubectl can connect to cluster

## Troubleshooting

If `terraform init` fails:
- Verify S3 bucket exists
- Verify DynamoDB table exists
- Check AWS credentials are configured

If `terraform apply` fails:
- Check AWS permissions
- Verify SSH key pair exists
- Check that instance type is available in region
- Review error messages for specific issues

## Documentation

For detailed information, refer to:
- **README.md** - Complete deployment guide
- **terraform.tfvars** - Current configuration values
- **variables.tf** - All available variables

## Summary

All Terraform configuration files have been created according to the task requirements:

✅ **Subtask 1**: AWS CLI and Terraform Initialization - Configuration files created
✅ **Subtask 2**: VPC and Networking Setup - Terraform configuration created with proper tagging
✅ **Subtask 3**: EKS Cluster Setup - Terraform configuration with OIDC, autoscaler, and 2 node groups
✅ **Subtask 4**: IAM Roles and ECR Setup - Terraform configuration with least privilege IAM policies

**The infrastructure is ready to be deployed. Follow the "Next Steps" section above to complete the deployment.**
