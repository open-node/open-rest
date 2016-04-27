async = require 'async'

module.exports = (root) ->
  rest = require "#{root}/node_modules/open-rest"
  db = require("#{root}/app/configs").db

  rest.model.init(db, "#{root}/app/models")
  models = []
  for name, Model of rest.model()
    models.push(Model)

  async.map(models, (Model, callback) ->
    Model.sync().then((name) ->
      callback(null, Model.name)
    ).catch(callback)
  , (error, results) ->
    console.log "#{results} sync done."
    process.exit(0)
  )

