#! /usr/bin/env coffee

cluster = require 'cluster'

if cluster.isMaster
  for i in [1..(require('os')).cpus().length]
    cluster.fork().on 'exit', (code, signal) ->
      if code isnt 0
        console.error "worker exited with error code: " + code
      else
        console.log "worker success!"
else
  require './index'
