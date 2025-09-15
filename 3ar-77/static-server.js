// static-server.js - Servidor estático simple para servidores gratuitos
import express from 'express';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const PORT = process.env.PORT || 3000;

// Servir archivos estáticos
app.use(express.static(__dirname));

// Manejar rutas SPA (Single Page Application)
app.get('*', (req, res) => {
    // Si es una ruta de API, devolver 404
    if (req.path.startsWith('/api/')) {
        return res.status(404).json({ error: 'API no disponible en modo estático' });
    }
    
    // Para todas las demás rutas, servir index.html
    res.sendFile(path.join(__dirname, 'index.html'));
});

app.listen(PORT, () => {
    console.log(`🚀 Servidor estático ejecutándose en http://localhost:${PORT}`);
    console.log(`📱 Modo: Estático (compatible con servidores gratuitos)`);
});

