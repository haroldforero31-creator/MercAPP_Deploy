# ============================================================
# MercAPP — Script de Sincronizacion para Deploy
# Copia Backend + Frontend al monorepo de despliegue
# ============================================================

$ErrorActionPreference = "Stop"

$DEPLOY_DIR   = $PSScriptRoot
$BACKEND_SRC  = "c:\Users\USUARIO\Pictures\MercAPP_IS2_Backend"
$FRONTEND_SRC = "c:\Users\USUARIO\Pictures\MercAPP_IS2_Frontend"

Write-Host "
========================================" -ForegroundColor Cyan
Write-Host "  MercAPP - Sincronizando para Deploy" -ForegroundColor Cyan
Write-Host "========================================
" -ForegroundColor Cyan

# 1. Limpiar archivos anteriores (preservar .git y archivos de deploy)
Write-Host "[1/4] Limpiando archivos anteriores..." -ForegroundColor Yellow
$preserveItems = @('.git', '.gitignore', 'render.yaml', 'build.sh', 'Procfile', 'sync_deploy.ps1', 'README.md')

Get-ChildItem -Path $DEPLOY_DIR -Force | Where-Object {
    $preserveItems -notcontains $_.Name
} | ForEach-Object {
    Remove-Item $_.FullName -Recurse -Force -ErrorAction SilentlyContinue
}

# 2. Copiar Backend
Write-Host "[2/4] Copiando Backend..." -ForegroundColor Yellow
$backendExcludes = @(
    'venv', '__pycache__', '.git', '.env', 'mercapp.db', 'mercapp.db-shm', 'mercapp.db-wal',
    'uploads', 'dist', 'dist_package', 'build', 'logs',
    'MercAPP_IS2_Windows', 'MercAPP_IS2_Windows.rar', 'MercAPP_IS2_Windows.zip',
    'instance', '.gitignore'
)

Get-ChildItem -Path $BACKEND_SRC -Force | Where-Object {
    $backendExcludes -notcontains $_.Name
} | ForEach-Object {
    if ($_.PSIsContainer) {
        Copy-Item $_.FullName -Destination (Join-Path $DEPLOY_DIR $_.Name) -Recurse -Force
    } else {
        Copy-Item $_.FullName -Destination $DEPLOY_DIR -Force
    }
}
Write-Host "   OK Backend copiado" -ForegroundColor Green

# 3. Copiar Frontend
Write-Host "[3/4] Copiando Frontend..." -ForegroundColor Yellow
$frontendDest = Join-Path $DEPLOY_DIR "MercAPP_IS2_Frontend"
$frontendExcludes = @('.git', '__pycache__', 'node_modules')

if (Test-Path $frontendDest) { Remove-Item $frontendDest -Recurse -Force }
New-Item -ItemType Directory -Path $frontendDest -Force | Out-Null

Get-ChildItem -Path $FRONTEND_SRC -Force | Where-Object {
    $frontendExcludes -notcontains $_.Name
} | ForEach-Object {
    if ($_.PSIsContainer) {
        Copy-Item $_.FullName -Destination (Join-Path $frontendDest $_.Name) -Recurse -Force
    } else {
        Copy-Item $_.FullName -Destination $frontendDest -Force
    }
}
Write-Host "   OK Frontend copiado" -ForegroundColor Green

# 4. Crear directorio uploads con .gitkeep
Write-Host "[4/4] Creando directorios de uploads..." -ForegroundColor Yellow
$uploadDirs = @('uploads\products', 'uploads\categories', 'uploads\invoices')
foreach ($dir in $uploadDirs) {
    $fullPath = Join-Path $DEPLOY_DIR $dir
    New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
    New-Item -ItemType File -Path (Join-Path $fullPath '.gitkeep') -Force | Out-Null
}
Write-Host "   OK Directorios uploads creados" -ForegroundColor Green

Write-Host "
========================================" -ForegroundColor Green
Write-Host "  Sincronizacion completada!" -ForegroundColor Green
Write-Host "========================================
" -ForegroundColor Green
