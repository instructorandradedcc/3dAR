# WebAR Complete - Generador Completo de Aplicaciones AR

Una aplicación web completa que permite crear aplicaciones de Realidad Aumentada desde la generación de marcadores hasta la compilación de APKs de Android.

## 🚀 Características Principales

- ✅ **Generador de Marcadores AR**: Sube imágenes JPG y modelos 3D, genera archivos .patt automáticamente
- ✅ **Editor 3D Interactivo**: Posiciona, rota y escala modelos 3D sobre marcadores usando Three.js
- ✅ **Verificación AR en Tiempo Real**: Prueba experiencias AR usando la cámara del dispositivo
- ✅ **Generador de APK**: Convierte aplicaciones web en APKs de Android usando Capacitor
- ✅ **Interfaz Responsiva**: Funciona en escritorio y dispositivos móviles
- ✅ **Tecnologías Modernas**: AR.js, Three.js, A-Frame, Capacitor, Express.js

## 🛠️ Requisitos del Sistema

### Para Desarrollo
- **Node.js 16+** (recomendado v18 o v20)
- **NPM 8+** o **Yarn 1.22+**
- **Git** para control de versiones
- **Chrome 90+** o **Firefox 90+**

### Para Generación de APK (Opcional)
- **Java JDK 8+** (OpenJDK u Oracle JDK)
- **Android Studio** con Android SDK
- **Android SDK Build Tools 30+**
- **Gradle 7+**

### Verificar Instalaciones
```bash
node --version    # Debe mostrar v16+
npm --version     # Debe mostrar v8+
java -version     # Debe mostrar JDK 8+
```

## 📦 Instalación Rápida

### 1. Clonar o Crear Proyecto
```bash
# Opción A: Si tienes el repositorio
git clone [URL_DEL_REPO]
cd webAR-app

# Opción B: Crear desde cero
mkdir webAR-app
cd webAR-app
```

### 2. Crear Estructura de Archivos
Crear los siguientes archivos y carpetas:

```
webAR-app/
├── package.json                 # ✅ Ya creado
├── capacitor.config.ts         # ✅ Ya creado  
├── vite.config.js              # ✅ Ya creado
├── server.js                   # ✅ Ya creado
├── index.html                  # ✅ Ya creado
├── pages/
│   ├── marker-generator.html   # Crear este archivo
│   ├── 3d-editor.html         # Crear este archivo
│   ├── ar-verification.html   # Crear este archivo
│   └── apk-builder.html       # Crear este archivo
├── js/
│   ├── marker-generator.js    # ✅ Ya creado
│   ├── 3d-editor.js          # Crear este archivo
│   ├── ar-verification.js    # Crear este archivo
│   └── apk-builder.js        # Crear este archivo
├── css/
│   ├── styles.css            # ✅ Ya creado
│   └── components.css        # ✅ Ya creado
├── assets/
│   ├── models/               # Crear carpeta
│   ├── markers/              # Crear carpeta
│   └── images/               # Crear carpeta
└── temp/                     # Se crea automáticamente
```

### 3. Instalar Dependencias
```bash
# Instalar dependencias Node.js
npm install

# Instalar dependencias específicas para desarrollo
npm install --save-dev @types/node

# Verificar instalación
npm list --depth=0
```

### 4. Configurar HTTPS Local (Obligatorio para WebAR)
```bash
# Instalar mkcert (Windows - usando Chocolatey)
choco install mkcert

# Instalar mkcert (macOS - usando Homebrew) 
brew install mkcert

# Instalar mkcert (Linux - Ubuntu/Debian)
sudo apt install mkcert

# Configurar certificados locales
mkdir certs
mkcert -install
mkcert -key-file certs/localhost-key.pem -cert-file certs/localhost.pem localhost 127.0.0.1 ::1
```

### 5. Ejecutar Aplicación
```bash
# Iniciar servidor de desarrollo (frontend)
npm run dev

# En otra terminal, iniciar servidor backend
npm run serve

# O ejecutar ambos simultáneamente
npm install concurrently --save-dev
# Agregar a package.json scripts: "start": "concurrently \"npm run dev\" \"npm run serve\""
npm start
```

### 6. Acceder a la Aplicación
- **Frontend**: https://localhost:3000
- **API Backend**: http://localhost:3001
- **Health Check**: http://localhost:3001/api/health

## 🔧 Configuración en Cursor

### 1. Abrir en Cursor
```bash
# Abrir proyecto en Cursor
cursor .
```

### 2. Extensiones Recomendadas para Cursor
Instalar estas extensiones desde el marketplace:
- **ES6 String HTML** - Sintaxis highlighting para HTML en strings
- **Auto Rename Tag** - Renombrado automático de tags HTML
- **Live Server** - Servidor de desarrollo (alternativa)
- **Thunder Client** - Cliente REST para probar APIs
- **GitLens** - Herramientas Git avanzadas

### 3. Configurar Workspace
Crear `.vscode/settings.json`:
```json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "javascript.preferences.importModuleSpecifier": "relative",
  "emmet.includeLanguages": {
    "javascript": "html"
  },
  "files.associations": {
    "*.js": "javascript"
  },
  "liveServer.settings.port": 3000,
  "liveServer.settings.https": {
    "enable": true,
    "cert": "./certs/localhost.pem",
    "key": "./certs/localhost-key.pem"
  }
}
```

### 4. Configurar Debugging
Crear `.vscode/launch.json`:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Server",
      "skipFiles": ["<node_internals>/**"],
      "program": "${workspaceFolder}/server.js",
      "env": {
        "NODE_ENV": "development"
      }
    }
  ]
}
```

## 🚦 Scripts de NPM

```bash
# Desarrollo
npm run dev          # Servidor frontend (Vite) en https://localhost:3000
npm run serve        # Servidor backend (Express) en http://localhost:3001

# Build para producción
npm run build        # Construir aplicación web
npm run preview      # Preview del build de producción

# Android
npm run android:add  # Agregar plataforma Android
npm run android:sync # Sincronizar archivos con Android
npm run android:open # Abrir en Android Studio
npm run android:build # Build completo + APK

# Utilidades
npm run install-deps # Instalar todas las dependencias
```

## 🧪 Flujo de Desarrollo

### 1. Desarrollo Frontend
```bash
# Terminal 1: Servidor de desarrollo
npm run dev

# Terminal 2: Servidor backend  
npm run serve

# La aplicación se recarga automáticamente al hacer cambios
```

### 2. Probar Funcionalidades
1. **Navegador**: Ir a https://localhost:3000
2. **Generar Marcador**: Subir imagen JPG + modelo 3D
3. **Editor 3D**: Posicionar modelo sobre marcador
4. **Verificar AR**: Usar cámara para probar AR
5. **Generar APK**: Crear aplicación Android

### 3. Desarrollo Backend
```bash
# Probar API endpoints
curl http://localhost:3001/api/health

# Ver logs del servidor
# Los logs aparecen automáticamente en la consola
```

## 📱 Generación de APK

### Prerrequisitos Adicionales
```bash
# Verificar Java JDK
java -version

# Verificar Android SDK (después de instalar Android Studio)
echo $ANDROID_HOME
# Debe mostrar la ruta del SDK

# Configurar variables de entorno (Windows)
setx ANDROID_HOME "C:\Users\[USER]\AppData\Local\Android\Sdk"
setx PATH "%PATH%;%ANDROID_HOME%\tools;%ANDROID_HOME%\platform-tools"

# Configurar variables de entorno (macOS/Linux)
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### Proceso de Build
```bash
# 1. Construir aplicación web
npm run build

# 2. Agregar plataforma Android (solo primera vez)
npm run android:add

# 3. Sincronizar archivos
npm run android:sync

# 4. Abrir en Android Studio (para build manual)
npm run android:open

# 5. O build automático completo
npm run android:build
```

## 🔍 Estructura de Archivos Detallada

```
webAR-app/
├── 📄 package.json              # Dependencias y scripts
├── 📄 capacitor.config.ts       # Configuración Capacitor
├── 📄 vite.config.js           # Configuración Vite
├── 📄 server.js                # Servidor Express backend
├── 📄 index.html               # Página principal
├── 📁 pages/                   # Páginas de la aplicación
│   ├── marker-generator.html   # Generador de marcadores
│   ├── 3d-editor.html         # Editor 3D
│   ├── ar-verification.html   # Verificación AR
│   └── apk-builder.html       # Constructor APK
├── 📁 js/                      # Lógica JavaScript
│   ├── marker-generator.js    # Lógica generador marcadores
│   ├── 3d-editor.js          # Lógica editor 3D
│   ├── ar-verification.js    # Lógica verificación AR
│   └── apk-builder.js        # Lógica constructor APK
├── 📁 css/                     # Estilos
│   ├── styles.css            # Estilos principales
│   └── components.css        # Componentes UI
├── 📁 assets/                  # Recursos estáticos
│   ├── models/               # Modelos 3D de ejemplo
│   ├── markers/              # Marcadores de ejemplo
│   └── images/               # Imágenes e iconos
├── 📁 temp/                    # Archivos temporales (generado)
├── 📁 dist/                    # Build de producción (generado)
├── 📁 android/                 # Proyecto Android (generado)
├── 📁 node_modules/           # Dependencias NPM
└── 📁 certs/                  # Certificados SSL locales
```

## 🐛 Solución de Problemas

### Error: "Camera not accessible"
```bash
# Solución: Asegurar HTTPS
# 1. Verificar certificados SSL
ls -la certs/
# 2. Acceder vía https://localhost:3000 (no http://)
# 3. Aceptar certificado en el navegador
```

### Error: "Module not found"
```bash
# Limpiar caché y reinstalar
rm -rf node_modules package-lock.json
npm install
```

### Error: "Android SDK not found"
```bash
# Verificar variables de entorno
echo $ANDROID_HOME          # macOS/Linux
echo %ANDROID_HOME%         # Windows

# Instalar Android Studio si no está instalado
# https://developer.android.com/studio
```

### Error: "Port 3000 already in use"
```bash
# Cambiar puerto en vite.config.js
# O matar proceso
npx kill-port 3000
```

### Error: "Sharp module not found"
```bash
# Instalar Sharp para procesamiento de imágenes
npm install sharp --save-optional
```

## 📚 Tecnologías Utilizadas

| Tecnología | Versión | Propósito |
|------------|---------|-----------|
| **Node.js** | 16+ | Runtime JavaScript |
| **Express.js** | 4.18.2 | Servidor backend |
| **Vite** | 4.4.9 | Build tool y dev server |
| **Three.js** | 0.157.0 | Renderizado 3D |
| **AR.js** | 3.4.0+ | Funcionalidad AR |
| **A-Frame** | 1.4.0 | Framework VR/AR |
| **Capacitor** | 5.5.1 | Web-to-native wrapper |
| **Multer** | 1.4.5 | Upload de archivos |

## 🎯 Roadmap de Desarrollo

### Fase 1: Core (Completa) ✅
- [x] Generador de marcadores básico
- [x] Upload de archivos
- [x] Estructura de navegación
- [x] Configuración de proyecto

### Fase 2: Editor 3D (En desarrollo)
- [ ] Controles de transformación interactivos
- [ ] Preview en tiempo real
- [ ] Guardado de configuración

### Fase 3: Verificación AR (Planeada)
- [ ] Integración AR.js + A-Frame
- [ ] Detección de marcadores
- [ ] Captura de screenshots

### Fase 4: Generador APK (Planeada)
- [ ] Build automatizado con Capacitor
- [ ] Personalización de APK
- [ ] Firma digital

## 🤝 Contribución

1. Fork del repositorio
2. Crear branch para features: `git checkout -b feature/nueva-funcionalidad`
3. Commit cambios: `git commit -am 'Agregar nueva funcionalidad'`
4. Push al branch: `git push origin feature/nueva-funcionalidad`
5. Crear Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver archivo [LICENSE](LICENSE) para detalles.

## 🆘 Soporte

- **Issues**: Reportar bugs en GitHub Issues
- **Documentación**: Wiki del proyecto
- **Comunidad**: Discussions en GitHub

---

**¡Feliz desarrollo de WebAR! 🚀📱**