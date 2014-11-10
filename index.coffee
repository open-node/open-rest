rest = require "./lib/initialize"

rest.router     = require "./lib/router"
rest.helper     = require "./lib/helper"
rest.defaultCtl = require "./lib/controller"
rest.model      = require "./lib/model"
rest.utils      = require "./lib/utils"
rest.errors     = require "./lib/errors"
rest.restify    = require "restify"
rest.Sequelize  = require "sequelize"

module.exports = rest
