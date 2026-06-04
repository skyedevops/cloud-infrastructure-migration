'use strict';

const pino = require('pino');
const pinoHttp = require('pino-http');

const log = pino({
  level: process.env.LOG_LEVEL || 'info',
  base: { service: 'cloud-migration-sample-app' },
});

function httpLogger() {
  return pinoHttp({
    logger: log,
    customLogLevel: function (req, res, err) {
      if (err || res.statusCode >= 500) return 'error';
      if (res.statusCode >= 400) return 'warn';
      return 'info';
    },
  });
}

module.exports = { log, httpLogger };
