const fs = require('fs');
const path = require('path');
const initSqlJs = require('sql.js');
const config = require('../config/env');

let dbInstance = null;
let SQL = null;
let isInitialized = false;
let initPromise = null;

function getDbPath() {
  return config.DB_PATH;
}

function saveDb() {
  if (!dbInstance) return;
  const dbPath = getDbPath();
  const dir = path.dirname(dbPath);
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
  const data = dbInstance.export();
  const buffer = Buffer.from(data);
  fs.writeFileSync(dbPath, buffer);
}

async function initDatabase() {
  if (isInitialized) return dbInstance;
  if (initPromise) return initPromise;

  initPromise = (async () => {
    SQL = await initSqlJs();
    const dbPath = getDbPath();
    if (fs.existsSync(dbPath)) {
      const fileBuffer = fs.readFileSync(dbPath);
      dbInstance = new SQL.Database(fileBuffer);
    } else {
      dbInstance = new SQL.Database();
    }

    // Executa schema inicial
    const schemaPath = path.join(__dirname, 'schema.sql');
    if (fs.existsSync(schemaPath)) {
      const schemaSql = fs.readFileSync(schemaPath, 'utf8');
      dbInstance.run(schemaSql);
      saveDb();
    }

    isInitialized = true;
    return dbInstance;
  })();

  return initPromise;
}

const dbWrapper = {
  init: initDatabase,

  run(sql, params = []) {
    if (!dbInstance) throw new Error('Database not initialized yet! Call await db.init()');
    dbInstance.run(sql, params);
    saveDb();
    return { success: true };
  },

  all(sql, params = []) {
    if (!dbInstance) throw new Error('Database not initialized yet! Call await db.init()');
    const stmt = dbInstance.prepare(sql);
    stmt.bind(params);
    const rows = [];
    while (stmt.step()) {
      rows.push(stmt.getAsObject());
    }
    stmt.free();
    return rows;
  },

  get(sql, params = []) {
    const rows = this.all(sql, params);
    return rows.length > 0 ? rows[0] : null;
  },

  exec(sql) {
    if (!dbInstance) throw new Error('Database not initialized yet! Call await db.init()');
    dbInstance.run(sql);
    saveDb();
  }
};

module.exports = dbWrapper;
