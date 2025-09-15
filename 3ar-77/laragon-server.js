import express from 'express';
import multer from 'multer';
import path from 'path';
import fs from 'fs';
import cors from 'cors';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = 3001;

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// Configurar multer para uploads
const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        const uploadDir = 'uploads/';
        if (!fs.existsSync(uploadDir)) {
            fs.mkdirSync(uploadDir, { recursive: true });
        }
        cb(null, uploadDir);
    },
    filename: (req, file, cb) => {
        const uniqueSuffix = Date.now() + '-' + Math.round(Math.random() * 1E9);
        cb(null, file.fieldname + '-' + uniqueSuffix + path.extname(file.originalname));
    }
});

const upload = multer({ 
    storage: storage,
    limits: { fileSize: 50 * 1024 * 1024 }, // 50MB
    fileFilter: (req, file, cb) => {
        const allowedTypes = /jpeg|jpg|png|gif|gltf|glb|obj|fbx|image\/|model\/|application\/octet-stream/;
        const extname = allowedTypes.test(path.extname(file.originalname).toLowerCase());
        const mimetype = allowedTypes.test(file.mimetype);
        
        // Permitir archivos de imagen y modelos 3D
        if (mimetype || extname) {
            return cb(null, true);
        } else {
            console.log(`Archivo rechazado: ${file.originalname}, tipo: ${file.mimetype}`);
            cb(new Error('Tipo de archivo no permitido'));
        }
    }
});

// Rutas API
app.get('/api/health', (req, res) => {
    res.json({
        status: 'OK',
        message: 'Laragon Backend funcionando',
        timestamp: new Date().toISOString(),
        services: {
            upload: 'OK',
            build: 'OK',
            ar: 'OK'
        }
    });
});

app.post('/api/upload', upload.single('file'), (req, res) => {
    try {
        if (!req.file) {
            return res.status(400).json({ error: 'No se subió ningún archivo' });
        }

        const fileInfo = {
            filename: req.file.filename,
            originalname: req.file.originalname,
            size: req.file.size,
            path: req.file.path,
            url: `/uploads/${req.file.filename}`,
            type: req.file.mimetype
        };

        res.json({
            success: true,
            message: 'Archivo subido exitosamente',
            file: fileInfo
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.post('/api/build', async (req, res) => {
    try {
        const { projectName, packageName, version } = req.body;
        
        // Simular proceso de build
        const buildId = Date.now();
        const buildInfo = {
            id: buildId,
            projectName: projectName || 'WebAR-App',
            packageName: packageName || 'com.webar.app',
            version: version || '1.0.0',
            status: 'building',
            progress: 0,
            timestamp: new Date().toISOString()
        };

        // Simular progreso de build
        setTimeout(() => {
            buildInfo.progress = 25;
            buildInfo.status = 'compiling';
        }, 1000);

        setTimeout(() => {
            buildInfo.progress = 50;
            buildInfo.status = 'optimizing';
        }, 2000);

        setTimeout(() => {
            buildInfo.progress = 75;
            buildInfo.status = 'signing';
        }, 3000);

        setTimeout(() => {
            buildInfo.progress = 100;
            buildInfo.status = 'completed';
            buildInfo.downloadUrl = `/downloads/app-${buildId}.apk`;
        }, 4000);

        res.json({
            success: true,
            message: 'Build iniciado',
            build: buildInfo
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

app.get('/api/build/:id', (req, res) => {
    const buildId = req.params.id;
    // Simular estado del build
    res.json({
        id: buildId,
        status: 'completed',
        progress: 100,
        downloadUrl: `/downloads/app-${buildId}.apk`
    });
});

app.get('/api/projects', (req, res) => {
    res.json({
        projects: [
            {
                id: 1,
                name: 'WebAR Demo',
                status: 'active',
                lastModified: new Date().toISOString()
            }
        ]
    });
});

// API para limpiar archivos del servidor
app.post('/api/clear-files', (req, res) => {
    try {
        const uploadDir = 'uploads/';
        
        if (fs.existsSync(uploadDir)) {
            // Limpiar archivos en uploads
            const files = fs.readdirSync(uploadDir);
            files.forEach(file => {
                const filePath = path.join(uploadDir, file);
                if (fs.statSync(filePath).isFile()) {
                    fs.unlinkSync(filePath);
                }
            });
        }
        
        res.json({
            success: true,
            message: 'Archivos del servidor limpiados exitosamente'
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// API para limpiar archivos del proyecto
app.post('/api/clear-project', (req, res) => {
    try {
        const { files } = req.body;
        const cleanedFiles = [];
        
        files.forEach(filePath => {
            try {
                if (fs.existsSync(filePath)) {
                    if (fs.statSync(filePath).isDirectory()) {
                        // Limpiar directorio
                        const files = fs.readdirSync(filePath);
                        files.forEach(file => {
                            const fullPath = path.join(filePath, file);
                            if (fs.statSync(fullPath).isFile()) {
                                fs.unlinkSync(fullPath);
                            }
                        });
                    } else {
                        // Eliminar archivo
                        fs.unlinkSync(filePath);
                    }
                    cleanedFiles.push(filePath);
                }
            } catch (error) {
                console.warn(`No se pudo limpiar ${filePath}:`, error.message);
            }
        });
        
        res.json({
            success: true,
            message: 'Archivos del proyecto limpiados exitosamente',
            cleanedFiles: cleanedFiles
        });
    } catch (error) {
        res.status(500).json({
            success: false,
            error: error.message
        });
    }
});

// Servir archivos estáticos
app.use('/uploads', express.static('uploads'));

// Ruta principal
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'dashboard.html'));
});

// Iniciar servidor
app.listen(PORT, () => {
    console.log(`🚀 Laragon Backend funcionando en http://localhost:${PORT}`);
    console.log(`📱 Dashboard: http://localhost/3ar-77/dashboard.html`);
    console.log(`🔧 API Backend: http://localhost:${PORT}/api`);
});

export default app;
