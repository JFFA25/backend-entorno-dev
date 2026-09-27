require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { Pool } = require('pg');
const mongoose = require('mongoose');

const app = express();
const PORT = process.env.PORT || 8000;

// Middlewares
app.use(cors());
app.use(express.json());

// 1. Configurar conexión a PostgreSQL
const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});

// 2. Configurar conexión a MongoDB
mongoose.connect(process.env.MONGO_URL)
  .then(() => console.log('MongoDB: Conexión establecida de forma inicial.'))
  .catch(err => console.error('MongoDB: Error inicial de conexión:', err.message));

// Ruta Base
app.get('/', (req, res) => {
  res.json({ status: 'online', message: 'Backend funcionando con Node/Express' });
});

// Ruta de diagnóstico (Healthcheck)
app.get('/healthcheck', async (req, res) => {
  const healthStatus = {};

  // Verificar PostgreSQL
  try {
    await pool.query('SELECT 1');
    healthStatus.postgres = 'Connected';
  } catch (err) {
    healthStatus.postgres = `Disconnected: ${err.message}`;
  }

  // Verificar MongoDB
  try {
    // 1 es conectado, 2 es conectando, 0 es desconectado
    const state = mongoose.connection.readyState;
    healthStatus.mongodb = state === 1 ? 'Connected' : `Disconnected (State: ${state})`;
  } catch (err) {
    healthStatus.mongodb = `Disconnected: ${err.message}`;
  }

  res.json(healthStatus);
});

// Arrancar el Servidor
app.listen(PORT, () => {
  console.log(`Servidor Express corriendo en http://localhost:${PORT}`);
});
