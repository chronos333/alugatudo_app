const express = require('express');
const cors = require('cors');
const path = require('path');
const config = require('./config/env');
const db = require('./database/db');
const seedDatabase = require('./database/seed');
const apiRoutes = require('./routes');
const errorHandler = require('./middlewares/errorHandler');

const app = express();

// Middlewares essenciais
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Servir frontend web estático diretamente de public/
app.use(express.static(path.join(__dirname, 'public')));

// Rotas da API REST
app.use(config.API_PREFIX, apiRoutes);

// Fallback para SPA (Single Page Application)
app.get('*', (req, res, next) => {
  if (req.path.startsWith('/api')) {
    return next();
  }
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Middleware centralizado de tratamento de erros
app.use(errorHandler);

// Inicialização do servidor com verificação de banco de dados
async function startServer() {
  try {
    await db.init();
    console.log('✅ Banco de dados relacional SQLite inicializado com sucesso.');

    // Verifica se precisa semear dados iniciais
    const userCount = db.get('SELECT COUNT(*) as count FROM users');
    if (!userCount || userCount.count === 0) {
      await seedDatabase();
    }

    app.listen(config.PORT, () => {
      console.log('====================================================');
      console.log(`🚀 ALUGA TUDO — SERVIDOR FULL STACK ATIVO`);
      console.log(`📡 API REST: http://localhost:${config.PORT}${config.API_PREFIX}`);
      console.log(`🌐 PORTAL WEB: http://localhost:${config.PORT}`);
      console.log('====================================================');
    });
  } catch (err) {
    console.error('❌ Falha crítica ao iniciar servidor:', err);
    process.exit(1);
  }
}

startServer();

