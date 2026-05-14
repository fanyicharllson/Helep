# Script to build and optionally push Docker images for all services in the Helep project to Docker Hub.
param(
    [Parameter(Mandatory = $true)]
    [string]$DockerHubUser,

    [string]$Tag = "0.1.0",

    [switch]$Push,

    [string]$RepoPrefix = "helep"
)

$ErrorActionPreference = "Stop"

$services = @(
    @{ Name = "user-service" },
    @{ Name = "sos-service" },
    @{ Name = "dispatch-service" },
    @{ Name = "notification-service" },
    @{ Name = "analytics-service" }
)

$scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$repoRoot = Split-Path -Parent $scriptRoot

Write-Host "Repository root: $repoRoot"
Write-Host "Docker Hub user: $DockerHubUser"
Write-Host "Tag: $Tag"
Write-Host "Push: $Push"

foreach ($service in $services) {
    $serviceName = $service.Name
    $servicePath = Join-Path $repoRoot "services\$serviceName"
    $imageName = "${DockerHubUser}/${RepoPrefix}-$serviceName`:$Tag"

    if (-not (Test-Path $servicePath)) {
        throw "Service directory not found: $servicePath"
    }

    Write-Host "Building $imageName from $servicePath"
    docker build -t $imageName $servicePath

    if ($LASTEXITCODE -ne 0) {
        throw "Docker build failed for $serviceName"
    }

    if ($Push) {
        Write-Host "Pushing $imageName"
        docker push $imageName

        if ($LASTEXITCODE -ne 0) {
            throw "Docker push failed for $serviceName"
        }
    }
}

Write-Host "Done."