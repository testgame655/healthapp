# PowerShell script to build Docker images locally for testing
# Usage: .\build-local.ps1

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Healthapp Local Docker Build" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Service configurations
$Services = @(
    @{
        Name = "healthapp-frontend"
        Path = "bbhealthapp-frontend"
        Dockerfile = "Dockerfile"
        ImageName = "healthapp-frontend"
        Port = 80
    },
    @{
        Name = "healthapp-master-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-master"
        Dockerfile = "Dockerfile"
        ImageName = "healthapp-master-service"
        Port = 8081
    },
    @{
        Name = "healthapp-register-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-register"
        Dockerfile = "Dockerfile"
        ImageName = "healthapp-register-service"
        Port = 8082
    },
    @{
        Name = "healthapp-document-service"
        Path = "bbhealthapp-backend/bbhealthapp-api-document"
        Dockerfile = "Dockerfile"
        ImageName = "healthapp-document-service"
        Port = 8083
    }
)

# Build each service
foreach ($Service in $Services) {
    Write-Host "========================================" -ForegroundColor Cyan
    Write-Host "Building: $($Service.Name)" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan

    $ServicePath = Join-Path $PSScriptRoot $Service.Path

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
    docker build -t "$($Service.ImageName):latest" -f $Service.Dockerfile .

    if ($LASTEXITCODE -ne 0) {
        Write-Host "Error: Failed to build $($Service.Name)" -ForegroundColor Red
        Set-Location $PSScriptRoot
        continue
    }

    Write-Host "Successfully built $($Service.Name)" -ForegroundColor Green
    Write-Host "Image: $($Service.ImageName):latest" -ForegroundColor Cyan
    Write-Host ""

    Set-Location $PSScriptRoot
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Local Build Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Built images:" -ForegroundColor Green
foreach ($Service in $Services) {
    Write-Host "  - $($Service.ImageName):latest" -ForegroundColor White
}
Write-Host ""
Write-Host "To test images, you can run:" -ForegroundColor Yellow
Write-Host "  docker run -p 80:80 healthapp-frontend" -ForegroundColor White
Write-Host "  docker run -p 8081:8081 healthapp-master-service" -ForegroundColor White
Write-Host "  docker run -p 8082:8082 healthapp-register-service" -ForegroundColor White
Write-Host "  docker run -p 8083:8083 healthapp-document-service" -ForegroundColor White
Write-Host ""
