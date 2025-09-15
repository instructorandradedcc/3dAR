# setup-android.ps1 - Script de configuración automática para Android
# WebAR Complete - Integración con Android Studio y Capacitor

Write-Host "🚀 Configurando Android para WebAR Complete..." -ForegroundColor Green

# Configurar variables de entorno
Write-Host "📱 Configurando variables de entorno..." -ForegroundColor Yellow
$env:ANDROID_HOME = "D:\androidstudio\sdk"
$env:ANDROID_SDK_ROOT = "D:\androidstudio\sdk"
$env:PATH += ";D:\androidstudio\sdk\platform-tools;D:\androidstudio\sdk\build-tools\34.0.0"

# Verificar que las rutas existen
if (-not (Test-Path "D:\androidstudio\sdk")) {
    Write-Host "❌ Error: Android SDK no encontrado en D:\androidstudio\sdk" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "F:\linux\3d-AR\capacitor\android")) {
    Write-Host "❌ Error: Proyecto Android Capacitor no encontrado en F:\linux\3d-AR\capacitor\android" -ForegroundColor Red
    exit 1
}

# Crear directorio android si no existe
if (-not (Test-Path "android")) {
    Write-Host "📁 Creando directorio android..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Name "android"
}

# Copiar configuración Android existente
Write-Host "📋 Copiando configuración Android existente..." -ForegroundColor Yellow
Copy-Item -Path "F:\linux\3d-AR\capacitor\android\*" -Destination "android\" -Recurse -Force

# Actualizar package ID en build.gradle
Write-Host "🔧 Actualizando package ID..." -ForegroundColor Yellow
$buildGradlePath = "android\app\build.gradle"
if (Test-Path $buildGradlePath) {
    $content = Get-Content $buildGradlePath -Raw
    $content = $content -replace "com\.librosdar\.ecobook12", "com.webar.complete"
    $content = $content -replace "ecobook12", "WebAR Complete"
    Set-Content $buildGradlePath $content
    Write-Host "✅ build.gradle actualizado" -ForegroundColor Green
}

# Actualizar AndroidManifest.xml
Write-Host "📱 Actualizando AndroidManifest.xml..." -ForegroundColor Yellow
$manifestPath = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $content = Get-Content $manifestPath -Raw
    $content = $content -replace "com\.librosdar\.ecobook12", "com.webar.complete"
    Set-Content $manifestPath $content
    Write-Host "✅ AndroidManifest.xml actualizado" -ForegroundColor Green
}

# Actualizar strings.xml
Write-Host "🏷️ Actualizando strings.xml..." -ForegroundColor Yellow
$stringsPath = "android\app\src\main\res\values\strings.xml"
if (Test-Path $stringsPath) {
    $content = Get-Content $stringsPath -Raw
    $content = $content -replace "ecobook12", "WebAR Complete"
    Set-Content $stringsPath $content
    Write-Host "✅ strings.xml actualizado" -ForegroundColor Green
}

# Actualizar capacitor.config.ts
Write-Host "⚙️ Actualizando capacitor.config.ts..." -ForegroundColor Yellow
$capacitorConfig = @"
import { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'com.webar.complete',
  appName: 'WebAR Complete',
  webDir: 'dist',
  server: {
    androidScheme: 'https',
    hostname: 'localhost',
    allowNavigation: ['*']
  },
  android: {
    buildOptions: {
      keystorePath: '',
      keystorePassword: '',
      keystoreAlias: '',
      keystoreAliasPassword: '',
      releaseType: 'APK'
    }
  },
  plugins: {
    Camera: {
      permissions: ['camera', 'photos']
    },
    Filesystem: {
      permissions: ['write_external_storage', 'read_external_storage']
    }
  }
};

export default config;
"@

Set-Content "capacitor.config.ts" $capacitorConfig
Write-Host "✅ capacitor.config.ts actualizado" -ForegroundColor Green

# Verificar que npm está disponible
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Error: npm no está disponible" -ForegroundColor Red
    exit 1
}

# Instalar dependencias si es necesario
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    npm install
}

# Sincronizar con Capacitor
Write-Host "🔄 Sincronizando con Capacitor..." -ForegroundColor Yellow
try {
    npx cap sync android
    Write-Host "✅ Sincronización completada" -ForegroundColor Green
} catch {
    Write-Host "⚠️ Advertencia: Error en sincronización, continuando..." -ForegroundColor Yellow
}

# Crear script de build
Write-Host "🔨 Creando script de build..." -ForegroundColor Yellow
$buildScript = @"
@echo off
echo 🚀 Generando APK para WebAR Complete...

REM Configurar variables de entorno
set ANDROID_HOME=D:\androidstudio\sdk
set ANDROID_SDK_ROOT=D:\androidstudio\sdk
set PATH=%PATH%;D:\androidstudio\sdk\platform-tools;D:\androidstudio\sdk\build-tools\34.0.0

REM Build del proyecto web
echo 📦 Construyendo proyecto web...
npm run build

REM Sincronizar con Android
echo 🔄 Sincronizando con Android...
npx cap sync android

REM Generar APK
echo 🔨 Generando APK...
cd android
gradlew assembleDebug

echo ✅ APK generado en: android\app\build\outputs\apk\debug\
pause
"@

Set-Content "build-apk.bat" $buildScript
Write-Host "✅ Script de build creado: build-apk.bat" -ForegroundColor Green

# Crear script de build PowerShell
$buildScriptPS = @"
# build-apk.ps1 - Script de build para WebAR Complete
Write-Host "🚀 Generando APK para WebAR Complete..." -ForegroundColor Green

# Configurar variables de entorno
`$env:ANDROID_HOME = "D:\androidstudio\sdk"
`$env:ANDROID_SDK_ROOT = "D:\androidstudio\sdk"
`$env:PATH += ";D:\androidstudio\sdk\platform-tools;D:\androidstudio\sdk\build-tools\34.0.0"

# Build del proyecto web
Write-Host "📦 Construyendo proyecto web..." -ForegroundColor Yellow
npm run build

# Sincronizar con Android
Write-Host "🔄 Sincronizando con Android..." -ForegroundColor Yellow
npx cap sync android

# Generar APK
Write-Host "🔨 Generando APK..." -ForegroundColor Yellow
Set-Location android
.\gradlew assembleDebug

Write-Host "✅ APK generado en: android\app\build\outputs\apk\debug\" -ForegroundColor Green
"@

Set-Content "build-apk.ps1" $buildScriptPS
Write-Host "✅ Script de build PowerShell creado: build-apk.ps1" -ForegroundColor Green

# Verificar configuración
Write-Host "🔍 Verificando configuración..." -ForegroundColor Yellow

$checks = @(
    @{Name="Android SDK"; Path="D:\androidstudio\sdk"; Required=$true},
    @{Name="Proyecto Android"; Path="android"; Required=$true},
    @{Name="capacitor.config.ts"; Path="capacitor.config.ts"; Required=$true},
    @{Name="package.json"; Path="package.json"; Required=$true}
)

$allGood = $true
foreach ($check in $checks) {
    if (Test-Path $check.Path) {
        Write-Host "✅ $($check.Name): OK" -ForegroundColor Green
    } else {
        Write-Host "❌ $($check.Name): NO ENCONTRADO" -ForegroundColor Red
        if ($check.Required) {
            $allGood = $false
        }
    }
}

if ($allGood) {
    Write-Host "`n🎉 ¡Configuración Android completada exitosamente!" -ForegroundColor Green
    Write-Host "📱 Para generar APK ejecuta: .\build-apk.ps1" -ForegroundColor Cyan
    Write-Host "🔧 Para abrir en Android Studio: npx cap open android" -ForegroundColor Cyan
} else {
    Write-Host "`n⚠️ Configuración incompleta. Revisa los errores arriba." -ForegroundColor Yellow
}

Write-Host "`n📋 Resumen de configuración:" -ForegroundColor Cyan
Write-Host "   • Android SDK: D:\androidstudio\sdk" -ForegroundColor White
Write-Host "   • Proyecto Android: android\" -ForegroundColor White
Write-Host "   • Package ID: com.webar.complete" -ForegroundColor White
Write-Host "   • App Name: WebAR Complete" -ForegroundColor White
Write-Host "   • Target SDK: 34" -ForegroundColor White
Write-Host "   • Min SDK: 24" -ForegroundColor White
