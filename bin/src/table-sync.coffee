module.exports = (root) ->
  rest = require "#{root}/node_modules/open-rest"
  db = require("#{root}/app/configs").db

  rest.model.init(db, "#{root}/app/models")
  for name, Model of rest.model()
    Model.sync()
    console.log "#{name} sync done."
