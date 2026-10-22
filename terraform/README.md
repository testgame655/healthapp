# Terraform AWS Infrastructure - Healthapp

This directory contains Terraform configuration for provisioning AWS infrastructure to deploy the Healthapp application on EKS.

## Prerequisites

1. **AWS CLI installed and configured**
   ```bash
   aws configure
   ```
   Provide your AWS credentials and set the default region to `us-west-2`.

2. **Terraform installed**
   - Version: 1.0 or higher

3. **Unique S3 bucket name**
   - You need to choose a unique name for the Terraform state bucket
   - Update the `bucket` parameter in `provider.tf`

## Infrastructure Components

### 1. VPC and Networking
- **VPC**: 10.0.0.0/16
- **Public Subnets**: 3 subnets (10.0.1.0/24, 10.0.2.0/24, 10.0.3.0/24)
- **Private Subnets**: 3 subnets (10.0.10.0/24, 10.0.11.0/24, 10.0.12.0/24)
- **Internet Gateway**: For public subnet internet access
- **NAT Gateways**: For private subnet internet access
- **VPC Endpoints**: ECR and S3 endpoints for private cluster access

### 2. EKS Cluster
- **Kubernetes Version**: 1.35
- **Cluster Name**: healthapp-eks-cluster
- **OIDC Enabled**: For IAM roles for service accounts
- **Cluster Autoscaler**: Enabled
- **Node Groups**:
  - Public Node Group: 2 nodes (t3.medium)
  - Private Node Group: 2 nodes (t3.medium)

### 3. ECR Repositories
- healthapp-frontend
- healthapp-master-service
- healthapp-register-service
- healthapp-document-service

### 4. IAM Roles
- EKS Cluster Role
- EKS Node Role
- ECR Access Role (for pods)
- CloudWatch Logs Role (for application logs)

## Deployment Steps

### Step 1: Update S3 Backend Configuration

Edit `provider.tf` and update the S3 bucket name to a unique name:

```hcl
backend "s3" {
  bucket         = "healthapp-terraform-state-YOUR-UNIQUE-NAME"
  key            = "terraform.tfstate"
  region         = "us-west-2"
  encrypt        = true
  dynamodb_table = "healthapp-terraform-locks"
}
```

### Step 2: Create S3 Bucket and DynamoDB Table

Before initializing Terraform, create the S3 bucket and DynamoDB table for state locking:

```bash
# Create S3 bucket
aws s3api create-bucket \
  --bucket healthapp-terraform-state-YOUR-UNIQUE-NAME \
  --region us-west-2 \
  --create-bucket-configuration LocationConstraint=us-west-2

# Enable versioning
aws s3api put-bucket-versioning \
  --bucket healthapp-terraform-state-YOUR-UNIQUE-NAME \
  --versioning-configuration Status=Enabled

# Enable encryption
aws s3api put-bucket-encryption \
  --bucket healthapp-terraform-state-YOUR-UNIQUE-NAME \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name healthapp-terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region us-west-2
```

### Step 3: Initialize Terraform

```bash
terraform init
```

### Step 4: Review and Customize Variables

Review `terraform.tfvars` and customize as needed:

```hcl
aws_region  = "us-west-2"
environment = "dev"
project_name = "healthapp"

# VPC Configuration
vpc_cidr               = "10.0.0.0/16"
public_subnet_cidrs    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
private_subnet_cidrs   = ["10.0.10.0/24", "10.0.11.0/24", "10.0.12.0/24"]
availability_zones     = ["us-west-2a", "us-west-2b", "us-west-2c"]

# EKS Cluster Configuration
cluster_name            = "healthapp-eks-cluster"
cluster_version         = "1.35"
node_instance_type      = "t3.medium"
node_group_desired_size = 2
node_group_max_size     = 4
node_group_min_size     = 1
enable_cluster_autoscaler = true
```

### Step 5: Plan the Infrastructure

```bash
terraform plan
```

Review the plan to ensure all resources will be created as expected.

### Step 6: Apply the Infrastructure

```bash
terraform apply
```

Type `yes` when prompted to confirm.

### Step 7: Configure kubectl

After the EKS cluster is created, configure kubectl:

```bash
aws eks update-kubeconfig --name healthapp-eks-cluster --region us-west-2
```

Verify the connection:

```bash
kubectl get nodes
```

### Step 8: Get Outputs

View the Terraform outputs:

```bash
terraform output
```

This will display:
- VPC ID
- Subnet IDs
- EKS cluster endpoint
- ECR repository URLs
- IAM role ARNs

## Screenshots Required

### Subtask 2: VPC and Networking
1. Navigate to AWS Console → VPC
2. Take screenshot of the VPC showing:
   - VPC ID
   - Public subnets
   - Private subnets
   - Internet Gateway
   - NAT Gateways
3. Verify subnet tags for EKS compliance:
   - Public subnets: `kubernetes.io/role/elb = 1`
   - Private subnets: `kubernetes.io/role/internal-elb = 1`

### Subtask 3: EKS Cluster
1. Navigate to AWS Console → EKS
2. Take screenshot of the EKS cluster showing:
   - Cluster name
   - Kubernetes version
   - Status
   - Node groups
3. Take screenshot of node groups showing:
   - Public node group details
   - Private node group details
   - Instance types
   - Node counts

### Subtask 4: IAM Roles and ECR
1. Navigate to AWS Console → IAM
2. Take screenshot of IAM roles:
   - healthapp-eks-cluster-role
   - healthapp-eks-node-role
   - healthapp-eks-ecr-role
   - healthapp-eks-cloudwatch-role
3. Navigate to AWS Console → ECR
4. Take screenshot of ECR repositories:
   - healthapp-frontend
   - healthapp-master-service
   - healthapp-register-service
   - healthapp-document-service

## Clean Up

To destroy all resources:

```bash
terraform destroy
```

## Important Notes

1. **SSH Key Pair (optional)**: SSH access is disabled by default (`ssh_key_name = null`). To enable it, create a key pair, then set `ssh_key_name = "healthapp-key"` in `terraform.tfvars`:
   ```bash
   aws ec2 create-key-pair --key-name healthapp-key --query 'KeyMaterial' --output text > healthapp-key.pem
   chmod 400 healthapp-key.pem
   ```

2. **State Locking**: The DynamoDB table ensures state locking for team collaboration.

3. **ECR Lifecycle Policy**: The ECR repositories are configured to keep only the last 10 images to save storage costs.

4. **OIDC Provider**: OIDC is enabled for IAM roles for service accounts, allowing pods to assume IAM roles.

5. **Cluster Autoscaler**: The cluster autoscaler is enabled to automatically scale node groups based on workload.

## Cost Considerations

- **EKS Cluster**: ~$73/month (control plane)
- **EC2 Instances (t3.medium)**: ~$21/month per instance (4 instances = ~$84/month)
- **NAT Gateways**: ~$32/month per gateway (3 gateways = ~$96/month)
- **ECR Storage**: ~$0.10/GB/month
- **Data Transfer**: Varies based on usage

**Estimated Total**: ~$250-300/month for the base infrastructure

## Troubleshooting

### Terraform Init Fails
- Ensure the S3 bucket and DynamoDB table exist
- Verify AWS credentials are configured correctly
- Check that the bucket name is globally unique

### EKS Cluster Creation Fails
- Verify IAM roles have the correct policies attached
- Check that subnets are properly tagged for EKS
- Ensure VPC endpoints are accessible

### Node Group Creation Fails
- Verify the node IAM role has the correct policies
- Check that the SSH key pair exists in the region
- Ensure the instance type is available in the region

## Next Steps

After infrastructure is provisioned:

1. Build and push Docker images to ECR
2. Update Kubernetes manifests with ECR image URLs
3. Deploy the application to EKS
4. Configure Ingress for external access
5. Set up monitoring and logging
