# setup-android-fix.ps1 - Configuracion automatica
Write-Host "Configurando Android para WebAR Complete..." -ForegroundColor Green

# Configurar variables de entorno
Write-Host "Configurando variables de entorno..." -ForegroundColor Yellow
$env:ANDROID_HOME = "D:\androidstudio\sdk"
$env:ANDROID_SDK_ROOT = "D:\androidstudio\sdk"

# Verificar rutas
if (-not (Test-Path "D:\androidstudio\sdk")) {
    Write-Host "Error: Android SDK no encontrado" -ForegroundColor Red
    exit 1
}

if (-not (Test-Path "F:\linux\3d-AR\capacitor\android")) {
    Write-Host "Error: Proyecto Android no encontrado" -ForegroundColor Red
    exit 1
}

# Crear directorio android
if (-not (Test-Path "android")) {
    Write-Host "Creando directorio android..." -ForegroundColor Yellow
    New-Item -ItemType Directory -Name "android" -Force
}

# Copiar configuracion Android
Write-Host "Copiando configuracion Android..." -ForegroundColor Yellow
Copy-Item -Path "F:\linux\3d-AR\capacitor\android\*" -Destination "android\" -Recurse -Force

# Actualizar package ID
Write-Host "Actualizando configuracion..." -ForegroundColor Yellow
$buildGradlePath = "android\app\build.gradle"
if (Test-Path $buildGradlePath) {
    $content = Get-Content $buildGradlePath -Raw
    $content = $content -replace "com\.librosdar\.ecobook12", "com.webar.complete"
    $content = $content -replace "ecobook12", "WebAR Complete"
    Set-Content $buildGradlePath $content
}

# Actualizar AndroidManifest
$manifestPath = "android\app\src\main\AndroidManifest.xml"
if (Test-Path $manifestPath) {
    $content = Get-Content $manifestPath -Raw
    $content = $content -replace "com\.librosdar\.ecobook12", "com.webar.complete"
    Set-Content $manifestPath $content
}

# Actualizar capacitor.config.ts
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

Write-Host "Configuracion completada!" -ForegroundColor Green
Write-Host "Para generar APK ejecuta: npm run android:build-real" -ForegroundColor Cyan
