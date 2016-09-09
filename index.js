var rest = require("./lib/initialize");

rest.Router = require("open-router");
rest.helper = require("./lib/helper");
rest.defaultCtl = require("./lib/controller");
rest.model = require("./lib/model");
rest.utils = require("./lib/utils");
rest.errors = require("./lib/errors");
rest.restify = require("restify");
rest.Sequelize = require("sequelize");
rest.mysql = require("mysql");

process.on('uncaughtException', function(error) {
  rest.utils.logger.error(error);
});

process.on('rejectionHandled', function(error) {
  rest.utils.logger.error(error);
});

module.exports = rest;
