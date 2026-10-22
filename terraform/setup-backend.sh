#!/bin/bash

# Script to create S3 bucket and DynamoDB table for Terraform backend
# Usage: ./setup-backend.sh <unique-bucket-name>

set -e

BUCKET_NAME=$1
REGION="us-west-2"
TABLE_NAME="healthapp-terraform-locks"

if [ -z "$BUCKET_NAME" ]; then
  echo "Usage: $0 <unique-bucket-name>"
  echo "Example: $0 healthapp-terraform-state-myproject-12345"
  exit 1
fi

echo "Creating S3 bucket: $BUCKET_NAME"
aws s3api create-bucket \
  --bucket $BUCKET_NAME \
  --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

echo "Enabling versioning on bucket"
aws s3api put-bucket-versioning \
  --bucket $BUCKET_NAME \
  --versioning-configuration Status=Enabled

echo "Enabling encryption on bucket"
aws s3api put-bucket-encryption \
  --bucket $BUCKET_NAME \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "Creating DynamoDB table: $TABLE_NAME"
aws dynamodb create-table \
  --table-name $TABLE_NAME \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region $REGION

echo "Waiting for DynamoDB table to be created..."
aws dynamodb wait table-exists --table-name $TABLE_NAME --region $REGION

echo ""
echo "Setup complete!"
echo ""
echo "Please update provider.tf with your bucket name:"
echo "  bucket         = \"$BUCKET_NAME\""
echo ""
echo "Then run: terraform init"
