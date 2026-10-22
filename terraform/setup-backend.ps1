# PowerShell script to create S3 bucket and DynamoDB table for Terraform backend
# Usage: .\setup-backend.ps1 -BucketName "healthapp-terraform-state-unique-name"

param(
    [Parameter(Mandatory=$true)]
    [string]$BucketName
)

$Region = "us-west-2"
$TableName = "healthapp-terraform-locks"

Write-Host "Creating S3 bucket: $BucketName" -ForegroundColor Green
aws s3api create-bucket `
    --bucket $BucketName `
    --region $Region `
    --create-bucket-configuration LocationConstraint=$Region

Write-Host "Enabling versioning on bucket" -ForegroundColor Green
aws s3api put-bucket-versioning `
    --bucket $BucketName `
    --versioning-configuration Status=Enabled

Write-Host "Enabling encryption on bucket" -ForegroundColor Green
$encryptionFile = Join-Path $env:TEMP "s3-encryption.json"
@'
{
  "Rules": [
    {
      "ApplyServerSideEncryptionByDefault": {
        "SSEAlgorithm": "AES256"
      }
    }
  ]
}
'@ | Set-Content -Path $encryptionFile -Encoding ascii
$encryptionUri = "file://" + ($encryptionFile -replace '\\', '/')
aws s3api put-bucket-encryption `
    --bucket $BucketName `
    --server-side-encryption-configuration $encryptionUri
Remove-Item $encryptionFile -ErrorAction SilentlyContinue

Write-Host "Creating DynamoDB table: $TableName" -ForegroundColor Green
aws dynamodb create-table `
    --table-name $TableName `
    --attribute-definitions AttributeName=LockID,AttributeType=S `
    --key-schema AttributeName=LockID,KeyType=HASH `
    --billing-mode PAY_PER_REQUEST `
    --region $Region

Write-Host "Waiting for DynamoDB table to be created..." -ForegroundColor Yellow
aws dynamodb wait table-exists --table-name $TableName --region $Region

Write-Host ""
Write-Host "Setup complete!" -ForegroundColor Green
Write-Host ""
Write-Host "Please update provider.tf with your bucket name:" -ForegroundColor Yellow
Write-Host "  bucket         = `"$BucketName`"" -ForegroundColor Cyan
Write-Host ""
Write-Host "Then run: terraform init" -ForegroundColor Yellow
