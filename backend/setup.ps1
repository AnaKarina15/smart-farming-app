# =============================================================================
# AgroField Backend - Script de Setup Automatico (Windows / PowerShell)
# =============================================================================
# Este script automatiza:
#   1. Verificacion de prerequisitos (Node, npm, Docker, Git)
#   2. Creacion del archivo .env desde .env.example
#   3. Instalacion de dependencias npm
#   4. Levantamiento de PostgreSQL en Docker
#   5. Espera a que la base de datos este lista
#   6. Ejecucion de migraciones
#
# Uso:
#   1. Descomprime el ZIP en una carpeta de tu eleccion
#   2. Abre PowerShell en esa carpeta
#   3. Si es la primera vez que ejecutas un script .ps1, ejecuta primero:
#        Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned
#   4. Ejecuta: .\setup.ps1
# =============================================================================

$ErrorActionPreference = "Stop"

function Write-Section {
    param([string]$Message)
    Write-Host ""
    Write-Host "==============================================================" -ForegroundColor Cyan
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host "==============================================================" -ForegroundColor Cyan
}

function Write-Step {
    param([string]$Message)
    Write-Host ">> $Message" -ForegroundColor Green
}

function Write-Warning2 {
    param([string]$Message)
    Write-Host "!! $Message" -ForegroundColor Yellow
}

function Write-Error2 {
    param([string]$Message)
    Write-Host "XX $Message" -ForegroundColor Red
}

# -----------------------------------------------------------------------------
Write-Section "AgroField Backend - Setup Automatico"
# -----------------------------------------------------------------------------

# Verificar que estamos en el directorio correcto
if (-not (Test-Path "package.json")) {
    Write-Error2 "No se encontro package.json. Ejecuta este script desde la raiz del proyecto."
    exit 1
}

# -----------------------------------------------------------------------------
Write-Section "Paso 1/6: Verificar prerequisitos"
# -----------------------------------------------------------------------------

Write-Step "Verificando Node.js..."
try {
    $nodeVersion = node --version
    Write-Host "   Node.js: $nodeVersion" -ForegroundColor Gray
    $major = [int]($nodeVersion -replace 'v(\d+).*', '$1')
    if ($major -lt 22) {
        Write-Warning2 "Se recomienda Node.js 22 LTS o superior. Tienes $nodeVersion"
    }
} catch {
    Write-Error2 "Node.js no esta instalado o no esta en el PATH"
    exit 1
}

Write-Step "Verificando npm..."
try {
    $npmVersion = npm --version
    Write-Host "   npm: $npmVersion" -ForegroundColor Gray
} catch {
    Write-Error2 "npm no esta disponible"
    exit 1
}

Write-Step "Verificando Docker..."
try {
    $dockerVersion = docker --version
    Write-Host "   $dockerVersion" -ForegroundColor Gray

    # Verificar que Docker este corriendo
    docker ps > $null 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error2 "Docker esta instalado pero no esta corriendo. Inicia Docker Desktop y vuelve a ejecutar este script."
        exit 1
    }
} catch {
    Write-Error2 "Docker no esta instalado o no esta en el PATH"
    exit 1
}

Write-Step "Verificando Git..."
try {
    $gitVersion = git --version
    Write-Host "   $gitVersion" -ForegroundColor Gray
} catch {
    Write-Warning2 "Git no esta instalado (opcional para correr el proyecto, recomendado para version control)"
}

# -----------------------------------------------------------------------------
Write-Section "Paso 2/6: Crear archivo .env"
# -----------------------------------------------------------------------------

if (Test-Path ".env") {
    Write-Warning2 "El archivo .env ya existe. No se sobrescribira."
} else {
    Copy-Item ".env.example" ".env"
    Write-Step "Archivo .env creado desde .env.example"
    Write-Host "   IMPORTANTE: Revisa el archivo .env y ajusta valores si es necesario" -ForegroundColor Gray
}

# -----------------------------------------------------------------------------
Write-Section "Paso 3/6: Instalar dependencias npm"
# -----------------------------------------------------------------------------

Write-Step "Ejecutando npm install (esto puede tardar varios minutos)..."
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Error2 "npm install fallo. Revisa los errores arriba."
    exit 1
}
Write-Step "Dependencias instaladas correctamente"

# -----------------------------------------------------------------------------
Write-Section "Paso 4/6: Levantar PostgreSQL en Docker"
# -----------------------------------------------------------------------------

Write-Step "Iniciando contenedores Docker (PostgreSQL + pgAdmin)..."
docker compose up -d
if ($LASTEXITCODE -ne 0) {
    Write-Error2 "docker compose up fallo. Revisa los errores arriba."
    exit 1
}

# -----------------------------------------------------------------------------
Write-Section "Paso 5/6: Esperar a que PostgreSQL este listo"
# -----------------------------------------------------------------------------

Write-Step "Esperando a que PostgreSQL acepte conexiones..."
$maxAttempts = 30
$attempt = 0
$ready = $false

while ($attempt -lt $maxAttempts -and -not $ready) {
    $attempt++
    Start-Sleep -Seconds 2
    $health = docker inspect --format='{{.State.Health.Status}}' agrofield-postgres 2>$null
    if ($health -eq "healthy") {
        $ready = $true
        Write-Step "PostgreSQL esta listo (intento $attempt/$maxAttempts)"
    } else {
        Write-Host "   Esperando... ($attempt/$maxAttempts) estado: $health" -ForegroundColor Gray
    }
}

if (-not $ready) {
    Write-Error2 "PostgreSQL no inicio dentro del tiempo esperado"
    Write-Host "   Revisa los logs con: docker compose logs postgres" -ForegroundColor Gray
    exit 1
}

# -----------------------------------------------------------------------------
Write-Section "Paso 6/6: Ejecutar migraciones"
# -----------------------------------------------------------------------------

Write-Step "Aplicando migraciones a la base de datos..."
npm run migration:run
if ($LASTEXITCODE -ne 0) {
    Write-Error2 "Las migraciones fallaron. Revisa los errores arriba."
    exit 1
}
Write-Step "Migraciones aplicadas correctamente"

# -----------------------------------------------------------------------------
Write-Section "Setup completado exitosamente"
# -----------------------------------------------------------------------------

Write-Host ""
Write-Host "  Para arrancar el servidor en modo desarrollo:" -ForegroundColor Yellow
Write-Host "    npm run start:dev" -ForegroundColor White
Write-Host ""
Write-Host "  URLs disponibles una vez arrancado:" -ForegroundColor Yellow
Write-Host "    API:        http://localhost:3000/api/v1" -ForegroundColor White
Write-Host "    Swagger UI: http://localhost:3000/api/docs" -ForegroundColor White
Write-Host "    Health:     http://localhost:3000/api/v1/health" -ForegroundColor White
Write-Host "    pgAdmin:    http://localhost:5050  (admin@agrofield.local / admin)" -ForegroundColor White
Write-Host ""
Write-Host "  Para probar los endpoints en IntelliJ:" -ForegroundColor Yellow
Write-Host "    Abre el archivo requests.http y ejecuta los bloques con el boton play" -ForegroundColor White
Write-Host ""
