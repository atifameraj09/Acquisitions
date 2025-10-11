# Acquisitions Docker Setup Script (PowerShell)
# This script helps you manage your Dockerized Neon Database application on Windows

param(
    [Parameter(Position=0)]
    [string]$Command = "help",
    
    [Parameter(Position=1)]
    [string]$Environment = ""
)

# Project configuration
$ProjectName = "Acquisitions"
$DevComposeFile = "docker-compose.dev.yml"
$ProdComposeFile = "docker-compose.prod.yml"

# Color functions
function Write-Info($message) {
    Write-Host "ℹ️  $message" -ForegroundColor Blue
}

function Write-Success($message) {
    Write-Host "✅ $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "⚠️  $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "❌ $message" -ForegroundColor Red
}

function Write-Header {
    Write-Host ""
    Write-Host "🐳 $ProjectName - Docker Management" -ForegroundColor Blue
    Write-Host "==================================" -ForegroundColor Blue
}

# Function to check if Docker is running
function Test-Docker {
    Write-Info "Checking Docker installation..."
    
    try {
        $dockerVersion = docker --version 2>$null
        if (-not $dockerVersion) {
            Write-Error "Docker is not installed or not in PATH"
            exit 1
        }
        
        $dockerInfo = docker info 2>$null
        if (-not $dockerInfo) {
            Write-Error "Docker daemon is not running. Please start Docker Desktop."
            exit 1
        }
        
        Write-Success "Docker is running"
    }
    catch {
        Write-Error "Failed to check Docker status"
        exit 1
    }
}

# Function to check if Docker Compose is available
function Test-DockerCompose {
    Write-Info "Checking Docker Compose..."
    
    try {
        $composeVersion = docker compose version 2>$null
        if ($composeVersion) {
            $script:DockerComposeCmd = "docker compose"
        }
        else {
            $composeVersion = docker-compose --version 2>$null
            if ($composeVersion) {
                $script:DockerComposeCmd = "docker-compose"
            }
            else {
                Write-Error "Docker Compose is not installed"
                exit 1
            }
        }
        
        Write-Success "Docker Compose is available"
    }
    catch {
        Write-Error "Failed to check Docker Compose"
        exit 1
    }
}

# Function to setup environment files
function Initialize-EnvFiles {
    Write-Info "Setting up environment files..."
    
    if (-not (Test-Path ".env.development")) {
        Write-Warning ".env.development not found. Creating template..."
        if (Test-Path ".env") {
            Copy-Item ".env" ".env.development" -ErrorAction SilentlyContinue
        }
    }
    
    if (-not (Test-Path ".env.production")) {
        Write-Warning ".env.production not found. Using template..."
    }
    
    Write-Success "Environment files are ready"
}

# Function to build Docker images
function Build-Images($env) {
    Write-Info "Building Docker images for $env environment..."
    
    try {
        if ($env -eq "dev") {
            docker build --target development -t acquisitions:dev .
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to build development image"
                exit 1
            }
        }
        elseif ($env -eq "prod") {
            docker build --target production -t acquisitions:prod .
            if ($LASTEXITCODE -ne 0) {
                Write-Error "Failed to build production image"
                exit 1
            }
        }
        
        Write-Success "$env image built successfully"
    }
    catch {
        Write-Error "Failed to build Docker image"
        exit 1
    }
}

# Function to start development environment
function Start-DevEnvironment {
    Write-Info "Starting development environment with Neon Local..."
    Initialize-EnvFiles
    
    try {
        & $DockerComposeCmd -f $DevComposeFile up --build -d
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to start development environment"
            exit 1
        }
        
        Write-Success "Development environment started!"
        Write-Info "Application: http://localhost:3000"
        Write-Info "Health check: http://localhost:3000/health"
        Write-Info "Database Admin: http://localhost:8080 (if enabled)"
        Write-Info "Use 'npm run docker:dev:logs' to view logs"
    }
    catch {
        Write-Error "Failed to start development environment"
        exit 1
    }
}

# Function to start production environment
function Start-ProdEnvironment {
    Write-Info "Starting production environment with Neon Cloud..."
    
    # Check for required environment variables
    if (-not $env:DATABASE_URL) {
        Write-Error "DATABASE_URL environment variable is required for production"
        Write-Info "Set it with: `$env:DATABASE_URL = 'your_neon_connection_string'"
        exit 1
    }
    
    if (-not $env:ARCJET_KEY) {
        Write-Warning "ARCJET_KEY environment variable is not set"
        Write-Info "Set it with: `$env:ARCJET_KEY = 'your_arcjet_key'"
    }
    
    try {
        & $DockerComposeCmd -f $ProdComposeFile up --build -d
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to start production environment"
            exit 1
        }
        
        Write-Success "Production environment started!"
        Write-Info "Application: http://localhost:3000"
        Write-Info "Health check: http://localhost:3000/health"
        Write-Info "Use 'npm run docker:prod:logs' to view logs"
    }
    catch {
        Write-Error "Failed to start production environment"
        exit 1
    }
}

# Function to stop environments
function Stop-Environment($env) {
    Write-Info "Stopping $env environment..."
    
    try {
        if ($env -eq "dev") {
            & $DockerComposeCmd -f $DevComposeFile down
        }
        elseif ($env -eq "prod") {
            & $DockerComposeCmd -f $ProdComposeFile down
        }
        
        Write-Success "$env environment stopped"
    }
    catch {
        Write-Error "Failed to stop $env environment"
        exit 1
    }
}

# Function to clean environments (remove volumes)
function Clear-Environment($env) {
    Write-Warning "Cleaning $env environment (this will remove data volumes)..."
    $confirm = Read-Host "Are you sure? (y/N)"
    
    if ($confirm -match "^[Yy]$") {
        try {
            if ($env -eq "dev") {
                & $DockerComposeCmd -f $DevComposeFile down -v --remove-orphans
            }
            elseif ($env -eq "prod") {
                & $DockerComposeCmd -f $ProdComposeFile down -v --remove-orphans
            }
            
            Write-Success "$env environment cleaned"
        }
        catch {
            Write-Error "Failed to clean $env environment"
            exit 1
        }
    }
    else {
        Write-Info "Operation cancelled"
    }
}

# Function to show logs
function Show-Logs($env) {
    Write-Info "Showing $env environment logs..."
    
    try {
        if ($env -eq "dev") {
            & $DockerComposeCmd -f $DevComposeFile logs -f
        }
        elseif ($env -eq "prod") {
            & $DockerComposeCmd -f $ProdComposeFile logs -f
        }
    }
    catch {
        Write-Error "Failed to show logs"
        exit 1
    }
}

# Function to show status
function Show-Status {
    Write-Info "Showing container status..."
    
    try {
        docker ps --filter "name=acquisitions"
        
        Write-Host "`nNetwork Information:" -ForegroundColor Blue
        docker network ls --filter "name=acquisitions"
        
        Write-Host "`nVolume Information:" -ForegroundColor Blue
        docker volume ls --filter "name=neon"
    }
    catch {
        Write-Error "Failed to show status"
    }
}

# Function to run database migrations
function Invoke-Migrations($env) {
    Write-Info "Running database migrations in $env environment..."
    
    try {
        if ($env -eq "dev") {
            & $DockerComposeCmd -f $DevComposeFile exec app npm run db:migrate
        }
        elseif ($env -eq "prod") {
            & $DockerComposeCmd -f $ProdComposeFile exec app npm run db:migrate
        }
        
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to run migrations"
            exit 1
        }
        
        Write-Success "Database migrations completed"
    }
    catch {
        Write-Error "Failed to run migrations"
        exit 1
    }
}

# Function to start database admin interface
function Start-DbAdmin {
    Write-Info "Starting database admin interface..."
    
    try {
        & $DockerComposeCmd -f $DevComposeFile --profile tools up adminer -d
        Write-Success "Database admin available at: http://localhost:8080"
        Write-Info "Server: neon-local, Username: user, Password: password, Database: neondb"
    }
    catch {
        Write-Error "Failed to start database admin"
        exit 1
    }
}

# Function to show help
function Show-Help {
    Write-Header
    Write-Host "Usage: " -ForegroundColor Green -NoNewline
    Write-Host "./setup-docker.ps1 [COMMAND] [OPTIONS]"
    Write-Host ""
    Write-Host "Commands:" -ForegroundColor Yellow
    Write-Host "  dev                 Start development environment (Neon Local)"
    Write-Host "  prod                Start production environment (Neon Cloud)"
    Write-Host "  stop [dev|prod]     Stop development or production environment"
    Write-Host "  clean [dev|prod]    Clean environment (removes volumes)"
    Write-Host "  logs [dev|prod]     Show logs for environment"
    Write-Host "  status              Show container status"
    Write-Host "  build [dev|prod]    Build Docker images"
    Write-Host "  migrate [dev|prod]  Run database migrations"
    Write-Host "  db-admin            Start database admin interface (dev only)"
    Write-Host "  help                Show this help message"
    Write-Host ""
    Write-Host "Environment Variables for Production:" -ForegroundColor Yellow
    Write-Host "  DATABASE_URL        Your Neon Cloud connection string"
    Write-Host "  ARCJET_KEY          Your Arcjet API key"
    Write-Host ""
    Write-Host "Examples:" -ForegroundColor Yellow
    Write-Host "  ./setup-docker.ps1 dev               # Start development environment"
    Write-Host "  ./setup-docker.ps1 prod              # Start production environment"
    Write-Host "  ./setup-docker.ps1 stop dev          # Stop development environment"
    Write-Host "  ./setup-docker.ps1 clean dev         # Clean development environment"
    Write-Host "  ./setup-docker.ps1 logs dev          # Show development logs"
    Write-Host "  ./setup-docker.ps1 migrate dev       # Run migrations in development"
    Write-Host "  ./setup-docker.ps1 db-admin          # Start database admin"
    Write-Host ""
    Write-Host "Production Setup Example:" -ForegroundColor Yellow
    Write-Host "  `$env:DATABASE_URL = 'postgresql://neondb_owner:npg_Bynh18iqMxaZ@ep-rough-wind-a1k2rr7x-pooler.ap-southeast-1.aws.neon.tech/neondb?sslmode=require&channel_binding=require'"
    Write-Host "  `$env:ARCJET_KEY = 'ajkey_01k6vrf2c9eqjse6np9rmkhbxh'"
    Write-Host "  ./setup-docker.ps1 prod"
}

# Main script logic
function Main {
    Write-Header
    
    # Check prerequisites
    Test-Docker
    Test-DockerCompose
    
    switch ($Command.ToLower()) {
        "dev" {
            Start-DevEnvironment
        }
        "prod" {
            Start-ProdEnvironment
        }
        "stop" {
            if (-not $Environment) {
                Write-Error "Please specify environment: dev or prod"
                exit 1
            }
            Stop-Environment $Environment
        }
        "clean" {
            if (-not $Environment) {
                Write-Error "Please specify environment: dev or prod"
                exit 1
            }
            Clear-Environment $Environment
        }
        "logs" {
            if (-not $Environment) {
                Write-Error "Please specify environment: dev or prod"
                exit 1
            }
            Show-Logs $Environment
        }
        "status" {
            Show-Status
        }
        "build" {
            if (-not $Environment) {
                Write-Error "Please specify environment: dev or prod"
                exit 1
            }
            Build-Images $Environment
        }
        "migrate" {
            if (-not $Environment) {
                Write-Error "Please specify environment: dev or prod"
                exit 1
            }
            Invoke-Migrations $Environment
        }
        "db-admin" {
            Start-DbAdmin
        }
        { $_ -in "help", "--help", "-h", "" } {
            Show-Help
        }
        default {
            Write-Error "Unknown command: $Command"
            Show-Help
            exit 1
        }
    }
}

# Run main function
Main