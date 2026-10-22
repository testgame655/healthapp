# PowerShell script to build and push Docker images to AWS ECR
# Usage: .\build-and-push-ecr.ps1 -Region "us-west-2" -AccountId "YOUR_ACCOUNT_ID"

param(
    [Parameter(Mandatory=$false)]
    [string]$Region = "us-west-2",

    [Parameter(Mandatory=$false)]
    [string]$AccountId = (aws sts get-caller-identity --query Account --output text)
)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Healthapp Docker Build and Push to ECR" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get AWS Account ID
if ([string]::IsNullOrEmpty($AccountId)) {
    Write-Host "Error: Could not determine AWS Account ID. Please provide it with -AccountId parameter." -ForegroundColor Red
    exit 1
}

Write-Host "AWS Account ID: $AccountId" -ForegroundColor Green
Write-Host "Region: $Region" -ForegroundColor Green
Write-Host ""

# ECR Registry URL
$RegistryUrl = "${AccountId}.dkr.ecr.${Region}.amazonaws.com"
Write-Host "ECR Registry URL: $RegistryUrl" -ForegroundColor Green
Write-Host ""

# Service configurations
$Services = @(
    @{
        Name = "healthapp-frontend"
        Path = "bbhealthapp-frontend"
        Dockerfile = "Dockerfile"
        Port = 80
    },
    @{
        Name = "healthapp-master-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-master"
        Dockerfile = "Dockerfile"
        Port = 8081
    },
    @{
        Name = "healthapp-register-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-register"
        Dockerfile = "Dockerfile"
        Port = 8082
    },
    @{
        Name = "healthapp-document-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-document"
        Dockerfile = "Dockerfile"
        Port = 8083
    }
)

# Login to ECR
Write-Host "Logging in to ECR..." -ForegroundColor Yellow
aws ecr get-login-password --region $Region | docker login --username AWS --password-stdin $RegistryUrl
if ($LASTEXITCODE -ne 0) {
    Write-Host "Error: Failed to login to ECR" -ForegroundColor Red
    exit 1
}
Write-Host "Successfully logged in to ECR" -ForegroundColor Green
Write-Host ""

# Build and push each service
foreach ($Service in $Services) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Processing: $($Service.Name)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    $ServicePath = Join-Path $PSScriptRoot $Service.Path
    $ImageName = "${RegistryUrl}/$($Service.Name)"

    # Check if service directory exists
    if (-not (Test-Path $ServicePath)) {
        Write-Host "Warning: Service path not found: $ServicePath" -ForegroundColor Yellow
        Write-Host "Skipping $($Service.Name)" -ForegroundColor Yellow
        Write-Host ""
        continue
    }

    # Build image
    Write-Host "Building Docker image..." -ForegroundColor Yellow
    Set-Location $ServicePath
    docker build -t ${ImageName}:latest -f $Service.Dockerfile .

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to build $($Service.Name)" -ForegroundColor Red
        Set-Location $PSScriptRoot
        continue
    }

    Write-Host "Successfully built $($Service.Name)" -ForegroundColor Green

    # Tag image
    Write-Host "Tagging image..." -ForegroundColor Yellow
    docker tag ${ImageName}:latest ${ImageName}:latest

    # Push image
    Write-Host "Pushing image to ECR..." -ForegroundColor Yellow
    docker push ${ImageName}:latest

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to push $($Service.Name)" -ForegroundColor Red
        Set-Location $PSScriptRoot
        continue
    }

    Write-Host "Successfully pushed $($Service.Name) to ECR" -ForegroundColor Green
    Write-Host "Image URL: ${ImageName}:latest" -ForegroundColor Cyan
    Write-Host ""

    Set-Location $PSScriptRoot
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Build and Push Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Summary:" -ForegroundColor Green
Write-Host "Registry: $RegistryUrl" -ForegroundColor Cyan
Write-Host "Images pushed:" -ForegroundColor Cyan
foreach ($Service in $Services) {
    Write-Host "  - ${RegistryUrl}/$($Service.Name):latest" -ForegroundColor White
}
Write-Host ""
