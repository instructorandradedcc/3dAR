# build-apk-final.ps1 - Script final para generar APK
Write-Host "🚀 WebAR Complete - Generador de APK" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Configurar variables de entorno
Write-Host "📱 Configurando entorno Android..." -ForegroundColor Yellow
$env:ANDROID_HOME = "D:\androidstudio\sdk"
$env:ANDROID_SDK_ROOT = "D:\androidstudio\sdk"
$env:PATH += ";D:\androidstudio\sdk\platform-tools;D:\androidstudio\sdk\build-tools\34.0.0"

# Verificar que Android SDK existe
if (-not (Test-Path "D:\androidstudio\sdk")) {
    Write-Host "❌ Error: Android SDK no encontrado en D:\androidstudio\sdk" -ForegroundColor Red
    Write-Host "Por favor, verifica la instalación de Android Studio" -ForegroundColor Yellow
    exit 1
}

# Verificar que el proyecto Android existe
if (-not (Test-Path "android")) {
    Write-Host "❌ Error: Proyecto Android no encontrado" -ForegroundColor Red
    Write-Host "Ejecuta primero: .\setup-android-fix.ps1" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ Entorno configurado correctamente" -ForegroundColor Green

# Paso 1: Build del proyecto web
Write-Host "`n📦 Paso 1: Construyendo proyecto web..." -ForegroundColor Cyan
try {
    npm run build
    Write-Host "✅ Proyecto web construido exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error construyendo proyecto web: $_" -ForegroundColor Red
    exit 1
}

# Paso 2: Sincronizar con Capacitor
Write-Host "`n🔄 Paso 2: Sincronizando con Capacitor..." -ForegroundColor Cyan
try {
    npx cap sync android
    Write-Host "✅ Sincronización completada" -ForegroundColor Green
} catch {
    Write-Host "❌ Error en sincronización: $_" -ForegroundColor Red
    exit 1
}

# Paso 3: Generar APK
Write-Host "`n🔨 Paso 3: Generando APK..." -ForegroundColor Cyan
try {
    Set-Location android
    .\gradlew assembleDebug
    Write-Host "✅ APK generado exitosamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error generando APK: $_" -ForegroundColor Red
    Set-Location ..
    exit 1
}

# Volver al directorio principal
Set-Location ..

# Buscar el APK generado
$apkPath = "android\app\build\outputs\apk\debug"
if (Test-Path $apkPath) {
    $apkFiles = Get-ChildItem $apkPath -Filter "*.apk"
    if ($apkFiles.Count -gt 0) {
        $apkFile = $apkFiles[0]
        $apkSize = [math]::Round($apkFile.Length / 1MB, 2)
        
        Write-Host "`n🎉 ¡APK GENERADO EXITOSAMENTE!" -ForegroundColor Green
        Write-Host "=================================" -ForegroundColor Green
        Write-Host "📱 Archivo: $($apkFile.Name)" -ForegroundColor White
        Write-Host "📏 Tamaño: $apkSize MB" -ForegroundColor White
        Write-Host "📍 Ubicación: $($apkFile.FullName)" -ForegroundColor White
        Write-Host "⏰ Generado: $($apkFile.LastWriteTime)" -ForegroundColor White
        
        # Abrir carpeta con el APK
        Write-Host "`n📁 Abriendo carpeta con el APK..." -ForegroundColor Yellow
        Start-Process explorer.exe -ArgumentList $apkPath
        
        Write-Host "`n📋 Instrucciones de instalación:" -ForegroundColor Cyan
        Write-Host "1. Transfiere el APK a tu dispositivo Android" -ForegroundColor White
        Write-Host "2. Habilita 'Fuentes desconocidas' en Configuración > Seguridad" -ForegroundColor White
        Write-Host "3. Toca el archivo APK para instalarlo" -ForegroundColor White
        Write-Host "4. Acepta los permisos de cámara cuando se soliciten" -ForegroundColor White
        Write-Host "5. ¡Disfruta tu aplicación AR!" -ForegroundColor White
        
    } else {
        Write-Host "❌ No se encontraron archivos APK en la carpeta de salida" -ForegroundColor Red
    }
} else {
    Write-Host "❌ Carpeta de salida del APK no encontrada" -ForegroundColor Red
}

Write-Host "`n🏆 ¡Proceso completado!" -ForegroundColor Green
Write-Host "Tu aplicación WebAR Complete está lista para usar" -ForegroundColor White
