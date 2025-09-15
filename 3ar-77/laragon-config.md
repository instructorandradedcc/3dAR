# 🚀 Configuración para Laragon

## 📋 Instrucciones para usar WebAR Complete con Laragon

### **Opción 1: Solo Frontend (Recomendado para desarrollo)**

1. **Abrir Laragon**
2. **Iniciar Apache** (si no está iniciado)
3. **Acceder a la aplicación:**
   - URL: `http://localhost/3ar-77/`
   - O: `http://3ar-77.test/` (si tienes auto-virtual hosts habilitado)

### **Opción 2: Frontend + Backend (Funcionalidad completa)**

1. **Iniciar Laragon** (Apache)
2. **Ejecutar servidor Node.js:**
   ```bash
   npm run serve
   ```
3. **Acceder a la aplicación:**
   - Frontend: `http://localhost/3ar-77/`
   - Backend API: `http://localhost:3001/api/`

## 🔧 Configuración de Laragon

### **Virtual Host (Opcional)**
Si quieres usar un dominio personalizado:

1. En Laragon, ve a **Menu > Apache > sites-enabled**
2. Crea un archivo `3ar-77.conf`:
   ```apache
   <VirtualHost *:80>
       DocumentRoot "F:/linux/paginas/servidoreslocales/laragon/laragon/www/3ar-77"
       ServerName 3ar-77.test
       <Directory "F:/linux/paginas/servidoreslocales/laragon/laragon/www/3ar-77">
           AllowOverride All
           Require all granted
       </Directory>
   </VirtualHost>
   ```
3. Reinicia Apache
4. Accede a: `http://3ar-77.test/`

## 📱 URLs de Acceso

### **Con Laragon (Apache):**
- **🚀 Dashboard Profesional:** `http://localhost/3ar-77/dashboard.html`
- **📊 Estado del Sistema:** `http://localhost/3ar-77/system-status.html`
- **🏠 Página Principal:** `http://localhost/3ar-77/laragon-index.html`
- **🧪 Tests Completos:** `http://localhost/3ar-77/test-complete.html`
- **🎯 Generador de marcadores:** `http://localhost/3ar-77/pages/marker-generator.html`
- **🎨 Editor 3D:** `http://localhost/3ar-77/pages/3d-editor.html`
- **📱 Verificación AR:** `http://localhost/3ar-77/pages/ar-verification.html`
- **🔨 Constructor APK:** `http://localhost/3ar-77/pages/apk-builder.html`

### **Con Node.js (Backend completo):**
- **Página principal:** `http://localhost:3001/`
- **API Health:** `http://localhost:3001/api/health`

## ⚠️ Limitaciones con solo Apache

Si usas solo Laragon (Apache) sin el servidor Node.js:

- ✅ **Funciona:** Todas las páginas frontend
- ✅ **Funciona:** Generación de marcadores (local)
- ✅ **Funciona:** Editor 3D
- ✅ **Funciona:** Verificación AR básica
- ❌ **No funciona:** APIs del backend (upload, build APK)
- ❌ **No funciona:** Generación real de APK

## 🚀 Recomendación

**Para desarrollo completo:**
1. Usa Laragon para servir los archivos estáticos
2. Ejecuta `npm run serve` para el backend
3. Accede a `http://localhost/3ar-77/` para el frontend

**Para solo frontend:**
1. Usa solo Laragon
2. Accede a `http://localhost/3ar-77/`
3. Las funcionalidades básicas funcionarán sin problemas

