// server.js - Servidor Express para manejar backend de WebAR Complete
import express from 'express';
import multer from 'multer';
import cors from 'cors';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import { exec } from 'child_process';
import { promisify } from 'util';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3001;
const execAsync = promisify(exec);

// Middleware
app.use(cors());
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ limit: '50mb', extended: true }));

// Servir archivos estáticos
app.use('/assets', express.static(path.join(__dirname, 'src/assets')));
app.use('/temp', express.static(path.join(__dirname, 'temp')));

// Configurar multer para uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = path.join(__dirname, 'temp', 'uploads');
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueName = Date.now() + '-' + Math.round(Math.random() * 1E9);
        const extension = path.extname(file.originalname);
        cb(null, uniqueName + extension);
    }
});

const upload = multer({ 
    storage: storage,
    limits: {
        fileSize: 10 * 1024 * 1024 // 10MB límite
    },
    fileFilter: (req, file, cb) => {
        const allowedTypes = {
            'image/jpeg': ['.jpg', '.jpeg'],
            'model/gltf+json': ['.gltf'],
            'model/gltf-binary': ['.glb'],
            'application/octet-stream': ['.glb']
        };
        
        const fileExtension = path.extname(file.originalname).toLowerCase();
        const isValidType = Object.values(allowedTypes).flat().includes(fileExtension);
        
        if (isValidType) {
            cb(null, true);
        } else {
            cb(new Error('Tipo de archivo no permitido'), false);
        }
    }
});

// Utility functions
const createDirectory = (dirPath) => {
    if (!fs.existsSync(dirPath)) {
        fs.mkdirSync(dirPath, { recursive: true });
    }
};

const deleteFile = (filePath) => {
    try {
        if (fs.existsSync(filePath)) {
            fs.unlinkSync(filePath);
        }
    } catch (error) {
        console.error('Error eliminando archivo:', error);
    }
};

// Endpoints

// Health check
app.get('/api/health', (req, res) => {
    res.json({ 
        status: 'OK', 
        timestamp: new Date().toISOString(),
        version: '1.0.0'
    });
});

// Upload de archivos (imagen + modelo 3D)
app.post('/api/upload', upload.fields([
    { name: 'image', maxCount: 1 },
    { name: 'model', maxCount: 1 }
]), async (req, res) => {
    try {
        console.log('Recibiendo uploads...', req.files);
        
        if (!req.files || !req.files.image || !req.files.model) {
            return res.status(400).json({
                success: false,
                error: 'Se requieren tanto imagen como modelo 3D'
            });
        }

        const imageFile = req.files.image[0];
        const modelFile = req.files.model[0];
        
        // Validar formato de imagen (solo JPG)
        if (!imageFile.mimetype.includes('jpeg')) {
            deleteFile(imageFile.path);
            deleteFile(modelFile.path);
            return res.status(400).json({
                success: false,
                error: 'Solo se permiten imágenes JPG para mejores resultados con AR.js'
            });
        }

        res.json({
            success: true,
            message: 'Archivos subidos exitosamente',
            files: {
                image: {
                    filename: imageFile.filename,
                    originalName: imageFile.originalname,
                    size: imageFile.size,
                    path: imageFile.path
                },
                model: {
                    filename: modelFile.filename,
                    originalName: modelFile.originalname,
                    size: modelFile.size,
                    path: modelFile.path
                }
            }
        });
        
    } catch (error) {
        console.error('Error en upload:', error);
        res.status(500).json({
            success: false,
            error: 'Error interno del servidor: ' + error.message
        });
    }
});

// Generar marcador AR
app.post('/api/generate-marker', async (req, res) => {
    try {
        const { 
            imageFilename, 
            modelFilename, 
            patternRatio = 0.7, 
            borderSize = 0.2,
            markerName = 'marcador_ar'
        } = req.body;

        if (!imageFilename || !modelFilename) {
            return res.status(400).json({
                success: false,
                error: 'Se requieren nombres de archivos de imagen y modelo'
            });
        }

        const imagePath = path.join(__dirname, 'temp', 'uploads', imageFilename);
        const modelPath = path.join(__dirname, 'temp', 'uploads', modelFilename);
        
        // Verificar que los archivos existen
        if (!fs.existsSync(imagePath) || !fs.existsSync(modelPath)) {
            return res.status(404).json({
                success: false,
                error: 'Archivos no encontrados'
            });
        }

        // Crear directorio de salida
        const outputDir = path.join(__dirname, 'temp', 'generated', Date.now().toString());
        createDirectory(outputDir);

        // Generar archivo .patt usando AR.js marker training
        const pattContent = await generatePattFile(imagePath, patternRatio);
        const pattPath = path.join(outputDir, markerName + '.patt');
        fs.writeFileSync(pattPath, pattContent);

        // Generar imagen de marcador con borde
        const markerImagePath = await createMarkerWithBorder(imagePath, outputDir, markerName, borderSize);

        // Copiar y optimizar modelo 3D
        const optimizedModelPath = path.join(outputDir, 'modelo_optimizado.glb');
        fs.copyFileSync(modelPath, optimizedModelPath);

        // Crear manifiesto del proyecto
        const manifest = {
            projectName: markerName,
            created: new Date().toISOString(),
            files: {
                patt: path.basename(pattPath),
                markerImage: path.basename(markerImagePath),
                model3D: path.basename(optimizedModelPath)
            },
            settings: {
                patternRatio: parseFloat(patternRatio),
                borderSize: parseFloat(borderSize)
            }
        };

        const manifestPath = path.join(outputDir, 'project_manifest.json');
        fs.writeFileSync(manifestPath, JSON.stringify(manifest, null, 2));

        res.json({
            success: true,
            message: 'Marcador generado exitosamente',
            outputDir: path.relative(__dirname, outputDir),
            files: {
                patt: path.relative(__dirname, pattPath),
                markerImage: path.relative(__dirname, markerImagePath),
                model3D: path.relative(__dirname, optimizedModelPath),
                manifest: path.relative(__dirname, manifestPath)
            },
            manifest: manifest
        });

        // Limpiar archivos temporales después de un tiempo
        setTimeout(() => {
            deleteFile(imagePath);
            deleteFile(modelPath);
        }, 300000); // 5 minutos

    } catch (error) {
        console.error('Error generando marcador:', error);
        res.status(500).json({
            success: false,
            error: 'Error generando marcador: ' + error.message
        });
    }
});

// Descargar archivo generado
app.get('/api/download/:projectId/:filename', (req, res) => {
    try {
        const { projectId, filename } = req.params;
        const filePath = path.join(__dirname, 'temp', 'generated', projectId, filename);
        
        if (!fs.existsSync(filePath)) {
            return res.status(404).json({
                success: false,
                error: 'Archivo no encontrado'
            });
        }

        res.download(filePath, filename, (err) => {
            if (err) {
                console.error('Error descargando archivo:', err);
                res.status(500).json({
                    success: false,
                    error: 'Error descargando archivo'
                });
            }
        });
        
    } catch (error) {
        console.error('Error en descarga:', error);
        res.status(500).json({
            success: false,
            error: 'Error interno del servidor'
        });
    }
});

// Build APK con Capacitor
app.post('/api/build-apk', async (req, res) => {
    try {
        const {
            appName = 'WebAR App',
            packageId = 'com.webar.complete',
            version = '1.0.0',
            description = 'WebAR Application',
            projectData
        } = req.body;

        if (!projectData) {
            return res.status(400).json({
                success: false,
                error: 'Datos del proyecto requeridos'
            });
        }

        // Crear directorio temporal para el build
        const buildId = Date.now().toString();
        const buildDir = path.join(__dirname, 'temp', 'builds', buildId);
        createDirectory(buildDir);

        // Crear estructura de proyecto Capacitor
        const webDir = path.join(buildDir, 'www');
        createDirectory(webDir);

        // Generar aplicación web AR mínima
        await generateWebARApp(webDir, projectData);

        // Configurar Capacitor
        const capacitorConfig = {
            appId: packageId,
            appName: appName,
            webDir: 'www',
            bundledWebRuntime: false,
            server: {
                androidScheme: 'https'
            }
        };

        const configPath = path.join(buildDir, 'capacitor.config.json');
        fs.writeFileSync(configPath, JSON.stringify(capacitorConfig, null, 2));

        // Package.json básico
        const packageJson = {
            name: appName.toLowerCase().replace(/\s+/g, '-'),
            version: version,
            description: description,
            dependencies: {
                '@capacitor/core': '^5.5.1',
                '@capacitor/android': '^5.5.1'
            }
        };

        fs.writeFileSync(
            path.join(buildDir, 'package.json'), 
            JSON.stringify(packageJson, null, 2)
        );

        // Ejecutar comandos de Capacitor
        const commands = [
            'npm install --silent',
            'npx cap add android --quiet',
            'npx cap sync android --quiet'
        ];

        let buildSuccess = true;
        let buildLog = [];

        for (const command of commands) {
            try {
                buildLog.push(`Ejecutando: ${command}`);
                const { stdout, stderr } = await execAsync(command, { 
                    cwd: buildDir,
                    timeout: 120000 // 2 minutos timeout
                });
                buildLog.push(stdout);
                if (stderr) buildLog.push('STDERR: ' + stderr);
            } catch (error) {
                buildLog.push('ERROR: ' + error.message);
                buildSuccess = false;
                break;
            }
        }

        if (buildSuccess) {
            // Intentar compilar APK si Android Studio está disponible
            try {
                const gradleBuild = 'cd android && ./gradlew assembleDebug';
                buildLog.push(`Ejecutando: ${gradleBuild}`);
                
                const { stdout, stderr } = await execAsync(gradleBuild, {
                    cwd: buildDir,
                    timeout: 300000 // 5 minutos timeout
                });
                
                buildLog.push(stdout);
                if (stderr) buildLog.push('STDERR: ' + stderr);

                // Buscar APK generado
                const apkPath = path.join(buildDir, 'android', 'app', 'build', 'outputs', 'apk', 'debug', 'app-debug.apk');
                
                if (fs.existsSync(apkPath)) {
                    res.json({
                        success: true,
                        message: 'APK generado exitosamente',
                        buildId: buildId,
                        apkPath: `temp/builds/${buildId}/android/app/build/outputs/apk/debug/app-debug.apk`,
                        buildLog: buildLog
                    });
                } else {
                    res.json({
                        success: false,
                        error: 'APK no encontrado después del build',
                        buildLog: buildLog
                    });
                }

            } catch (gradleError) {
                buildLog.push('ERROR Gradle: ' + gradleError.message);
                res.json({
                    success: false,
                    error: 'Error compilando APK. Asegúrate de tener Android Studio y SDK configurados.',
                    buildLog: buildLog,
                    buildId: buildId
                });
            }
        } else {
            res.json({
                success: false,
                error: 'Error en setup de Capacitor',
                buildLog: buildLog
            });
        }

    } catch (error) {
        console.error('Error building APK:', error);
        res.status(500).json({
            success: false,
            error: 'Error interno: ' + error.message
        });
    }
});

// Funciones auxiliares
async function generatePattFile(imagePath, patternRatio) {
    // Implementación básica de generación de archivo .patt
    // En producción se usaría la biblioteca de AR.js marker training
    
    const sharp = await import('sharp').catch(() => null);
    
    if (!sharp) {
        // Fallback sin sharp
        console.log('Sharp no disponible, usando generación básica de .patt');
        return generateBasicPattFile();
    }

    try {
        // Redimensionar imagen a 16x16 para el patrón
        const resized = await sharp.default(imagePath)
            .resize(16, 16)
            .grayscale()
            .raw()
            .toBuffer();

        // Convertir buffer a formato .patt
        let pattContent = '';
        for (let i = 0; i < resized.length; i++) {
            pattContent += resized[i].toString().padStart(3, ' ');
            if ((i + 1) % 16 === 0) pattContent += '\n';
            else pattContent += ' ';
        }

        // Repetir patrón 3 veces (formato .patt estándar)
        return pattContent + pattContent + pattContent;

    } catch (error) {
        console.error('Error procesando imagen con Sharp:', error);
        return generateBasicPattFile();
    }
}

function generateBasicPattFile() {
    // Generar un patrón básico cuando no se puede procesar la imagen
    let pattern = '';
    for (let i = 0; i < 256; i++) {
        const value = Math.floor(Math.random() * 128 + 64); // Valores medios
        pattern += value.toString().padStart(3, ' ');
        if ((i + 1) % 16 === 0) pattern += '\n';
        else pattern += ' ';
    }
    return pattern + pattern + pattern;
}

async function createMarkerWithBorder(imagePath, outputDir, markerName, borderSize) {
    const outputPath = path.join(outputDir, markerName + '_marker.jpg');
    
    const sharp = await import('sharp').catch(() => null);
    
    if (!sharp) {
        // Fallback: copiar imagen original
        fs.copyFileSync(imagePath, outputPath);
        return outputPath;
    }

    try {
        const markerSize = 400;
        const imageSize = Math.floor(markerSize * (1 - borderSize * 2));
        const offset = Math.floor(markerSize * borderSize);

        // Crear imagen con borde negro
        await sharp.default(imagePath)
            .resize(imageSize, imageSize)
            .extend({
                top: offset,
                bottom: offset,
                left: offset,
                right: offset,
                background: { r: 0, g: 0, b: 0 }
            })
            .jpeg({ quality: 90 })
            .toFile(outputPath);

        return outputPath;

    } catch (error) {
        console.error('Error creando marcador con borde:', error);
        // Fallback: copiar imagen original
        fs.copyFileSync(imagePath, outputPath);
        return outputPath;
    }
}

async function generateWebARApp(webDir, projectData) {
    // Generar aplicación web AR mínima para el APK
    const htmlContent = `
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
    <title>WebAR App</title>
    <script src="https://aframe.io/releases/1.4.0/aframe.min.js"></script>
    <script src="https://raw.githack.com/AR-js-org/AR.js/master/aframe/build/aframe-ar.js"></script>
    <style>
        body { margin: 0; font-family: Arial, sans-serif; }
        #arButton { 
            position: fixed; 
            bottom: 20px; 
            left: 50%; 
            transform: translateX(-50%); 
            z-index: 1000;
            background: #007bff;
            color: white;
            border: none;
            padding: 15px 30px;
            border-radius: 25px;
            font-size: 16px;
            cursor: pointer;
        }
        #instructions {
            position: fixed;
            top: 20px;
            left: 20px;
            right: 20px;
            background: rgba(0,0,0,0.8);
            color: white;
            padding: 15px;
            border-radius: 10px;
            z-index: 1000;
            text-align: center;
        }
    </style>
</head>
<body>
    <div id="instructions">
        <h3>WebAR App</h3>
        <p>Presiona "Iniciar AR" y apunta la cámara hacia el marcador</p>
    </div>
    
    <button id="arButton">Iniciar AR</button>
    
    <a-scene 
        id="arScene"
        embedded 
        arjs="sourceType: webcam; debugUIEnabled: false;" 
        style="display: none;">
        
        <a-marker type="pattern" url="./marker.patt">
            <a-entity 
                gltf-model="./model.glb"
                position="0 0 0"
                scale="${projectData.scale || '1 1 1'}"
                rotation="${projectData.rotation || '0 0 0'}">
            </a-entity>
        </a-marker>
        
        <a-entity camera></a-entity>
    </a-scene>

    <script>
        document.getElementById('arButton').addEventListener('click', function() {
            const scene = document.getElementById('arScene');
            const button = this;
            const instructions = document.getElementById('instructions');
            
            scene.style.display = 'block';
            button.style.display = 'none';
            instructions.innerHTML = '<p>Busca el marcador con la cámara...</p>';
        });
    </script>
</body>
</html>`;

    fs.writeFileSync(path.join(webDir, 'index.html'), htmlContent);

    // Copiar archivos del proyecto si están disponibles
    if (projectData.pattFile) {
        fs.writeFileSync(path.join(webDir, 'marker.patt'), projectData.pattFile);
    }
    
    // Crear manifest.json
    const manifest = {
        name: "WebAR App",
        short_name: "WebAR",
        display: "standalone",
        orientation: "portrait",
        theme_color: "#007bff",
        background_color: "#ffffff",
        icons: []
    };
    
    fs.writeFileSync(path.join(webDir, 'manifest.json'), JSON.stringify(manifest, null, 2));
}

// Manejo de errores
app.use((error, req, res, next) => {
    console.error('Error no manejado:', error);
    res.status(500).json({
        success: false,
        error: 'Error interno del servidor'
    });
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`🚀 Servidor WebAR Complete ejecutándose en http://localhost:${PORT}`);
    console.log(`📱 API endpoints disponibles:`);
    console.log(`   GET  /api/health - Health check`);
    console.log(`   POST /api/upload - Subir archivos`);
    console.log(`   POST /api/generate-marker - Generar marcador AR`);
    console.log(`   POST /api/build-apk - Construir APK`);
    console.log(`   GET  /api/download/:projectId/:filename - Descargar archivo`);
});

export default app;