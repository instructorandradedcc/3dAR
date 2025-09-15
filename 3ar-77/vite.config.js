import { defineConfig } from 'vite';
import { resolve } from 'path';
import fs from 'fs';
import path from 'path';

export default defineConfig({
  server: {
    host: '0.0.0.0',
    port: 3000,
    https: {
      key: fs.existsSync('./certs/localhost-key.pem') ? fs.readFileSync('./certs/localhost-key.pem') : undefined,
      cert: fs.existsSync('./certs/localhost.pem') ? fs.readFileSync('./certs/localhost.pem') : undefined,
    },
    cors: true,
    headers: {
      'Cross-Origin-Embedder-Policy': 'cross-origin',
      'Cross-Origin-Opener-Policy': 'same-origin'
    }
  },
  build: {
    outDir: 'dist',
    rollupOptions: {
      input: {
        main: resolve(__dirname, 'index.html'),
        'marker-generator': resolve(__dirname, 'pages/marker-generator.html'),
        '3d-editor': resolve(__dirname, 'pages/3d-editor.html'),
        'ar-verification': resolve(__dirname, 'pages/ar-verification.html'),
        'apk-builder': resolve(__dirname, 'pages/apk-builder.html')
      }
    }
  },
  optimizeDeps: {
    include: ['three', 'aframe']
  },
  define: {
    'process.env': {}
  }
});