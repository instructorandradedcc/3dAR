# 🚀 Guía de Despliegue para Servidores Gratuitos

## 🌐 **Plataformas Compatibles**

### **1. Vercel (Recomendado)**
```bash
# Instalar Vercel CLI
npm i -g vercel

# Desplegar
vercel --prod
```

**Características:**
- ✅ Deploy automático desde GitHub
- ✅ HTTPS automático
- ✅ CDN global
- ✅ Funciones serverless
- ✅ Dominio personalizado

### **2. Netlify**
```bash
# Instalar Netlify CLI
npm i -g netlify-cli

# Desplegar
netlify deploy --prod
```

**Características:**
- ✅ Deploy automático desde GitHub
- ✅ HTTPS automático
- ✅ CDN global
- ✅ Formularios y funciones
- ✅ Dominio personalizado

### **3. GitHub Pages**
```bash
# Crear branch gh-pages
git checkout -b gh-pages
git push origin gh-pages
```

**Características:**
- ✅ Gratuito para repos públicos
- ✅ HTTPS automático
- ✅ Integración con GitHub
- ❌ Solo archivos estáticos

### **4. Firebase Hosting**
```bash
# Instalar Firebase CLI
npm i -g firebase-tools

# Inicializar y desplegar
firebase init hosting
firebase deploy
```

## 📋 **Instrucciones de Despliegue**

### **Opción A: Vercel (Más Fácil)**

1. **Subir a GitHub:**
   ```bash
   git init
   git add .
   git commit -m "WebAR Complete - Listo para deploy"
   git push origin main
   ```

2. **Conectar con Vercel:**
   - Ve a [vercel.com](https://vercel.com)
   - Conecta tu cuenta de GitHub
   - Importa el repositorio
   - Deploy automático

3. **Configuración automática:**
   - Vercel detectará el `vercel.json`
   - Usará `static-server.js` como entry point
   - Deploy en minutos

### **Opción B: Netlify**

1. **Subir a GitHub** (igual que arriba)

2. **Conectar con Netlify:**
   - Ve a [netlify.com](https://netlify.com)
   - Conecta tu cuenta de GitHub
   - Importa el repositorio
   - Netlify usará `netlify.toml` automáticamente

### **Opción C: GitHub Pages**

1. **Preparar archivos:**
   ```bash
   # Crear branch gh-pages
   git checkout -b gh-pages
   
   # Copiar archivos necesarios
   cp -r pages/* .
   cp -r css .
   cp -r js .
   cp index.html .
   cp test.html .
   ```

2. **Configurar GitHub Pages:**
   - Ve a Settings > Pages
   - Selecciona "Deploy from a branch"
   - Selecciona "gh-pages" branch
   - Accede a `https://tuusuario.github.io/turepo`

## 🔧 **Configuración Local para Testing**

### **Servidor Estático:**
```bash
npm run serve:static
# Accede a http://localhost:3000
```

### **Servidor Completo:**
```bash
npm run serve
# Accede a http://localhost:3001
```

## 📱 **URLs de Acceso**

### **Después del Deploy:**
- **Página principal:** `https://tu-dominio.vercel.app/`
- **Test:** `https://tu-dominio.vercel.app/test.html`
- **Generador:** `https://tu-dominio.vercel.app/pages/marker-generator.html`
- **Editor 3D:** `https://tu-dominio.vercel.app/pages/3d-editor.html`
- **Verificación AR:** `https://tu-dominio.vercel.app/pages/ar-verification.html`
- **Constructor APK:** `https://tu-dominio.vercel.app/pages/apk-builder.html`

## ⚠️ **Limitaciones en Servidores Gratuitos**

### **Funcionalidades Disponibles:**
- ✅ Generación de marcadores AR (local)
- ✅ Editor 3D interactivo
- ✅ Verificación AR básica
- ✅ Preview de configuración APK
- ✅ Exportación/importación de proyectos
- ✅ Navegación completa

### **Funcionalidades No Disponibles:**
- ❌ Upload de archivos al servidor
- ❌ Generación real de APK
- ❌ APIs del backend
- ❌ Almacenamiento en servidor

## 🚀 **Recomendaciones**

### **Para Desarrollo:**
- Usa `npm run serve` (servidor completo)
- Todas las funcionalidades disponibles

### **Para Producción:**
- Usa Vercel o Netlify
- Funcionalidades básicas disponibles
- Optimizado para móviles

### **Para Funcionalidad Completa:**
- Despliega en servidor con Node.js
- Usa `npm run serve`
- Todas las funcionalidades disponibles

## 📊 **Comparación de Plataformas**

| Plataforma | Gratuito | HTTPS | CDN | Node.js | Fácil Deploy |
|------------|----------|-------|-----|---------|--------------|
| Vercel     | ✅       | ✅    | ✅  | ✅      | ✅           |
| Netlify    | ✅       | ✅    | ✅  | ✅      | ✅           |
| GitHub Pages | ✅    | ✅    | ✅  | ❌      | ✅           |
| Firebase   | ✅       | ✅    | ✅  | ✅      | ⚠️           |

## 🎯 **Próximos Pasos**

1. **Elegir plataforma** (recomendado: Vercel)
2. **Subir a GitHub**
3. **Conectar con plataforma**
4. **Deploy automático**
5. **¡Disfrutar tu WebAR en producción!**

---

**🎉 ¡Tu aplicación WebAR estará disponible en internet en minutos!**


