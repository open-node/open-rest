rest = require "./lib/initialize"

rest.Router     = require "open-router"
rest.helper     = require "./lib/helper"
rest.defaultCtl = require "./lib/controller"
rest.model      = require "./lib/model"
rest.utils      = require "./lib/utils"
rest.errors     = require "./lib/errors"
rest.restify    = require "restify"
rest.Sequelize  = require "sequelize"
rest.mysql      = require "mysql"

# 异常处理，尽量保证服务不要宕掉
process.on 'uncaughtException', (error) ->
  console.error new Date
  console.error error
  console.error error.stack

module.exports = rest
