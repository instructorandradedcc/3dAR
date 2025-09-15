#!/bin/bash

# install.sh - Script de instalación automática para WebAR Complete
# Ejecutar con: bash install.sh

echo "🚀 Instalador Automático WebAR Complete v1.0"
echo "=============================================="
echo ""

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # Sin color

# Función para imprimir mensajes con colores
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar Node.js
print_status "Verificando Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js encontrado: $NODE_VERSION"
    
    # Verificar versión mínima (v16)
    NODE_MAJOR=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$NODE_MAJOR" -lt 16 ]; then
        print_error "Node.js versión 16+ requerida. Tu versión: $NODE_VERSION"
        echo "Por favor actualiza Node.js desde https://nodejs.org/"
        exit 1
    fi
else
    print_error "Node.js no encontrado. Por favor instala Node.js 16+ desde https://nodejs.org/"
    exit 1
fi

# Verificar NPM
print_status "Verificando NPM..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "NPM encontrado: v$NPM_VERSION"
else
    print_error "NPM no encontrado. Instala NPM con Node.js"
    exit 1
fi

# Crear estructura de directorios
print_status "Creando estructura de directorios..."

# Crear directorios principales
mkdir -p pages
mkdir -p js
mkdir -p css
mkdir -p assets/{models,markers,images}
mkdir -p temp/{uploads,generated,builds}
mkdir -p certs
mkdir -p public

# Crear archivos vacíos que faltan
touch pages/3d-editor.html
touch pages/ar-verification.html  
touch pages/apk-builder.html
touch js/3d-editor.js
touch js/ar-verification.js
touch js/apk-builder.js
touch js/app.js
touch public/manifest.json

print_success "Estructura de directorios creada"

# Instalar dependencias
print_status "Instalando dependencias NPM..."
npm install --silent

if [ $? -eq 0 ]; then
    print_success "Dependencias instaladas correctamente"
else
    print_error "Error instalando dependencias"
    exit 1
fi

# Verificar/Instalar mkcert para HTTPS
print_status "Configurando certificados HTTPS..."
if command -v mkcert &> /dev/null; then
    print_success "mkcert encontrado"
    
    # Instalar CA root
    mkcert -install 2>/dev/null || true
    
    # Generar certificados para localhost
    mkcert -key-file certs/localhost-key.pem -cert-file certs/localhost.pem localhost 127.0.0.1 ::1 2>/dev/null
    
    if [ -f "certs/localhost.pem" ] && [ -f "certs/localhost-key.pem" ]; then
        print_success "Certificados SSL generados en ./certs/"
    else
        print_warning "Error generando certificados. Verifica instalación de mkcert"
    fi
else
    print_warning "mkcert no encontrado. Se necesita para HTTPS local"
    echo "Instala mkcert según tu sistema operativo:"
    echo "- Windows: choco install mkcert"
    echo "- macOS: brew install mkcert"  
    echo "- Linux: sudo apt install mkcert"
fi

# Crear archivo .env de configuración
print_status "Creando configuración del entorno..."
cat > .env << EOF
# WebAR Complete - Variables de Entorno
NODE_ENV=development
PORT=3001
FRONTEND_PORT=3000
HTTPS_ENABLED=true
UPLOAD_MAX_SIZE=10mb
TEMP_CLEANUP_HOURS=24
EOF

print_success "Archivo .env creado"

# Crear .gitignore
print_status "Creando .gitignore..."
cat > .gitignore << EOF
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
EOF

print_success ".gitignore creado"

# Crear scripts adicionales
print_status "Creando scripts de utilidad..."

# Script para limpiar archivos temporales
cat > clean.sh << 'EOF'
#!/bin/bash
echo "🧹 Limpiando archivos temporales..."
rm -rf temp/uploads/*
rm -rf temp/generated/*
rm -rf temp/builds/*
rm -rf node_modules/.cache
echo "✅ Limpieza completada"
EOF

chmod +x clean.sh

# Script para verificar dependencias
cat > check-deps.sh << 'EOF'
#!/bin/bash
echo "🔍 Verificando dependencias del sistema..."

echo "Node.js: $(node --version 2>/dev/null || echo 'NO INSTALADO')"
echo "NPM: v$(npm --version 2>/dev/null || echo 'NO INSTALADO')"
echo "Git: $(git --version 2>/dev/null || echo 'NO INSTALADO')"
echo "Java: $(java -version 2>&1 | head -n1 2>/dev/null || echo 'NO INSTALADO')"
echo "mkcert: $(mkcert -version 2>/dev/null || echo 'NO INSTALADO')"

echo ""
echo "📦 Verificando dependencias NPM..."
npm list --depth=0 2>/dev/null || echo "Ejecuta 'npm install' para instalar dependencias"

echo ""
echo "🔒 Verificando certificados SSL..."
if [ -f "certs/localhost.pem" ]; then
    echo "✅ Certificados SSL configurados"
else
    echo "❌ Certificados SSL no encontrados"
    echo "Ejecuta: mkcert -key-file certs/localhost-key.pem -cert-file certs/localhost.pem localhost 127.0.0.1 ::1"
fi
EOF

chmod +x check-deps.sh

print_success "Scripts de utilidad creados"

# Crear script de inicio rápido
cat > start.sh << 'EOF'
#!/bin/bash
echo "🚀 Iniciando WebAR Complete..."

# Verificar dependencias
if [ ! -d "node_modules" ]; then
    echo "📦 Instalando dependencias..."
    npm install
fi

# Verificar certificados
if [ ! -f "certs/localhost.pem" ]; then
    echo "🔒 Generando certificados SSL..."
    mkcert -key-file certs/localhost-key.pem -cert-file certs/localhost.pem localhost 127.0.0.1 ::1
fi

echo ""
echo "🌐 Iniciando servidores..."
echo "Frontend: https://localhost:3000"
echo "Backend:  http://localhost:3001"
echo ""
echo "Presiona Ctrl+C para detener"

# Iniciar ambos servidores
npx concurrently --names "FRONTEND,BACKEND" --prefix-colors "blue,green" \
    "npm run dev" \
    "npm run serve"
EOF

chmod +x start.sh

print_success "Script de inicio creado"

# Verificar instalación de Java (opcional para APK)
print_status "Verificando Java JDK (opcional para APK)..."
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n1)
    print_success "Java encontrado: $JAVA_VERSION"
else
    print_warning "Java JDK no encontrado. Necesario solo para generación de APK"
    echo "Instala OpenJDK desde https://adoptopenjdk.net/"
fi

# Instalar concurrently para ejecutar múltiples comandos
print_status "Instalando herramientas adicionales..."
npm install --save-dev concurrently &> /dev/null

print_success "Herramientas adicionales instaladas"

# Resumen final
echo ""
echo "======================================="
print_success "¡INSTALACIÓN COMPLETADA EXITOSAMENTE!"
echo "======================================="
echo ""
echo "📁 Proyecto: $(pwd)"
echo "🌐 Frontend: https://localhost:3000"
echo "🔧 Backend:  http://localhost:3001"
echo ""
echo "🚀 Para iniciar el proyecto:"
echo "   ./start.sh                  # Script automático"
echo "   npm run dev                 # Solo frontend"
echo "   npm run serve               # Solo backend"
echo ""
echo "🔍 Comandos útiles:"
echo "   ./check-deps.sh            # Verificar dependencias"
echo "   ./clean.sh                 # Limpiar archivos temporales"
echo "   npm run android:add        # Configurar Android (requiere Android Studio)"
echo ""
echo "📖 Documentación completa en README.md"
echo ""

# Verificar si todo está listo para ejecutar
if [ -f "package.json" ] && [ -d "node_modules" ]; then
    print_success "El proyecto está listo para ejecutar"
    echo ""
    echo "¿Quieres iniciar el servidor ahora? (y/n)"
    read -r response
    if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
        ./start.sh
    else
        echo "Puedes iniciar el servidor más tarde con: ./start.sh"
    fi
else
    print_warning "Hay problemas con la instalación. Revisa los mensajes anteriores."
fi