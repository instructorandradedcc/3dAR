# install.ps1 - Script de instalación automática para Windows PowerShell
# Ejecutar con: PowerShell -ExecutionPolicy Bypass -File install.ps1

Write-Host "🚀 Instalador Automático WebAR Complete v1.0" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host ""

# Función para imprimir mensajes con colores
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Verificar PowerShell version
$PSVersion = $PSVersionTable.PSVersion.Major
if ($PSVersion -lt 5) {
    Write-Error "PowerShell 5.0+ requerido. Tu versión: $($PSVersionTable.PSVersion)"
    exit 1
}

# Verificar Node.js
Write-Status "Verificando Node.js..."
try {
    $nodeVersion = & node --version 2>$null
    if ($nodeVersion) {
        Write-Success "Node.js encontrado: $nodeVersion"
        
        # Verificar versión mínima (v16)
        $nodeMajor = [int]($nodeVersion -replace 'v(\d+)\..*', '$1')
        if ($nodeMajor -lt 16) {
            Write-Error "Node.js versión 16+ requerida. Tu versión: $nodeVersion"
            Write-Host "Por favor actualiza Node.js desde https://nodejs.org/"
            exit 1
        }
    }
} catch {
    Write-Error "Node.js no encontrado. Por favor instala Node.js 16+ desde https://nodejs.org/"
    Write-Host "También puedes usar Chocolatey: choco install nodejs"
    exit 1
}

# Verificar NPM
Write-Status "Verificando NPM..."
try {
    $npmVersion = & npm --version 2>$null
    if ($npmVersion) {
        Write-Success "NPM encontrado: v$npmVersion"
    }
} catch {
    Write-Error "NPM no encontrado. Instala NPM con Node.js"
    exit 1
}

# Crear estructura de directorios
Write-Status "Creando estructura de directorios..."

$directories = @(
    "pages",
    "js", 
    "css",
    "assets\models",
    "assets\markers", 
    "assets\images",
    "temp\uploads",
    "temp\generated",
    "temp\builds",
    "certs",
    "public"
)

foreach ($dir in $directories) {
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

# Crear archivos vacíos que faltan
$files = @(
    "pages\3d-editor.html",
    "pages\ar-verification.html",
    "pages\apk-builder.html", 
    "js\3d-editor.js",
    "js\ar-verification.js",
    "js\apk-builder.js",
    "js\app.js",
    "public\manifest.json"
)

foreach ($file in $files) {
    if (!(Test-Path $file)) {
        New-Item -ItemType File -Path $file -Force | Out-Null
    }
}

Write-Success "Estructura de directorios creada"

# Instalar dependencias
Write-Status "Instalando dependencias NPM..."
try {
    & npm install --silent
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Dependencias instaladas correctamente"
    } else {
        Write-Error "Error instalando dependencias"
        exit 1
    }
} catch {
    Write-Error "Error ejecutando npm install"
    exit 1
}

# Verificar/Instalar mkcert para HTTPS
Write-Status "Configurando certificados HTTPS..."
try {
    $mkcertVersion = & mkcert -version 2>$null
    if ($mkcertVersion) {
        Write-Success "mkcert encontrado"
        
        # Instalar CA root
        & mkcert -install 2>$null
        
        # Generar certificados para localhost
        & mkcert -key-file certs\localhost-key.pem -cert-file certs\localhost.pem localhost 127.0.0.1 ::1 2>$null
        
        if ((Test-Path "certs\localhost.pem") -and (Test-Path "certs\localhost-key.pem")) {
            Write-Success "Certificados SSL generados en .\certs\"
        } else {
            Write-Warning "Error generando certificados. Verifica instalación de mkcert"
        }
    }
} catch {
    Write-Warning "mkcert no encontrado. Se necesita para HTTPS local"
    Write-Host "Instala mkcert usando Chocolatey:"
    Write-Host "  choco install mkcert"
    Write-Host "O descarga desde: https://github.com/FiloSottile/mkcert/releases"
}

# Crear archivo .env de configuración
Write-Status "Creando configuración del entorno..."
$envContent = @"
# WebAR Complete - Variables de Entorno
NODE_ENV=development
PORT=3001
FRONTEND_PORT=3000
HTTPS_ENABLED=true
UPLOAD_MAX_SIZE=10mb
TEMP_CLEANUP_HOURS=24
"@

Set-Content -Path ".env" -Value $envContent
Write-Success "Archivo .env creado"

# Crear .gitignore
Write-Status "Creando .gitignore..."
$gitignoreContent = @"
# Dependencies
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*

# Build outputs
dist/
build/
*.tgz

# Temporary files
temp/
.cache/
.temp/

# Environment variables
.env.local
.env.production
.env.development.local

# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# IDE files
.vscode/
.idea/
*.swp
*.swo
*~

# Logs
logs/
*.log

# Runtime data
pids/
*.pid
*.seed
*.pid.lock

# Android
android/
capacitor.config.json
.capacitor/

# SSL certificates (comentar si quieres committear)
# certs/

# Specific to this project
temp/uploads/
temp/generated/
temp/builds/
"@

Set-Content -Path ".gitignore" -Value $gitignoreContent
Write-Success ".gitignore creado"

# Crear scripts de utilidad para Windows
Write-Status "Creando scripts de utilidad..."

# Script para limpiar archivos temporales (PowerShell)
$cleanScript = @"
# clean.ps1 - Limpiar archivos temporales
Write-Host "🧹 Limpiando archivos temporales..." -ForegroundColor Yellow

Remove-Item -Path "temp\uploads\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "temp\generated\*" -Recurse -Force -ErrorAction SilentlyContinue  
Remove-Item -Path "temp\builds\*" -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -Path "node_modules\.cache\*" -Recurse -Force -ErrorAction SilentlyContinue

Write-Host "✅ Limpieza completada" -ForegroundColor Green
"@

Set-Content -Path "clean.ps1" -Value $cleanScript

# Script para verificar dependencias (PowerShell)
$checkDepsScript = @"
# check-deps.ps1 - Verificar dependencias del sistema
Write-Host "🔍 Verificando dependencias del sistema..." -ForegroundColor Cyan

try { `$nodeVer = & node --version; Write-Host "Node.js: `$nodeVer" -ForegroundColor Green } catch { Write-Host "Node.js: NO INSTALADO" -ForegroundColor Red }
try { `$npmVer = & npm --version; Write-Host "NPM: v`$npmVer" -ForegroundColor Green } catch { Write-Host "NPM: NO INSTALADO" -ForegroundColor Red }
try { `$gitVer = & git --version; Write-Host "Git: `$gitVer" -ForegroundColor Green } catch { Write-Host "Git: NO INSTALADO" -ForegroundColor Red }
try { `$javaVer = & java -version 2>&1 | Select-Object -First 1; Write-Host "Java: `$javaVer" -ForegroundColor Green } catch { Write-Host "Java: NO INSTALADO" -ForegroundColor Red }
try { `$mkcertVer = & mkcert -version; Write-Host "mkcert: `$mkcertVer" -ForegroundColor Green } catch { Write-Host "mkcert: NO INSTALADO" -ForegroundColor Red }

Write-Host ""
Write-Host "📦 Verificando dependencias NPM..." -ForegroundColor Cyan
try {
    & npm list --depth=0 2>`$null
    if (`$LASTEXITCODE -ne 0) {
        Write-Host "Ejecuta 'npm install' para instalar dependencias" -ForegroundColor Yellow
    }
} catch {
    Write-Host "Error verificando dependencias NPM" -ForegroundColor Red
}

Write-Host ""
Write-Host "🔒 Verificando certificados SSL..." -ForegroundColor Cyan
if ((Test-Path "certs\localhost.pem")) {
    Write-Host "✅ Certificados SSL configurados" -ForegroundColor Green
} else {
    Write-Host "❌ Certificados SSL no encontrados" -ForegroundColor Red
    Write-Host "Ejecuta: mkcert -key-file certs\localhost-key.pem -cert-file certs\localhost.pem localhost 127.0.0.1 ::1" -ForegroundColor Yellow
}
"@

Set-Content -Path "check-deps.ps1" -Value $checkDepsScript

# Script de inicio rápido (PowerShell)
$startScript = @"
# start.ps1 - Iniciar WebAR Complete
Write-Host "🚀 Iniciando WebAR Complete..." -ForegroundColor Cyan

# Verificar dependencias
if (!(Test-Path "node_modules")) {
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    & npm install
}

# Verificar certificados
if (!(Test-Path "certs\localhost.pem")) {
    Write-Host "🔒 Generando certificados SSL..." -ForegroundColor Yellow
    & mkcert -key-file certs\localhost-key.pem -cert-file certs\localhost.pem localhost 127.0.0.1 ::1
}

Write-Host ""
Write-Host "🌐 Iniciando servidores..." -ForegroundColor Green
Write-Host "Frontend: https://localhost:3000" -ForegroundColor Blue
Write-Host "Backend:  http://localhost:3001" -ForegroundColor Blue
Write-Host ""
Write-Host "Presiona Ctrl+C para detener" -ForegroundColor Yellow

# Instalar concurrently si no existe
try {
    & npx concurrently --version 2>`$null | Out-Null
    if (`$LASTEXITCODE -ne 0) {
        Write-Host "Instalando concurrently..." -ForegroundColor Yellow
        & npm install --save-dev concurrently
    }
} catch {
    Write-Host "Instalando concurrently..." -ForegroundColor Yellow
    & npm install --save-dev concurrently
}

# Iniciar ambos servidores
& npx concurrently --names "FRONTEND,BACKEND" --prefix-colors "blue,green" "npm run dev" "npm run serve"
"@

Set-Content -Path "start.ps1" -Value $startScript

Write-Success "Scripts de utilidad creados"

# Verificar instalación de Java (opcional para APK)
Write-Status "Verificando Java JDK (opcional para APK)..."
try {
    $javaVersion = & java -version 2>&1 | Select-Object -First 1
    if ($javaVersion) {
        Write-Success "Java encontrado: $javaVersion"
    }
} catch {
    Write-Warning "Java JDK no encontrado. Necesario solo para generación de APK"
    Write-Host "Instala OpenJDK:"
    Write-Host "  choco install openjdk"
    Write-Host "  O desde https://adoptopenjdk.net/"
}

# Instalar concurrently para ejecutar múltiples comandos
Write-Status "Instalando herramientas adicionales..."
& npm install --save-dev concurrently 2>$null | Out-Null
Write-Success "Herramientas adicionales instaladas"

# Crear script batch para usuarios que prefieren CMD
$batchScript = @"
@echo off
echo 🚀 Iniciando WebAR Complete...
echo.

if not exist node_modules (
    echo 📦 Instalando dependencias...
    npm install
)

if not exist certs\localhost.pem (
    echo 🔒 Generando certificados SSL...
    mkcert -key-file certs\localhost-key.pem -cert-file certs\localhost.pem localhost 127.0.0.1 ::1
)

echo.
echo 🌐 Iniciando servidores...
echo Frontend: https://localhost:3000
echo Backend:  http://localhost:3001
echo.
echo Presiona Ctrl+C para detener

npx concurrently --names "FRONTEND,BACKEND" --prefix-colors "blue,green" "npm run dev" "npm run serve"
"@

Set-Content -Path "start.bat" -Value $batchScript

# Resumen final
Write-Host ""
Write-Host "=======================================" -ForegroundColor Green
Write-Success "¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""
Write-Host "📁 Proyecto: $(Get-Location)" -ForegroundColor Cyan
Write-Host "🌐 Frontend: https://localhost:3000" -ForegroundColor Blue
Write-Host "🔧 Backend:  http://localhost:3001" -ForegroundColor Blue
Write-Host ""
Write-Host "🚀 Para iniciar el proyecto:" -ForegroundColor Yellow
Write-Host "   .\start.ps1                # PowerShell (recomendado)"
Write-Host "   start.bat                  # Command Prompt"
Write-Host "   npm run dev                # Solo frontend"
Write-Host "   npm run serve              # Solo backend"
Write-Host ""
Write-Host "🔍 Comandos útiles:" -ForegroundColor Yellow
Write-Host "   .\check-deps.ps1           # Verificar dependencias"
Write-Host "   .\clean.ps1                # Limpiar archivos temporales"
Write-Host "   npm run android:add        # Configurar Android (requiere Android Studio)"
Write-Host ""
Write-Host "📖 Documentación completa en README.md" -ForegroundColor Cyan
Write-Host ""

# Verificar si todo está listo para ejecutar
if ((Test-Path "package.json") -and (Test-Path "node_modules")) {
    Write-Success "El proyecto está listo para ejecutar"
    Write-Host ""
    
    $response = Read-Host "¿Quieres iniciar el servidor ahora? (y/n)"
    if ($response -match "^[yY]") {
        & .\start.ps1
    } else {
        Write-Host "Puedes iniciar el servidor más tarde con: .\start.ps1" -ForegroundColor Cyan
    }
} else {
    Write-Warning "Hay problemas con la instalación. Revisa los mensajes anteriores."
}

Write-Host ""
Write-Host "¡Feliz desarrollo de WebAR! 🚀📱" -ForegroundColor Magenta