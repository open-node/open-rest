#! /usr/bin/env jasmine-node --coffee --matchall

Restspec    = require 'restspec'
config      = require '../app/configs/config.apitest'
options     = require './options'

new Restspec options(config)
