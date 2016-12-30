const rest = require('./lib/initialize');

rest.Router = require('open-router');
rest.helper = require('./lib/helper');
rest.utils = require('./lib/utils');
rest.errors = require('./lib/errors');
rest.restify = require('restify');

process.on('uncaughtException', (error) => {
  rest.utils.logger.error(error);
});

process.on('unhandledRejection', (reason, p) => {
  rest.utils.logger.error(reason, p);
});

process.on('rejectionHandled', (error) => {
  rest.utils.logger.error(error);
});

module.exports = rest;
