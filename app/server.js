'use strict';

const express = require('express');
const { initDb, initRedis } = require('./clients');
const { log, httpLogger } = require('./logger');

async function main() {
  const app = express();
  app.use(express.json());
  app.use(httpLogger());

  // Best-effort init: log but don't crash if deps are unreachable.
  let db = null;
  let redis = null;
  try {
    db = await initDb();
  } catch (err) {
    log.warn({ err }, 'starting without db');
  }
  try {
    redis = initRedis();
  } catch (err) {
    log.warn({ err }, 'starting without redis');
  }

  // Public instance metadata
  app.get('/', async (req, res) => {
    const body = {
      service: 'cloud-migration-sample-app',
      timestamp: new Date().toISOString(),
    };
    if (req.headers['x-forwarded-for']) body.client_ip = req.headers['x-forwarded-for'];
    res.json(body);
  });

  // Health: process is up
  app.get('/healthz', (req, res) => res.json({ status: 'ok' }));

  // Readiness: also pings dependencies
  app.get('/readyz', async (req, res) => {
    const result = { status: 'ok', checks: { db: 'unknown', redis: 'unknown' } };
    if (db) {
      try {
        const [rows] = await db.query('SELECT 1 AS ok');
        result.checks.db = rows[0].ok === 1 ? 'ok' : 'fail';
      } catch (err) {
        result.checks.db = 'fail';
      }
    } else {
      result.checks.db = 'skip';
    }
    if (redis) {
      try {
        const pong = await redis.ping();
        result.checks.redis = pong === 'PONG' ? 'ok' : 'fail';
      } catch (err) {
        result.checks.redis = 'fail';
      }
    } else {
      result.checks.redis = 'skip';
    }
    const ok = Object.values(result.checks).every((v) => v === 'ok' || v === 'skip');
    res.status(ok ? 200 : 503).json(result);
  });

  // Cache: writes a counter, increments, returns it
  app.get('/cache', async (req, res) => {
    if (!redis) return res.status(503).json({ error: 'redis unavailable' });
    const n = await redis.incr('hits');
    res.json({ cache: 'redis', hits: Number(n) });
  });

  // DB: records a visit, returns the row count
  app.post('/visit', async (req, res) => {
    if (!db) return res.status(503).json({ error: 'db unavailable' });
    const path = (req.body && req.body.path) || '/';
    await db.query('INSERT INTO visits (path) VALUES (?)', [path]);
    const [[row]] = await db.query('SELECT COUNT(*) AS n FROM visits');
    res.json({ visited: path, total: row.n });
  });

  // 404 + error handlers
  app.use((req, res) => res.status(404).json({ error: 'not_found' }));
  app.use((err, req, res, next) => {
    log.error({ err }, 'unhandled error');
    res.status(500).json({ error: 'internal' });
  });

  const port = Number(process.env.PORT || 3000);
  const server = app.listen(port, '0.0.0.0', () => {
    log.info({ port }, 'listening');
  });

  const shutdown = (sig) => {
    log.info({ sig }, 'shutting down');
    server.close(() => process.exit(0));
  };
  process.on('SIGINT', () => shutdown('SIGINT'));
  process.on('SIGTERM', () => shutdown('SIGTERM'));
}

main().catch((err) => {
  log.fatal({ err }, 'fatal');
  process.exit(1);
});
