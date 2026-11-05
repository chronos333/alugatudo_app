const path = require('path');
require('dotenv').config({ path: path.resolve(__dirname, '../.env') });

module.exports = {
  PORT: process.env.PORT || 3000,
  NODE_ENV: process.env.NODE_ENV || 'development',
  JWT_SECRET: process.env.JWT_SECRET || 'alugatudo_fallback_secret_key_change_in_prod',
  DB_PATH: process.env.DB_PATH || path.resolve(__dirname, '../database/alugatudo.sqlite'),
  API_PREFIX: process.env.API_PREFIX || '/api/v1'
};

