_ = require 'underscore'

module.exports = (config) ->
  name: '这是一个初始化测试'
  urlRoot: "http://127.0.0.1:#{config.service.port}"
  cases: require './index'
  hooks:
    done: ->
      _.delay ->
        console.log "Done at: #{new Date}"
        process.exit()
      , 100
  globals:
    request:
      headers:
        'X-Auth-Token': 1
