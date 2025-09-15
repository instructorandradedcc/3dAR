# 🧪 Guía de Prueba con Laragon

## 🚀 **Instrucciones para Probar Localmente**

### **1. Verificar que Laragon esté funcionando**
- ✅ Apache debe estar ejecutándose en puerto 80
- ✅ El proyecto debe estar en la carpeta `www` de Laragon

### **2. URLs de Prueba**

#### **Con Laragon (Apache):**
- **Test Laragon:** `http://localhost/3ar-77/test-laragon.html`
- **Página Principal:** `http://localhost/3ar-77/`
- **Test Completo:** `http://localhost/3ar-77/test.html`

#### **Con Servidor Estático (Node.js):**
- **Servidor Estático:** `http://localhost:3000/`
- **Test Laragon:** `http://localhost:3000/test-laragon.html`

### **3. Pasos de Prueba**

#### **Paso 1: Verificar Laragon**
1. Abrir `http://localhost/3ar-77/test-laragon.html`
2. Verificar que se carguen los estilos CSS
3. Verificar que JavaScript funcione
4. Verificar que LocalStorage funcione

#### **Paso 2: Probar Navegación**
1. Hacer clic en "Página Principal"
2. Verificar que cargue correctamente
3. Probar navegación entre páginas

#### **Paso 3: Probar Funcionalidades**
1. **Generador de Marcadores:**
   - Subir una imagen JPG
   - Subir un modelo 3D
   - Generar marcador
   - Verificar que se guarde en localStorage

2. **Editor 3D:**
   - Cargar proyecto del localStorage
   - Probar controles de transformación
   - Verificar que se guarden los cambios

3. **Verificación AR:**
   - Probar acceso a cámara
   - Verificar que se cargue A-Frame
   - Probar tracking de marcadores

4. **Constructor APK:**
   - Configurar metadatos de la app
   - Subir icono y splash screen
   - Verificar preview de configuración

### **4. Verificaciones Importantes**

#### **✅ Debe Funcionar:**
- Carga de archivos CSS y JS
- Navegación entre páginas
- Generación de marcadores (local)
- Editor 3D interactivo
- Verificación AR básica
- Guardado en localStorage
- Exportación de proyectos

#### **❌ No Funcionará (Esperado):**
- Upload de archivos al servidor
- APIs del backend
- Generación real de APK
- Almacenamiento en servidor

### **5. Solución de Problemas**

#### **Si no cargan los estilos:**
- Verificar que la carpeta `css/` exista
- Verificar que los archivos CSS estén en la ubicación correcta
- Verificar que Laragon esté sirviendo archivos estáticos

#### **Si no funciona JavaScript:**
- Verificar que la carpeta `js/` exista
- Verificar que los archivos JS estén en la ubicación correcta
- Verificar la consola del navegador para errores

#### **Si no funciona LocalStorage:**
- Verificar que el navegador soporte LocalStorage
- Verificar que no esté en modo incógnito
- Verificar que no haya bloqueadores de cookies

### **6. URLs de Acceso**

#### **Laragon (Apache):**
```
http://localhost/3ar-77/
http://localhost/3ar-77/test-laragon.html
http://localhost/3ar-77/test.html
http://localhost/3ar-77/pages/marker-generator.html
http://localhost/3ar-77/pages/3d-editor.html
http://localhost/3ar-77/pages/ar-verification.html
http://localhost/3ar-77/pages/apk-builder.html
```

#### **Servidor Estático (Node.js):**
```
http://localhost:3000/
http://localhost:3000/test-laragon.html
http://localhost:3000/test.html
http://localhost:3000/pages/marker-generator.html
http://localhost:3000/pages/3d-editor.html
http://localhost:3000/pages/ar-verification.html
http://localhost:3000/pages/apk-builder.html
```

### **7. Checklist de Prueba**

- [ ] Laragon Apache funcionando
- [ ] Archivos CSS cargando
- [ ] Archivos JS cargando
- [ ] Navegación funcionando
- [ ] Generador de marcadores funcionando
- [ ] Editor 3D funcionando
- [ ] Verificación AR funcionando
- [ ] Constructor APK funcionando
- [ ] LocalStorage funcionando
- [ ] Exportación de proyectos funcionando

### **8. Próximos Pasos**

Una vez que todo funcione localmente:

1. **Subir a GitHub**
2. **Conectar con Vercel/Netlify**
3. **Deploy automático**
4. **¡Disfrutar en producción!**

---

**🎯 Objetivo: Verificar que todo funcione perfectamente antes del deploy**


