'use strict';

const mysql = require('mysql2/promise');
const Redis = require('ioredis');
const { log } = require('./logger');

let dbPool = null;
let redis = null;

async function initDb() {
  if (dbPool) return dbPool;

  const cfg = {
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0,
    enableKeepAlive: true,
  };

  if (!cfg.host || !cfg.user || !cfg.password || !cfg.database) {
    throw new Error('DB configuration missing (DB_HOST/DB_USER/DB_PASSWORD/DB_NAME)');
  }

  dbPool = mysql.createPool(cfg);

  // Best-effort schema bootstrap
  try {
    const conn = await dbPool.getConnection();
    await conn.query(`
      CREATE TABLE IF NOT EXISTS visits (
        id INT AUTO_INCREMENT PRIMARY KEY,
        path VARCHAR(255) NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    `);
    conn.release();
    log.info('db ready');
  } catch (err) {
    log.error({ err }, 'db init failed');
    throw err;
  }

  return dbPool;
}

function initRedis() {
  if (redis) return redis;

  const host = process.env.REDIS_HOST;
  const port = Number(process.env.REDIS_PORT || 6379);
  if (!host) throw new Error('REDIS_HOST missing');

  redis = new Redis({
    host,
    port,
    lazyConnect: false,
    enableReadyCheck: true,
    maxRetriesPerRequest: 3,
  });

  redis.on('error', (err) => log.error({ err }, 'redis error'));
  redis.on('ready', () => log.info('redis ready'));

  return redis;
}

async function shutdown() {
  if (redis) await redis.quit().catch(() => {});
  if (dbPool) await dbPool.end().catch(() => {});
}

module.exports = { initDb, initRedis, shutdown };
